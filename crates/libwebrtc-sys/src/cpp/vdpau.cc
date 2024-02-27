#include <X11/Xlib.h>
#include <X11/Xos.h>
#include <X11/Xutil.h>
#include <stdio.h>
#include <stdlib.h>
#include <vdpau/vdpau_x11.h>
#include <iostream>
#include "api/video/i420_buffer.h"
#include "third_party/libyuv/include/libyuv/convert.h"
#include "libyuv.h"
#include "vdpau.h"

static Window x11_window;
static GC x11_gc;
constexpr int kMaxAbsQpDeltaValue = 51;
static int frame_count;
static int surface_count;


// TODO(rogurotus): Parse from H264 frame.
static const uint8_t default_scaling4[2][16] = {
    {  6, 13, 20, 28, 13, 20, 28, 32,
      20, 28, 32, 37, 28, 32, 37, 42 },
    { 10, 14, 20, 24, 14, 20, 24, 27,
      20, 24, 27, 30, 24, 27, 30, 34 }
};

// TODO(rogurotus): Parse from H264 frame.
static const uint8_t default_scaling8[2][64] = {
    {  6, 10, 13, 16, 18, 23, 25, 27,
      10, 11, 16, 18, 23, 25, 27, 29,
      13, 16, 18, 23, 25, 27, 29, 31,
      16, 18, 23, 25, 27, 29, 31, 33,
      18, 23, 25, 27, 29, 31, 33, 36,
      23, 25, 27, 29, 31, 33, 36, 38,
      25, 27, 29, 31, 33, 36, 38, 40,
      27, 29, 31, 33, 36, 38, 40, 42 },
    {  9, 13, 15, 17, 19, 21, 22, 24,
      13, 13, 17, 19, 21, 22, 24, 25,
      15, 17, 19, 21, 22, 24, 25, 27,
      17, 19, 21, 22, 24, 25, 27, 28,
      19, 21, 22, 24, 25, 27, 28, 30,
      21, 22, 24, 25, 27, 28, 30, 32,
      22, 24, 25, 27, 28, 30, 32, 33,
      24, 25, 27, 28, 30, 32, 33, 35 }
};


MyH264Decoder::MyH264Decoder() {
  frame_count = 0;
  surface_count = 0;
  x11_display = XOpenDisplay((char*)0);
  x11_screen = DefaultScreen(x11_display);

  init_vdpau_ctx();
  init_decoder();
  init_vdpau_mixer();
  init_vdpau_surfaces();
  init_vdpau_output();
}

VdpStatus MyH264Decoder::init_vdpau_surfaces() {
  int i;
  VdpStatus status = VDP_STATUS_OK;

  for (i = 0; i < NUMBER_OF_SURFACES; i++) {
    surfaces[i] = VDP_INVALID_HANDLE;

    status = table->vdp_video_surface_create(vdp_device, VDP_CHROMA_TYPE_420,
                                             width, height, &surfaces[i]);
    if (status != VDP_STATUS_OK) {
      fprintf(stderr, "Failed to create surface\n");
      return (VdpStatus)-1;
    }
  }
  fprintf(stdout, "Created surfaces\n");
  return (VdpStatus)0;
}

void MyH264Decoder::init_vdpau_functions() {
  fprintf(stdout, "Initializing vpdau functions\n");
  VdpStatus status;
  table = new vdp_functable();
  if (!table) {
    fprintf(stdout, "Err\n");
  }

  size_t iter;
  int i;
  int size = sizeof(vdp_functable) / sizeof(void*);

  for (i = 0, iter = (size_t)table; i < size; i++, iter += (sizeof(size_t))) {
    std::cout << (size_t)iter << " " << refs[i] << std::endl;
    status = vdp_get_proc_address(vdp_device, refs[i], (void**)iter);
    if (status != VDP_STATUS_OK)
      printf("Failed\n");
  }
  unsigned int version;
  const char* info;
  table->vdp_get_information_string(&info);
  table->vdp_get_api_version(&version);
}

void MyH264Decoder::init_vdpau_mixer() {
  mixer_features[0] = VDP_VIDEO_MIXER_FEATURE_NOISE_REDUCTION;
  mixer_features[1] = VDP_VIDEO_MIXER_FEATURE_SHARPNESS;
  mixer_features[2] = VDP_VIDEO_MIXER_FEATURE_DEINTERLACE_TEMPORAL;
  mixer_features[3] = VDP_VIDEO_MIXER_FEATURE_DEINTERLACE_TEMPORAL_SPATIAL;
  mixer_features[4] = VDP_VIDEO_MIXER_FEATURE_INVERSE_TELECINE;
  VdpVideoMixerParameter params[] = {
      VDP_VIDEO_MIXER_PARAMETER_VIDEO_SURFACE_WIDTH,
      VDP_VIDEO_MIXER_PARAMETER_VIDEO_SURFACE_HEIGHT,
      VDP_VIDEO_MIXER_PARAMETER_CHROMA_TYPE, VDP_VIDEO_MIXER_PARAMETER_LAYERS};
  chroma = VDP_CHROMA_TYPE_420;
  int num_layers = 3;
  void const* param_values[] = {&width, &height, &chroma, &num_layers};

  VdpStatus status = table->vdp_video_mixer_create(
      vdp_device, 5, mixer_features, 4, params, param_values, &vdp_mixer);
  if (status != VDP_STATUS_OK) {
    fprintf(stderr, "Failed to create mixer\n");
  }
  fprintf(stdout, "Video mixer created %i\n", status);
}

void MyH264Decoder::init_vdpau_ctx() {
  VdpStatus status = VDP_STATUS_OK;

  if (!x11_display) {
    fprintf(stderr, "Display cannot be null\n");
  }

  fprintf(stdout, "Initializing vdpau context\n");
  status = vdp_device_create_x11(x11_display, x11_screen, &vdp_device,
                                 &vdp_get_proc_address);
  fprintf(stdout, "Created x11 device\n");

  init_vdpau_functions();
}


void MyH264Decoder::ParseSlice(const uint8_t* slice, size_t length) {
  webrtc::H264::NaluType nalu_type = webrtc::H264::ParseNaluType(slice[0]);
  switch (nalu_type) {
    case webrtc::H264::NaluType::kSps: {
      sps_ =
          webrtc::MySpsParser::ParseSps(slice + webrtc::H264::kNaluTypeSize,
                                        length - webrtc::H264::kNaluTypeSize);
      break;
    }
    case webrtc::H264::NaluType::kPps: {
      pps_ =
          webrtc::MyPpsParser::ParsePps(slice + webrtc::H264::kNaluTypeSize,
                                        length - webrtc::H264::kNaluTypeSize);
      break;
    }
    case webrtc::H264::NaluType::kAud:
    case webrtc::H264::NaluType::kSei:
    case webrtc::H264::NaluType::kPrefix:
      break;  // Ignore these nalus, as we don't care about their contents.
    default:
      ParseNonParameterSetNalu(slice, length, nalu_type);
      break;
  }
}

int MyH264Decoder::ParseNonParameterSetNalu(const uint8_t* source,
                                            size_t source_length,
                                            uint8_t nalu_type) {
  if (!sps_ || !pps_)
    return -1;

  last_slice_qp_delta_ = absl::nullopt;
  const std::vector<uint8_t> slice_rbsp =
      webrtc::H264::ParseRbsp(source, source_length);
  if (slice_rbsp.size() < webrtc::H264::kNaluTypeSize)
    return -1;

  webrtc::BitstreamReader slice_reader(slice_rbsp);
  slice_reader.ConsumeBits(webrtc::H264::kNaluTypeSize * 8);

  // Check to see if this is an IDR slice, which has an extra field to parse
  // out.
  bool is_idr = (source[0] & 0x0F) == webrtc::H264::NaluType::kIdr;
  uint8_t nal_ref_idc = (source[0] & 0x60) >> 5;

  // first_mb_in_slice: ue(v)
  slice_reader.ReadExponentialGolomb();
  // slice_type: ue(v)
  uint32_t slice_type = slice_reader.ReadExponentialGolomb();
  // slice_type's 5..9 range is used to indicate that all slices of a picture
  // have the same value of slice_type % 5, we don't care about that, so we map
  // to the corresponding 0..4 range.
  slice_type %= 5;
  // pic_parameter_set_id: ue(v)
  slice_reader.ReadExponentialGolomb();
  if (sps_->separate_colour_plane_flag == 1) {
    // colour_plane_id
    //  sps_->frame_num = slice_reader.Read<int16_t>();

    slice_reader.ConsumeBits(2);
  }

  // frame_num: u(v)
  sps_->frame_num = slice_reader.ReadBits(sps_->log2_max_frame_num);
  // Represented by log2_max_frame_num bits.
  // slice_reader.ConsumeBits(sps_->log2_max_frame_num);
  bool field_pic_flag = false;
  if (sps_->frame_mbs_only_flag == 0) {
    // field_pic_flag: u(1)
    field_pic_flag = slice_reader.Read<bool>();
    sps_->field_pic_flag = field_pic_flag;
    if (field_pic_flag) {
      sps_->bottom_field_flag = slice_reader.ReadBits(1);
      // bottom_field_flag: u(1)
      // slice_reader.ConsumeBits(1);
    }
  }
  if (is_idr) {
    // idr_pic_id: ue(v)
    slice_reader.ReadExponentialGolomb();
  }
  // pic_order_cnt_lsb: u(v)
  // Represented by sps_.log2_max_pic_order_cnt_lsb bits.
  if (sps_->pic_order_cnt_type == 0) {
    slice_reader.ConsumeBits(sps_->log2_max_pic_order_cnt_lsb);
    if (pps_->bottom_field_pic_order_in_frame_present_flag && !field_pic_flag) {
      // delta_pic_order_cnt_bottom: se(v)
      slice_reader.ReadExponentialGolomb();
    }
  }
  if (sps_->pic_order_cnt_type == 1 &&
      !sps_->delta_pic_order_always_zero_flag) {
    // delta_pic_order_cnt[0]: se(v)
    slice_reader.ReadExponentialGolomb();
    if (pps_->bottom_field_pic_order_in_frame_present_flag && !field_pic_flag) {
      // delta_pic_order_cnt[1]: se(v)
      slice_reader.ReadExponentialGolomb();
    }
  }
  if (pps_->redundant_pic_cnt_present_flag) {
    // redundant_pic_cnt: ue(v)
    slice_reader.ReadExponentialGolomb();
  }
  if (slice_type == webrtc::H264::SliceType::kB) {
    // direct_spatial_mv_pred_flag: u(1)
    slice_reader.ConsumeBits(1);
  }
  switch (slice_type) {
    case webrtc::H264::SliceType::kP:
    case webrtc::H264::SliceType::kB:
    case webrtc::H264::SliceType::kSp:
      // num_ref_idx_active_override_flag: u(1)
      if (slice_reader.Read<bool>()) {
        // num_ref_idx_l0_active_minus1: ue(v)
          pps_->num_ref_idx_l0_active_minus1 = slice_reader.ReadExponentialGolomb();

        if (slice_type == webrtc::H264::SliceType::kB) {
          // num_ref_idx_l1_active_minus1: ue(v)
          pps_->num_ref_idx_l1_active_minus1 = slice_reader.ReadExponentialGolomb();
        }
      }
      break;
    default:
      break;
  }
  if (!slice_reader.Ok()) {
    return -1;
  }
  // assume nal_unit_type != 20 && nal_unit_type != 21:
  if (nalu_type == 20 || nalu_type == 21) {
    // RTC_LOG(LS_ERROR) << "Unsupported nal unit type.";
    return -1;
  }
  // if (nal_unit_type == 20 || nal_unit_type == 21)
  //   ref_pic_list_mvc_modification()
  // else
  {
    // ref_pic_list_modification():
    // `slice_type` checks here don't use named constants as they aren't named
    // in the spec for this segment. Keeping them consistent makes it easier to
    // verify that they are both the same.
    if (slice_type % 5 != 2 && slice_type % 5 != 4) {
      // ref_pic_list_modification_flag_l0: u(1)
      if (slice_reader.Read<bool>()) {
        uint32_t modification_of_pic_nums_idc;
        do {
          // modification_of_pic_nums_idc: ue(v)
          modification_of_pic_nums_idc = slice_reader.ReadExponentialGolomb();
          if (modification_of_pic_nums_idc == 0 ||
              modification_of_pic_nums_idc == 1) {
            // abs_diff_pic_num_minus1: ue(v)
            slice_reader.ReadExponentialGolomb();
          } else if (modification_of_pic_nums_idc == 2) {
            // long_term_pic_num: ue(v)
            slice_reader.ReadExponentialGolomb();
          }
        } while (modification_of_pic_nums_idc != 3 && slice_reader.Ok());
      }
    }
    if (slice_type % 5 == 1) {
      // ref_pic_list_modification_flag_l1: u(1)
      if (slice_reader.Read<bool>()) {
        uint32_t modification_of_pic_nums_idc;
        do {
          // modification_of_pic_nums_idc: ue(v)
          modification_of_pic_nums_idc = slice_reader.ReadExponentialGolomb();
          if (modification_of_pic_nums_idc == 0 ||
              modification_of_pic_nums_idc == 1) {
            // abs_diff_pic_num_minus1: ue(v)
            slice_reader.ReadExponentialGolomb();
          } else if (modification_of_pic_nums_idc == 2) {
            // long_term_pic_num: ue(v)
            slice_reader.ReadExponentialGolomb();
          }
        } while (modification_of_pic_nums_idc != 3 && slice_reader.Ok());
      }
    }
  }
  if (!slice_reader.Ok()) {
    return -1;
  }
  // TODO(pbos): Do we need support for pred_weight_table()?
  if ((pps_->weighted_pred_flag &&
       (slice_type == webrtc::H264::SliceType::kP ||
        slice_type == webrtc::H264::SliceType::kSp)) ||
      (pps_->weighted_bipred_idc == 1 &&
       slice_type == webrtc::H264::SliceType::kB)) {
    // RTC_LOG(LS_ERROR) << "Streams with pred_weight_table unsupported.";
    return -1;
  }
  // if ((weighted_pred_flag && (slice_type == P || slice_type == SP)) ||
  //    (weighted_bipred_idc == 1 && slice_type == B)) {
  //  pred_weight_table()
  // }
  if (nal_ref_idc != 0) {
    // dec_ref_pic_marking():
    if (is_idr) {
      // no_output_of_prior_pics_flag: u(1)
      // long_term_reference_flag: u(1)
      slice_reader.ConsumeBits(2);
    } else {
      // adaptive_ref_pic_marking_mode_flag: u(1)
      if (slice_reader.Read<bool>()) {
        uint32_t memory_management_control_operation;
        do {
          // memory_management_control_operation: ue(v)
          memory_management_control_operation =
              slice_reader.ReadExponentialGolomb();
          if (memory_management_control_operation == 1 ||
              memory_management_control_operation == 3) {
            // difference_of_pic_nums_minus1: ue(v)
            slice_reader.ReadExponentialGolomb();
          }
          if (memory_management_control_operation == 2) {
            // long_term_pic_num: ue(v)
            slice_reader.ReadExponentialGolomb();
          }
          if (memory_management_control_operation == 3 ||
              memory_management_control_operation == 6) {
            // long_term_frame_idx: ue(v)
            slice_reader.ReadExponentialGolomb();
          }
          if (memory_management_control_operation == 4) {
            // max_long_term_frame_idx_plus1: ue(v)
            slice_reader.ReadExponentialGolomb();
          }
        } while (memory_management_control_operation != 0 && slice_reader.Ok());
      }
    }
  }
  if (pps_->entropy_coding_mode_flag &&
      slice_type != webrtc::H264::SliceType::kI &&
      slice_type != webrtc::H264::SliceType::kSi) {
    // cabac_init_idc: ue(v)
    slice_reader.ReadExponentialGolomb();
  }

  int last_slice_qp_delta = slice_reader.ReadSignedExponentialGolomb();
  if (!slice_reader.Ok()) {
    return -1;
  }
  if (abs(last_slice_qp_delta) > kMaxAbsQpDeltaValue) {
    // Something has gone wrong, and the parsed value is invalid.
    // RTC_LOG(LS_WARNING) << "Parsed QP value out of range.";
    return -1;
  }

  last_slice_qp_delta_ = last_slice_qp_delta;
  return 0;
}

VdpStatus MyH264Decoder::init_vdpau_output() {
  VdpStatus status = VDP_STATUS_OK;
  status = table->vdp_output_surface_create(
      vdp_device, VDP_RGBA_FORMAT_B8G8R8A8, width, height, &vdp_output_surface);
  if (status != VDP_STATUS_OK) {
    fprintf(stdout, "Failed to create output surface\n");
    return status;
  }
  return status;
}



static absl::optional<int> qp__; 

VdpPictureInfoH264 MyH264Decoder::parseInfo(
    const webrtc::EncodedImage& input_image) {
  h264_bitstream_parser_.ParseBitstream(input_image);
  qp__ = h264_bitstream_parser_.GetLastSliceQp();
  auto data = input_image.data();

  std::vector<webrtc::H264::NaluIndex> nalu_indices =
      webrtc::H264::FindNaluIndices(input_image.data(), input_image.size());

  for (const webrtc::H264::NaluIndex& index : nalu_indices)
    ParseSlice(input_image.data() + index.payload_start_offset,
               index.payload_size);

  VdpPictureInfoH264 info;

  auto sps = sps_.value();
  auto pps = pps_.value();

  info.delta_pic_order_always_zero_flag = sps.delta_pic_order_always_zero_flag;
  info.frame_mbs_only_flag = sps.frame_mbs_only_flag;
  info.log2_max_frame_num_minus4 = sps.log2_max_frame_num - 4;
  // info.log2_max_frame_num_minus4 = 0;
  info.log2_max_pic_order_cnt_lsb_minus4 = sps.log2_max_pic_order_cnt_lsb - 4;
  // info.log2_max_pic_order_cnt_lsb_minus4 = 0;
  info.pic_order_cnt_type = sps.pic_order_cnt_type;
  info.weighted_pred_flag = pps.weighted_pred_flag;
  info.entropy_coding_mode_flag = pps.entropy_coding_mode_flag;
  info.weighted_bipred_idc = pps.weighted_bipred_idc;
  info.redundant_pic_cnt_present_flag = pps.redundant_pic_cnt_present_flag;
  info.pic_init_qp_minus26 = pps.pic_init_qp_minus26;
  info.frame_num = sps.frame_num;
  info.field_pic_flag = sps.field_pic_flag;
  info.deblocking_filter_control_present_flag =
      pps.deblocking_filter_control_present_flag;
  info.direct_8x8_inference_flag = sps.direct_8x8_inference_flag;
  info.chroma_qp_index_offset = pps.chroma_qp_index_offset;
  info.num_ref_idx_l1_active_minus1 = pps.num_ref_idx_l1_active_minus1;
  info.num_ref_idx_l0_active_minus1 = pps.num_ref_idx_l0_active_minus1;
  info.constrained_intra_pred_flag = pps.constrained_intra_pred_flag;
  info.mb_adaptive_frame_field_flag = sps.mb_adaptive_frame_field_flag;
  info.bottom_field_flag = sps.bottom_field_flag;



  // TODO(rogurotus): Parse from H264.s
  info.slice_count = 0;
  info.field_order_cnt[0] = 0;
  info.field_order_cnt[1] = 0;
  info.is_reference = 0;
  info.num_ref_frames = 0;
  info.transform_8x8_mode_flag = 0;
  info.second_chroma_qp_index_offset = 0;
  info.pic_order_present_flag = 0;


  for (int i =0; i<6; ++i) {
    for (int j = 0; j <16; ++j) {
      info.scaling_lists_4x4[i][j] = default_scaling4[i][j];
    }
  }

  for (int i =0; i<2; ++i) {
    for (int j = 0; j <64; ++j) {
      info.scaling_lists_8x8[i][j] = default_scaling8[i][j];
    }
  }

  for (int i = 0; i < 16; i++) {
    if (info.referenceFrames[i].surface != VDP_INVALID_HANDLE) {
      info.referenceFrames[i].surface = VDP_INVALID_HANDLE;
    }
  }

  return info;
}

int32_t MyH264Decoder::Decode(const webrtc::EncodedImage& input_image,
                              int64_t render_time_ms) {
  ++frame_count;
  auto info = parseInfo(input_image);
  VdpVideoSurface current = surfaces[surface_count];

  int k = frame_count-1;
  // TODO(rogurotus): Fix incorrect referenceFrames.
  for (int i=0; i < 1; i++) {
    if (info.referenceFrames[i].surface == VDP_INVALID_HANDLE) {
        info.referenceFrames[i].surface = 
            refframes[i].surface; 
    } 
  }

  VdpBitstreamBuffer vbit;
  vbit.struct_version = VDP_BITSTREAM_BUFFER_VERSION;
  vbit.bitstream = input_image.data();
  vbit.bitstream_bytes = input_image.size();

  VdpStatus st = table->vdp_decoder_render(vdp_decoder, current,
                                           (VdpPictureInfo*)&info, 1, &vbit);

  VdpRect vid_source = {0, 0, width, height};
  VdpRect out_dest = {0, 0, width, height};

  VdpStatus status2 = table->vdp_video_mixer_render(
      vdp_mixer, VDP_INVALID_HANDLE, 0, VDP_VIDEO_MIXER_PICTURE_STRUCTURE_FRAME,
      0, 0, current, 0, 0, &vid_source, vdp_output_surface, &out_dest,
      &out_dest, 0, NULL);

  table->vdp_presentation_queue_display(vdp_queue, vdp_output_surface, 0, 0, 0);

  uint32_t** data;
  const uint32_t a[1] = {width * 4};
  VdpStatus vdp_st;

  data = new uint32_t*[2];

  for (int i = 0; i < 1; ++i) {
    data[i] = new uint32_t[width * height];
  }

  vdp_st = table->vdp_output_surface_get_bits_native(vdp_output_surface, NULL,
                                                     (void* const*)data, a);

  auto buff = webrtc::I420Buffer::Create(width, height);

  libyuv::ARGBToI420((const uint8_t*) data[0],
                      width*4,
                      buff->MutableDataY(),
                      buff->StrideY(),
                      buff->MutableDataU(),
                      buff->StrideU(),
                      buff->MutableDataV(),
                      buff->StrideV(),
                      width,
                      height);

  auto builder = webrtc::VideoFrame::Builder();

  webrtc::VideoFrame frame = builder.set_video_frame_buffer(buff)
                                 .set_rotation(webrtc::kVideoRotation_0)
                                 .set_timestamp_ms(render_time_ms)
                                 .build();

  frame.set_timestamp(input_image.Timestamp());
  frame.set_ntp_time_ms(input_image.ntp_time_ms_);


  callback->Decoded(frame, absl::nullopt, qp__);

  refframes[k%16].surface = current;
  ++surface_count;
  if (surface_count >= 16)
      surface_count = 0;
  if (frame_count >= 30) {
      frame_count = 0;
      surface_count = 0;
  }
  return 0;
}

VdpStatus MyH264Decoder::init_x11() {
  return VDP_STATUS_OK;
}

VdpStatus MyH264Decoder::init_vdpau() {
  return VDP_STATUS_OK;
}

VdpStatus MyH264Decoder::init_decoder() {
  VdpStatus retval = VDP_STATUS_OK;

  retval = table->vdp_decoder_create(vdp_device, VDP_DECODER_PROFILE_H264_MAIN,
                                     width, height, 1, &vdp_decoder);

  if (retval != VDP_STATUS_OK) {
    fprintf(stderr, "Decoder create failed with error %d\n", retval);
    return retval;
  }

  return retval;
}

VdpStatus MyH264Decoder::init_video_mixer() {
  return (VdpStatus)0;
}

VdpStatus MyH264Decoder::init_presentation_queue() {
  VdpStatus vdpret;
  return vdpret;
}

bool MyH264Decoder::Configure(const Settings& settings) {
  width = settings.max_render_resolution().Width();
  height = settings.max_render_resolution().Height();
  return true;
}

int32_t MyH264Decoder::RegisterDecodeCompleteCallback(
    webrtc::DecodedImageCallback* callback) {
  this->callback = callback;
  return 0;
}

int32_t MyH264Decoder::Release() {
  return 0;
}

webrtc::VideoDecoder::DecoderInfo MyH264Decoder::GetDecoderInfo() const {
  auto a = webrtc::VideoDecoder::DecoderInfo();
  a.implementation_name = "TRY_HARD";
  return a;
}

// Deprecated, use GetDecoderInfo().implementation_name instead.
const char* MyH264Decoder::ImplementationName() const {
  return "TRY_HARD";
}

#include <cstdint>
#include <limits>
#include <vector>

#include "absl/numeric/bits.h"
#include "common_video/h264/h264_common.h"
#include "rtc_base/bitstream_reader.h"
#include "rtc_base/checks.h"

namespace webrtc {
namespace {
constexpr int kMaxPicInitQpDeltaValue = 25;
constexpr int kMinPicInitQpDeltaValue = -26;
}  // namespace

// General note: this is based off the 02/2014 version of the H.264 standard.
// You can find it on this page:
// http://www.itu.int/rec/T-REC-H.264

absl::optional<MyPpsParser::MyPpsState> MyPpsParser::ParsePps(
    const uint8_t* data,
    size_t length) {
  // First, parse out rbsp, which is basically the source buffer minus emulation
  // bytes (the last byte of a 0x00 0x00 0x03 sequence). RBSP is defined in
  // section 7.3.1 of the H.264 standard.
  return ParseInternal(H264::ParseRbsp(data, length));
}

bool webrtc::MyPpsParser::ParsePpsIds(const uint8_t* data,
                                      size_t length,
                                      uint32_t* pps_id,
                                      uint32_t* sps_id) {
  RTC_DCHECK(pps_id);
  RTC_DCHECK(sps_id);
  // First, parse out rbsp, which is basically the source buffer minus emulation
  // bytes (the last byte of a 0x00 0x00 0x03 sequence). RBSP is defined in
  // section 7.3.1 of the H.264 standard.
  std::vector<uint8_t> unpacked_buffer = H264::ParseRbsp(data, length);
  BitstreamReader reader(unpacked_buffer);
  *pps_id = reader.ReadExponentialGolomb();
  *sps_id = reader.ReadExponentialGolomb();
  return reader.Ok();
}

absl::optional<uint32_t> webrtc::MyPpsParser::ParsePpsIdFromSlice(
    const uint8_t* data,
    size_t length) {
  std::vector<uint8_t> unpacked_buffer = H264::ParseRbsp(data, length);
  BitstreamReader slice_reader(unpacked_buffer);

  // first_mb_in_slice: ue(v)
  slice_reader.ReadExponentialGolomb();
  // slice_type: ue(v)
  slice_reader.ReadExponentialGolomb();
  // pic_parameter_set_id: ue(v)
  uint32_t slice_pps_id = slice_reader.ReadExponentialGolomb();
  if (!slice_reader.Ok()) {
    return absl::nullopt;
  }
  return slice_pps_id;
}

absl::optional<MyPpsParser::MyPpsState> MyPpsParser::ParseInternal(
    rtc::ArrayView<const uint8_t> buffer) {
  BitstreamReader reader(buffer);
  MyPpsState pps;
  pps.id = reader.ReadExponentialGolomb();
  pps.sps_id = reader.ReadExponentialGolomb();

  // entropy_coding_mode_flag: u(1)
  pps.entropy_coding_mode_flag = reader.Read<bool>();
  // bottom_field_pic_order_in_frame_present_flag: u(1)
  pps.bottom_field_pic_order_in_frame_present_flag = reader.Read<bool>();

  // num_slice_groups_minus1: ue(v)
  uint32_t num_slice_groups_minus1 = reader.ReadExponentialGolomb();
  if (num_slice_groups_minus1 > 0) {
    // slice_group_map_type: ue(v)
    uint32_t slice_group_map_type = reader.ReadExponentialGolomb();
    if (slice_group_map_type == 0) {
      for (uint32_t i_group = 0;
           i_group <= num_slice_groups_minus1 && reader.Ok(); ++i_group) {
        // run_length_minus1[iGroup]: ue(v)
        reader.ReadExponentialGolomb();
      }
    } else if (slice_group_map_type == 1) {
      // TODO(sprang): Implement support for dispersed slice group map type.
      // See 8.2.2.2 Specification for dispersed slice group map type.
    } else if (slice_group_map_type == 2) {
      for (uint32_t i_group = 0;
           i_group <= num_slice_groups_minus1 && reader.Ok(); ++i_group) {
        // top_left[iGroup]: ue(v)
        reader.ReadExponentialGolomb();
        // bottom_right[iGroup]: ue(v)
        reader.ReadExponentialGolomb();
      }
    } else if (slice_group_map_type == 3 || slice_group_map_type == 4 ||
               slice_group_map_type == 5) {
      // slice_group_change_direction_flag: u(1)
      reader.ConsumeBits(1);
      // slice_group_change_rate_minus1: ue(v)
      reader.ReadExponentialGolomb();
    } else if (slice_group_map_type == 6) {
      // pic_size_in_map_units_minus1: ue(v)
      uint32_t pic_size_in_map_units = reader.ReadExponentialGolomb() + 1;
      int slice_group_id_bits = 1 + absl::bit_width(num_slice_groups_minus1);

      // slice_group_id: array of size pic_size_in_map_units, each element
      // is represented by ceil(log2(num_slice_groups_minus1 + 1)) bits.
      int64_t bits_to_consume =
          int64_t{slice_group_id_bits} * pic_size_in_map_units;
      if (!reader.Ok() || bits_to_consume > std::numeric_limits<int>::max()) {
        return absl::nullopt;
      }
      reader.ConsumeBits(bits_to_consume);
    }
  }
  // num_ref_idx_l0_default_active_minus1: ue(v)
  reader.ReadExponentialGolomb();
  // num_ref_idx_l1_default_active_minus1: ue(v)
  reader.ReadExponentialGolomb();
  // weighted_pred_flag: u(1)
  pps.weighted_pred_flag = reader.Read<bool>();
  // weighted_bipred_idc: u(2)
  pps.weighted_bipred_idc = reader.ReadBits(2);

  // pic_init_qp_minus26: se(v)
  pps.pic_init_qp_minus26 = reader.ReadSignedExponentialGolomb();
  // Sanity-check parsed value
  if (!reader.Ok() || pps.pic_init_qp_minus26 > kMaxPicInitQpDeltaValue ||
      pps.pic_init_qp_minus26 < kMinPicInitQpDeltaValue) {
    return absl::nullopt;
  }
  // pic_init_qs_minus26: se(v)
  reader.ReadExponentialGolomb();

  // chroma_qp_index_offset: se(v)
  pps.chroma_qp_index_offset = reader.ReadExponentialGolomb();
  pps.deblocking_filter_control_present_flag = reader.ReadBit();
  // deblocking_filter_control_present_flag: u(1)
  pps.constrained_intra_pred_flag = reader.ReadBit();

  // constrained_intra_pred_flag: u(1)
  // reader.ConsumeBits(1);
  // redundant_pic_cnt_present_flag: u(1)
  pps.redundant_pic_cnt_present_flag = reader.ReadBit();

    // pps.transform_8x8_mode = 0;
    // memcpy(pps->scaling_matrix4, sps->scaling_matrix4,
    //        sizeof(pps->scaling_matrix4));
    // memcpy(pps->scaling_matrix8, sps->scaling_matrix8,
    //        sizeof(pps->scaling_matrix8));

  for (int k = 0; k<0; ++k) {
      reader.ReadBits(8);
  }

  std::cout << "WTF " << reader.RemainingBitCount() << " " << buffer.size() << std::endl;

  for (int i =0; i<6; ++i) {
    for (int j = 0; j <16; ++j) {
      // pps.scaling_lists_4x4[i][j] = reader.ReadBits(8);
    }
  }

  for (int i =0; i<2; ++i) {
    for (int j = 0; j <64; ++j) {
      // pps.scaling_lists_8x8[i][j] = reader.ReadBits(8);
    }
  }
  std::cout << "WTF2" << std::endl;

  if (!reader.Ok()) {
  std::cout << "WTF3" << std::endl;
    return absl::nullopt;
  }

  return pps;
}

}  // namespace webrtc

#include <cstdint>
#include <vector>

#include "common_video/h264/h264_common.h"
#include "rtc_base/bitstream_reader.h"

namespace {
constexpr int kScalingDeltaMin = -128;
constexpr int kScaldingDeltaMax = 127;
}  // namespace

namespace webrtc {

MySpsParser::MySpsState::MySpsState() = default;
MySpsParser::MySpsState::MySpsState(const MySpsState&) = default;
MySpsParser::MySpsState::~MySpsState() = default;

// General note: this is based off the 02/2014 version of the H.264 standard.
// You can find it on this page:
// http://www.itu.int/rec/T-REC-H.264

// Unpack RBSP and parse SPS state from the supplied buffer.
absl::optional<MySpsParser::MySpsState> MySpsParser::ParseSps(
    const uint8_t* data,
    size_t length) {
  std::vector<uint8_t> unpacked_buffer = H264::ParseRbsp(data, length);
  BitstreamReader reader(unpacked_buffer);
  return ParseSpsUpToVui(reader);
}

absl::optional<MySpsParser::MySpsState> MySpsParser::ParseSpsUpToVui(
    BitstreamReader& reader) {
  // Now, we need to use a bitstream reader to parse through the actual AVC SPS
  // format. See Section 7.3.2.1.1 ("Sequence parameter set data syntax") of the
  // H.264 standard for a complete description.
  // Since we only care about resolution, we ignore the majority of fields, but
  // we still have to actively parse through a lot of the data, since many of
  // the fields have variable size.
  // We're particularly interested in:
  // chroma_format_idc -> affects crop units
  // pic_{width,height}_* -> resolution of the frame in macroblocks (16x16).
  // frame_crop_*_offset -> crop information

  MySpsState sps;

  // chroma_format_idc will be ChromaArrayType if separate_colour_plane_flag is
  // 0. It defaults to 1, when not specified.
  uint32_t chroma_format_idc = 1;

  // profile_idc: u(8). We need it to determine if we need to read/skip chroma
  // formats.
  uint8_t profile_idc = reader.Read<uint8_t>();
  // constraint_set0_flag through constraint_set5_flag + reserved_zero_2bits
  // 1 bit each for the flags + 2 bits + 8 bits for level_idc = 16 bits.
  reader.ConsumeBits(16);
  // seq_parameter_set_id: ue(v)
  sps.id = reader.ReadExponentialGolomb();
  sps.separate_colour_plane_flag = 0;
  // See if profile_idc has chroma format information.
  if (profile_idc == 100 || profile_idc == 110 || profile_idc == 122 ||
      profile_idc == 244 || profile_idc == 44 || profile_idc == 83 ||
      profile_idc == 86 || profile_idc == 118 || profile_idc == 128 ||
      profile_idc == 138 || profile_idc == 139 || profile_idc == 134) {
    // chroma_format_idc: ue(v)
    chroma_format_idc = reader.ReadExponentialGolomb();
    if (chroma_format_idc == 3) {
      // separate_colour_plane_flag: u(1)
      sps.separate_colour_plane_flag = reader.ReadBit();
    }
    // bit_depth_luma_minus8: ue(v)
    reader.ReadExponentialGolomb();
    // bit_depth_chroma_minus8: ue(v)
    reader.ReadExponentialGolomb();
    // qpprime_y_zero_transform_bypass_flag: u(1)
    reader.ConsumeBits(1);
    // seq_scaling_matrix_present_flag: u(1)
    if (reader.Read<bool>()) {
      // Process the scaling lists just enough to be able to properly
      // skip over them, so we can still read the resolution on streams
      // where this is included.
      int scaling_list_count = (chroma_format_idc == 3 ? 12 : 8);
      for (int i = 0; i < scaling_list_count; ++i) {
        // seq_scaling_list_present_flag[i]  : u(1)
        if (reader.Read<bool>()) {
          int last_scale = 8;
          int next_scale = 8;
          int size_of_scaling_list = i < 6 ? 16 : 64;
          for (int j = 0; j < size_of_scaling_list; j++) {
            if (next_scale != 0) {
              // delta_scale: se(v)
              int delta_scale = reader.ReadSignedExponentialGolomb();
              if (!reader.Ok() || delta_scale < kScalingDeltaMin ||
                  delta_scale > kScaldingDeltaMax) {
                return absl::nullopt;
              }
              next_scale = (last_scale + delta_scale + 256) % 256;
            }
            if (next_scale != 0)
              last_scale = next_scale;
          }
        }
      }
    }
  }
  // log2_max_frame_num and log2_max_pic_order_cnt_lsb are used with
  // BitstreamReader::ReadBits, which can read at most 64 bits at a time. We
  // also have to avoid overflow when adding 4 to the on-wire golomb value,
  // e.g., for evil input data, ReadExponentialGolomb might return 0xfffc.
  const uint32_t kMaxLog2Minus4 = 12;

  // log2_max_frame_num_minus4: ue(v)
  uint32_t log2_max_frame_num_minus4 = reader.ReadExponentialGolomb();
  if (!reader.Ok() || log2_max_frame_num_minus4 > kMaxLog2Minus4) {
    return absl::nullopt;
  }
  sps.log2_max_frame_num = log2_max_frame_num_minus4 + 4;

  // pic_order_cnt_type: ue(v)
  sps.pic_order_cnt_type = reader.ReadExponentialGolomb();
  if (sps.pic_order_cnt_type == 0) {
    // log2_max_pic_order_cnt_lsb_minus4: ue(v)
    uint32_t log2_max_pic_order_cnt_lsb_minus4 = reader.ReadExponentialGolomb();
    if (!reader.Ok() || log2_max_pic_order_cnt_lsb_minus4 > kMaxLog2Minus4) {
      return absl::nullopt;
    }
    sps.log2_max_pic_order_cnt_lsb = log2_max_pic_order_cnt_lsb_minus4 + 4;
  } else if (sps.pic_order_cnt_type == 1) {
    // delta_pic_order_always_zero_flag: u(1)
    sps.delta_pic_order_always_zero_flag = reader.ReadBit();
    // offset_for_non_ref_pic: se(v)
    reader.ReadExponentialGolomb();
    // offset_for_top_to_bottom_field: se(v)
    reader.ReadExponentialGolomb();
    // num_ref_frames_in_pic_order_cnt_cycle: ue(v)
    uint32_t num_ref_frames_in_pic_order_cnt_cycle =
        reader.ReadExponentialGolomb();
    for (size_t i = 0; i < num_ref_frames_in_pic_order_cnt_cycle; ++i) {
      // offset_for_ref_frame[i]: se(v)
      reader.ReadExponentialGolomb();
      if (!reader.Ok()) {
        return absl::nullopt;
      }
    }
  }
  // max_num_ref_frames: ue(v)
  sps.max_num_ref_frames = reader.ReadExponentialGolomb();
  // gaps_in_frame_num_value_allowed_flag: u(1)
  reader.ConsumeBits(1);
  //
  // IMPORTANT ONES! Now we're getting to resolution. First we read the pic
  // width/height in macroblocks (16x16), which gives us the base resolution,
  // and then we continue on until we hit the frame crop offsets, which are used
  // to signify resolutions that aren't multiples of 16.
  //
  // pic_width_in_mbs_minus1: ue(v)
  sps.width = 16 * (reader.ReadExponentialGolomb() + 1);
  // pic_height_in_map_units_minus1: ue(v)
  uint32_t pic_height_in_map_units_minus1 = reader.ReadExponentialGolomb();
  // frame_mbs_only_flag: u(1)
  sps.frame_mbs_only_flag = reader.ReadBit();
  if (!sps.frame_mbs_only_flag) {
    sps.mb_adaptive_frame_field_flag = reader.ReadBit();
    // mb_adaptive_frame_field_flag: u(1)
    // reader.ConsumeBits(1);
  }
  sps.height =
      16 * (2 - sps.frame_mbs_only_flag) * (pic_height_in_map_units_minus1 + 1);

  sps.direct_8x8_inference_flag = reader.ReadBit();
  // direct_8x8_inference_flag: u(1)
  // reader.ConsumeBits(1);
  //
  // MORE IMPORTANT ONES! Now we're at the frame crop information.
  //
  uint32_t frame_crop_left_offset = 0;
  uint32_t frame_crop_right_offset = 0;
  uint32_t frame_crop_top_offset = 0;
  uint32_t frame_crop_bottom_offset = 0;
  // frame_cropping_flag: u(1)
  if (reader.Read<bool>()) {
    // frame_crop_{left, right, top, bottom}_offset: ue(v)
    frame_crop_left_offset = reader.ReadExponentialGolomb();
    frame_crop_right_offset = reader.ReadExponentialGolomb();
    frame_crop_top_offset = reader.ReadExponentialGolomb();
    frame_crop_bottom_offset = reader.ReadExponentialGolomb();
  }
  // vui_parameters_present_flag: u(1)
  sps.vui_params_present = reader.ReadBit();

  // Far enough! We don't use the rest of the SPS.
  if (!reader.Ok()) {
    return absl::nullopt;
  }

  // Figure out the crop units in pixels. That's based on the chroma format's
  // sampling, which is indicated by chroma_format_idc.
  if (sps.separate_colour_plane_flag || chroma_format_idc == 0) {
    frame_crop_bottom_offset *= (2 - sps.frame_mbs_only_flag);
    frame_crop_top_offset *= (2 - sps.frame_mbs_only_flag);
  } else if (!sps.separate_colour_plane_flag && chroma_format_idc > 0) {
    // Width multipliers for formats 1 (4:2:0) and 2 (4:2:2).
    if (chroma_format_idc == 1 || chroma_format_idc == 2) {
      frame_crop_left_offset *= 2;
      frame_crop_right_offset *= 2;
    }
    // Height multipliers for format 1 (4:2:0).
    if (chroma_format_idc == 1) {
      frame_crop_top_offset *= 2;
      frame_crop_bottom_offset *= 2;
    }
  }
  // Subtract the crop for each dimension.
  sps.width -= (frame_crop_left_offset + frame_crop_right_offset);
  sps.height -= (frame_crop_top_offset + frame_crop_bottom_offset);

  return sps;
}

}  // namespace webrtc

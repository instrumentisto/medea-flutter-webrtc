#ifndef _VDPAU_LAYER_H_
#define _VDPAU_LAYER_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <sstream>

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xos.h>
#include <vdpau/vdpau_x11.h>


#include "api/video_codecs/video_decoder.h"
#include "common_video/h264/h264_bitstream_parser.h"
#include "common_video/h264/h264_common.h"

#define NUMBER_OF_SURFACES 16

typedef struct {
    VdpGetErrorString *vdp_get_error_string;
    VdpGetApiVersion *vdp_get_api_version;
    VdpGetInformationString *vdp_get_information_string;
    VdpDeviceDestroy *vdp_device_destroy;
    VdpGenerateCSCMatrix *vdp_generate_csc_matrix;
    VdpVideoSurfaceQueryCapabilities *vdp_video_surface_query_capabilities;
    VdpVideoSurfaceQueryGetPutBitsYCbCrCapabilities *vdp_video_surface_query_get_put_bits_y_cb_cr_capabilities;
    VdpVideoSurfaceCreate *vdp_video_surface_create;
    VdpVideoSurfaceDestroy *vdp_video_surface_destroy;
    VdpVideoSurfaceGetParameters *vdp_video_surface_get_parameters;
    VdpVideoSurfaceGetBitsYCbCr	*vdp_video_surface_get_bits_y_cb_cr;
    VdpVideoSurfacePutBitsYCbCr	*vdp_video_surface_put_bits_y_cb_cr;
    VdpOutputSurfaceQueryCapabilities *vdp_output_surface_query_capabilities;
    VdpOutputSurfaceQueryGetPutBitsNativeCapabilities *vdp_output_surface_query_get_put_bits_native_capabilities;
    VdpOutputSurfaceQueryPutBitsIndexedCapabilities *vdp_output_surface_query_put_bits_indexed_capabilities;
    VdpOutputSurfaceQueryPutBitsYCbCrCapabilities *vdp_output_surface_query_put_bits_y_cb_cr_capabilities;
    VdpOutputSurfaceCreate *vdp_output_surface_create;
    VdpOutputSurfaceDestroy *vdp_output_surface_destroy;
    VdpOutputSurfaceGetParameters *vdp_output_surface_get_parameters;
    VdpOutputSurfaceGetBitsNative *vdp_output_surface_get_bits_native;
    VdpOutputSurfacePutBitsNative *vdp_output_surface_put_bits_native;
    VdpOutputSurfacePutBitsIndexed *vdp_output_surface_put_bits_indexed;
    VdpOutputSurfacePutBitsYCbCr *vdp_output_surface_put_bits_y_cb_cr;
    VdpBitmapSurfaceQueryCapabilities *vdp_bitmap_surface_query_capabilities;
    VdpBitmapSurfaceCreate *vdp_bitmap_surface_create;
    VdpBitmapSurfaceDestroy *vdp_bitmap_surface_destroy;
    VdpBitmapSurfaceGetParameters *vdp_bitmap_surface_get_parameters;
    VdpBitmapSurfacePutBitsNative *vdp_bitmap_surface_put_bits_native;
    VdpOutputSurfaceRenderOutputSurface *vdp_output_surface_render_output_surface;
    VdpOutputSurfaceRenderBitmapSurface *vdp_output_surface_render_bitmap_surface;
    VdpDecoderQueryCapabilities *vdp_decoder_query_capabilities;
    VdpDecoderCreate *vdp_decoder_create;
    VdpDecoderDestroy *vdp_decoder_destroy;
    VdpDecoderGetParameters *vdp_decoder_get_parameters;
    VdpDecoderRender *vdp_decoder_render;
    VdpVideoMixerQueryFeatureSupport *vdp_video_mixer_query_feature_support;
    VdpVideoMixerQueryParameterSupport *vdp_video_mixer_query_parameter_support;
    VdpVideoMixerQueryAttributeSupport *vdp_video_mixer_query_attribute_support;
    VdpVideoMixerQueryParameterValueRange *vdp_video_mixer_query_parameter_value_range;
    VdpVideoMixerQueryAttributeValueRange *vdp_video_mixer_query_attribute_value_range;
    VdpVideoMixerCreate	*vdp_video_mixer_create;
    VdpVideoMixerSetFeatureEnables *vdp_video_mixer_set_feature_enables;
    VdpVideoMixerGetAttributeValues *vdp_video_mixer_set_attribute_values;
    VdpVideoMixerGetFeatureSupport *vdp_video_mixer_get_feature_support;
    VdpVideoMixerGetFeatureEnables *vdp_video_mixer_get_feature_enables;
    VdpVideoMixerGetParameterValues *vdp_video_mixer_get_parameter_values;
    VdpVideoMixerGetAttributeValues *vdp_video_mixer_get_attribute_values;
    VdpVideoMixerDestroy *vdp_video_mixer_destroy;
    VdpVideoMixerRender	*vdp_video_mixer_render;
    VdpPresentationQueueTargetCreateX11	*vdp_presentation_queue_target_create_x11;
    VdpPresentationQueueTargetDestroy *vdp_presentation_queue_target_destroy;
    VdpPresentationQueueCreate *vdp_presentation_queue_create;
    VdpPresentationQueueDestroy	*vdp_presentation_queue_destroy;
    VdpPresentationQueueSetBackgroundColor *vdp_presentation_queue_set_background_color;
    VdpPresentationQueueGetBackgroundColor *vdp_presentation_queue_get_background_color;
    VdpPresentationQueueGetTime	*vdp_presentation_queue_get_time;
    VdpPresentationQueueDisplay	*vdp_presentation_queue_display;
    VdpPresentationQueueBlockUntilSurfaceIdle *vdp_presentation_queue_block_until_surface_idle;
    VdpPresentationQueueQuerySurfaceStatus *vdp_presentation_queue_query_surface_status;
    VdpPreemptionCallbackRegister *vdp_preemption_callback_register;
}vdp_functable;

static int refs[] = {
    VDP_FUNC_ID_GET_ERROR_STRING,
    VDP_FUNC_ID_GET_API_VERSION,
    VDP_FUNC_ID_GET_INFORMATION_STRING,
    VDP_FUNC_ID_DEVICE_DESTROY,
    VDP_FUNC_ID_GENERATE_CSC_MATRIX,
    VDP_FUNC_ID_VIDEO_SURFACE_QUERY_CAPABILITIES,
    VDP_FUNC_ID_VIDEO_SURFACE_QUERY_GET_PUT_BITS_Y_CB_CR_CAPABILITIES,
    VDP_FUNC_ID_VIDEO_SURFACE_CREATE,
    VDP_FUNC_ID_VIDEO_SURFACE_DESTROY,
    VDP_FUNC_ID_VIDEO_SURFACE_GET_PARAMETERS,
    VDP_FUNC_ID_VIDEO_SURFACE_GET_BITS_Y_CB_CR,
    VDP_FUNC_ID_VIDEO_SURFACE_PUT_BITS_Y_CB_CR,
    VDP_FUNC_ID_OUTPUT_SURFACE_QUERY_CAPABILITIES,
    VDP_FUNC_ID_OUTPUT_SURFACE_QUERY_GET_PUT_BITS_NATIVE_CAPABILITIES,
    VDP_FUNC_ID_OUTPUT_SURFACE_QUERY_PUT_BITS_INDEXED_CAPABILITIES,
    VDP_FUNC_ID_OUTPUT_SURFACE_QUERY_PUT_BITS_Y_CB_CR_CAPABILITIES,
    VDP_FUNC_ID_OUTPUT_SURFACE_CREATE,
    VDP_FUNC_ID_OUTPUT_SURFACE_DESTROY,
    VDP_FUNC_ID_OUTPUT_SURFACE_GET_PARAMETERS,
    VDP_FUNC_ID_OUTPUT_SURFACE_GET_BITS_NATIVE,
    VDP_FUNC_ID_OUTPUT_SURFACE_PUT_BITS_NATIVE,
    VDP_FUNC_ID_OUTPUT_SURFACE_PUT_BITS_INDEXED,
    VDP_FUNC_ID_OUTPUT_SURFACE_PUT_BITS_Y_CB_CR,
    VDP_FUNC_ID_BITMAP_SURFACE_QUERY_CAPABILITIES,
    VDP_FUNC_ID_BITMAP_SURFACE_CREATE,
    VDP_FUNC_ID_BITMAP_SURFACE_DESTROY,
    VDP_FUNC_ID_BITMAP_SURFACE_GET_PARAMETERS,
    VDP_FUNC_ID_BITMAP_SURFACE_PUT_BITS_NATIVE,
    VDP_FUNC_ID_OUTPUT_SURFACE_RENDER_OUTPUT_SURFACE,
    VDP_FUNC_ID_OUTPUT_SURFACE_RENDER_BITMAP_SURFACE,
    VDP_FUNC_ID_DECODER_QUERY_CAPABILITIES,
    VDP_FUNC_ID_DECODER_CREATE,
    VDP_FUNC_ID_DECODER_DESTROY,
    VDP_FUNC_ID_DECODER_GET_PARAMETERS,
    VDP_FUNC_ID_DECODER_RENDER,
    VDP_FUNC_ID_VIDEO_MIXER_QUERY_FEATURE_SUPPORT,
    VDP_FUNC_ID_VIDEO_MIXER_QUERY_PARAMETER_SUPPORT,
    VDP_FUNC_ID_VIDEO_MIXER_QUERY_ATTRIBUTE_SUPPORT,
    VDP_FUNC_ID_VIDEO_MIXER_QUERY_PARAMETER_VALUE_RANGE,
    VDP_FUNC_ID_VIDEO_MIXER_QUERY_ATTRIBUTE_VALUE_RANGE,
    VDP_FUNC_ID_VIDEO_MIXER_CREATE,
    VDP_FUNC_ID_VIDEO_MIXER_SET_FEATURE_ENABLES,
    VDP_FUNC_ID_VIDEO_MIXER_SET_ATTRIBUTE_VALUES,
    VDP_FUNC_ID_VIDEO_MIXER_GET_FEATURE_SUPPORT,
    VDP_FUNC_ID_VIDEO_MIXER_GET_FEATURE_ENABLES,
    VDP_FUNC_ID_VIDEO_MIXER_GET_PARAMETER_VALUES,
    VDP_FUNC_ID_VIDEO_MIXER_GET_ATTRIBUTE_VALUES,
    VDP_FUNC_ID_VIDEO_MIXER_DESTROY,
    VDP_FUNC_ID_VIDEO_MIXER_RENDER,
    VDP_FUNC_ID_PRESENTATION_QUEUE_TARGET_CREATE_X11,
    VDP_FUNC_ID_PRESENTATION_QUEUE_TARGET_DESTROY,
    VDP_FUNC_ID_PRESENTATION_QUEUE_CREATE,
    VDP_FUNC_ID_PRESENTATION_QUEUE_DESTROY,
    VDP_FUNC_ID_PRESENTATION_QUEUE_SET_BACKGROUND_COLOR,
    VDP_FUNC_ID_PRESENTATION_QUEUE_GET_BACKGROUND_COLOR,
    VDP_FUNC_ID_PRESENTATION_QUEUE_GET_TIME,
    VDP_FUNC_ID_PRESENTATION_QUEUE_DISPLAY,
    VDP_FUNC_ID_PRESENTATION_QUEUE_BLOCK_UNTIL_SURFACE_IDLE,
    VDP_FUNC_ID_PRESENTATION_QUEUE_QUERY_SURFACE_STATUS,
    VDP_FUNC_ID_PREEMPTION_CALLBACK_REGISTER
};

typedef struct {
    // Display *display;
    // int screen;
    // Window win;
    // GC gc;
    // VdpDevice vdp_device;
    // VdpGetProcAddress *vdp_get_proc_address;
    vdp_functable *table;
    VdpOutputSurface display_surface;
    VdpPresentationQueueTarget queue_target;
    VdpPresentationQueue queue;
} vdp_ctx;

typedef struct {
    uint32_t width, height;
    double ratio;
    vdp_ctx *ctx;
    VdpDecoder vdp_decoder;
    VdpDecoderProfile profile;
    VdpVideoSurface surfaces[NUMBER_OF_SURFACES];
    int refframes[25];
} vdp_decoder_ctx;



#include <stddef.h>
#include <stdint.h>

#include "absl/types/optional.h"
#include "api/array_view.h"

namespace webrtc {


#include "absl/types/optional.h"
#include "rtc_base/bitstream_reader.h"

// A class for parsing out sequence parameter set (SPS) data from an H264 NALU.
class MySpsParser {
 public:
  // The parsed state of the SPS. Only some select values are stored.
  // Add more as they are actually needed.
  struct MySpsState {
    MySpsState();
    MySpsState(const MySpsState&);
    ~MySpsState();

    uint32_t width = 0;
    uint32_t height = 0;
    uint16_t frame_num = 0;
    bool field_pic_flag = false;
    bool bottom_field_flag = false;
    uint32_t delta_pic_order_always_zero_flag = 0;
    uint32_t separate_colour_plane_flag = 0;
    uint32_t redundant_pic_cnt_present_flag = 0;
    uint32_t direct_8x8_inference_flag;

    uint32_t frame_mbs_only_flag = 0;
    uint32_t mb_adaptive_frame_field_flag = 0;
    uint32_t log2_max_frame_num = 4;          // Smallest valid value.
    uint32_t log2_max_pic_order_cnt_lsb = 4;  // Smallest valid value.
    uint32_t pic_order_cnt_type = 0;
    uint32_t max_num_ref_frames = 0;
    uint32_t vui_params_present = 0;
    uint32_t transform_8x_mode = 0;
    
    uint32_t id = 0;


  };

  // Unpack RBSP and parse SPS state from the supplied buffer.
  static absl::optional<MySpsState> ParseSps(const uint8_t* data, size_t length);

 protected:
  // Parse the SPS state, up till the VUI part, for a buffer where RBSP
  // decoding has already been performed.
  static absl::optional<MySpsState> ParseSpsUpToVui(BitstreamReader& reader);
};


// A class for parsing out picture parameter set (PPS) data from a H264 NALU.
class MyPpsParser {
 public:
  // The parsed state of the PPS. Only some select values are stored.
  // Add more as they are actually needed.
  struct MyPpsState {
    MyPpsState() = default;

    bool bottom_field_pic_order_in_frame_present_flag = false;
    bool weighted_pred_flag = false;
    bool entropy_coding_mode_flag = false;
    uint32_t weighted_bipred_idc = false;
    uint32_t redundant_pic_cnt_present_flag = 0;
    uint32_t deblocking_filter_control_present_flag = 0;
    int8_t chroma_qp_index_offset = 0;
    int pic_init_qp_minus26 = 0;
    uint32_t id = 0;
    uint32_t sps_id = 0;


    uint32_t constrained_intra_pred_flag = 0;
    uint32_t num_ref_idx_l1_active_minus1;
    uint32_t num_ref_idx_l0_active_minus1;


    /** Convert to raster order. */
    uint8_t scaling_lists_4x4[6][16];
    /** Convert to raster order. */
    uint8_t scaling_lists_8x8[2][64];
  };

  // Unpack RBSP and parse PPS state from the supplied buffer.
  static absl::optional<MyPpsState> ParsePps(const uint8_t* data, size_t length);

  static bool ParsePpsIds(const uint8_t* data,
                          size_t length,
                          uint32_t* pps_id,
                          uint32_t* sps_id);

  static absl::optional<uint32_t> ParsePpsIdFromSlice(const uint8_t* data,
                                                      size_t length);

 protected:
  // Parse the PPS state, for a buffer where RBSP decoding has already been
  // performed.
  static absl::optional<MyPpsState> ParseInternal(
      rtc::ArrayView<const uint8_t> buffer);
};

}  // namespace webrtc


class MyH264Decoder : public webrtc::VideoDecoder {

public:
    MyH264Decoder();
    VdpStatus init_vdpau();
    VdpStatus init_decoder();
    VdpStatus init_x11();
    VdpStatus init_video_mixer();
    VdpStatus init_presentation_queue();
    VdpStatus init_vdpau_surfaces();
    void init_vdpau_ctx();
    void init_vdpau_functions();
    void init_vdpau_mixer();
    VdpStatus init_vdpau_output();
    VdpVideoSurface getNextFrame(void **frames);
    VdpPictureInfoH264 parseInfo(const webrtc::EncodedImage& input_image);


    void ParseSlice(const uint8_t* slice, size_t length);
    int ParseNonParameterSetNalu(
    const uint8_t* source,
    size_t source_length,
    uint8_t nalu_type);

    // Prepares decoder to handle incoming encoded frames. Can be called multiple
    // times, in such case only latest `settings` are in effect.
    bool Configure(const Settings& settings) override;

    // TODO(bugs.webrtc.org/15444): Make pure virtual once all subclasses have
    // migrated to implementing this class.
    int32_t Decode(const webrtc::EncodedImage& input_image,
                            int64_t render_time_ms) override;

    int32_t RegisterDecodeCompleteCallback(
        webrtc::DecodedImageCallback* callback) override;

    int32_t Release() override;

    DecoderInfo GetDecoderInfo() const override;

    // Deprecated, use GetDecoderInfo().implementation_name instead.
    const char* ImplementationName() const override;

    VdpDevice vdp_device;
    VdpDecoder vdp_decoder;
    VdpVideoSurface vdp_video_surface;
    VdpOutputSurface vdp_output_surface;
    VdpPresentationQueueTarget queue_target;
    VdpPresentationQueueTarget vdp_target;
    VdpGetProcAddress* vdp_get_proc_address;
    VdpPresentationQueue vdp_queue;
    uint32_t vid_width, vid_height;
    VdpChromaType vdp_chroma_type;

    absl::optional<int32_t> last_slice_qp_delta_;
    absl::optional<webrtc::MySpsParser::MySpsState> sps_;
    absl::optional<webrtc::MyPpsParser::MyPpsState> pps_;

    VdpVideoSurface surfaces[NUMBER_OF_SURFACES];

    VdpVideoMixer vdp_mixer;
    VdpVideoMixerFeature mixer_features[6];
    VdpChromaType chroma;


    webrtc::DecodedImageCallback* callback;
    Display *x11_display;
    vdp_functable* table;
    int x11_screen;

    int width = 640;
    int height = 480;
    VdpReferenceFrameH264 refframes[16];
    webrtc::H264BitstreamParser h264_bitstream_parser_;
};



#include <memory>
#include <vector>

#include "modules/video_coding/codecs/h264/include/h264.h"

namespace webrtc {
// TODO(bugs.webrtc.org/13573): When OpenH264 is no longer a conditional build
//                              target remove #ifdefs.
struct MyH264DecoderTemplateAdapter {
  static std::vector<SdpVideoFormat> SupportedFormats() {
    return SupportedH264DecoderCodecs();
  }

  static std::unique_ptr<VideoDecoder> CreateDecoder(
      const SdpVideoFormat& format) {
    auto a = format.parameters.at("profile-level-id");
    std::stringstream strm(a);

    int num;
    strm >> num;

    std::cout << "LLLLLLL" << num << " " << ~(1<<11) <<  " " << (42 & (~(1<<11))) << " " << format.ToString() << std::endl;
    // & ~AV_PROFILE_H264_INTRA;
    return std::make_unique<MyH264Decoder>(MyH264Decoder());
  }
};
}  // namespace webrtc

#endif



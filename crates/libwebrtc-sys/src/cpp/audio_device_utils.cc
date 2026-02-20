#include "audio_device_utils.h"

#if defined(WEBRTC_WIN)

#include "rtc_base/logging.h"

#include <audioclient.h>
#include <mmdeviceapi.h>
#include <Functiondiscoverykeys_devpkey.h>
#include <propvarutil.h>

#include <third_party/wil/com.h>
#include <third_party/wil/resource.h>
#include <third_party/wil/result.h>

#include <string>

namespace {

// Retrieves the friendly name (`PKEY_Device_FriendlyName`) of the provided `IMMDevice`.
HRESULT GetDeviceFriendlyName(IMMDevice* device, std::string& name_out) {
  RETURN_HR_IF(E_INVALIDARG, device == nullptr);

  wil::com_ptr_nothrow<IPropertyStore> store;
  RETURN_IF_FAILED(device->OpenPropertyStore(STGM_READ, &store));

  wil::unique_prop_variant var;
  RETURN_IF_FAILED(store->GetValue(PKEY_Device_FriendlyName, var.addressof()));

  RETURN_HR_IF(E_FAIL, var.vt != VT_LPWSTR || var.pwszVal == nullptr);

  int wide_len = static_cast<int>(wcslen(var.pwszVal));
  RETURN_HR_IF(E_FAIL, wide_len <= 0);

  int utf8_len = WideCharToMultiByte(
      CP_UTF8, 0,
      var.pwszVal, wide_len,
      nullptr, 0,
      nullptr, nullptr);

  RETURN_HR_IF(E_FAIL, utf8_len <= 0);

  name_out.resize(static_cast<size_t>(utf8_len));

  int written = WideCharToMultiByte(
      CP_UTF8, 0,
      var.pwszVal, wide_len,
      name_out.data(),
      utf8_len,
      nullptr, nullptr);

  RETURN_HR_IF(E_FAIL, written != utf8_len);

  return S_OK;
}

// Finds a WASAPI endpoint by matching its friendly name (`PKEY_Device_FriendlyName`).
HRESULT GetEndpointByName(EDataFlow flow,
                          const std::string& device_name,
                          wil::com_ptr_nothrow<IMMDevice>& device) {
  device.reset();

  wil::com_ptr_nothrow<IMMDeviceEnumerator> enumerator;
  RETURN_IF_FAILED(CoCreateInstance(__uuidof(MMDeviceEnumerator),
                                    nullptr,
                                    CLSCTX_ALL,
                                    IID_PPV_ARGS(&enumerator)));

  wil::com_ptr_nothrow<IMMDeviceCollection> collection;
  RETURN_IF_FAILED(
      enumerator->EnumAudioEndpoints(flow,
                                     DEVICE_STATE_ACTIVE,
                                     &collection));

  UINT count = 0;
  RETURN_IF_FAILED(collection->GetCount(&count));

  for (UINT i = 0; i < count; ++i) {
    wil::com_ptr_nothrow<IMMDevice> candidate;
    RETURN_IF_FAILED(collection->Item(i, &candidate));

    std::string friendly_name;
    HRESULT hr = GetDeviceFriendlyName(candidate.get(), friendly_name);
    if (SUCCEEDED(hr) && friendly_name == device_name) {
      device = std::move(candidate);
      return S_OK;
    }
  }

  return HRESULT_FROM_WIN32(ERROR_NOT_FOUND);
}

// Retrieves the PnP container ID (`PKEY_Device_ContainerId`) of the provided `IMMDevice`.
HRESULT GetContainerIdUtf8Internal(IMMDevice* device,
                                   std::string& container_id) {
  RETURN_HR_IF(E_INVALIDARG, device == nullptr);

  container_id.clear();

  wil::com_ptr_nothrow<IPropertyStore> store;
  RETURN_IF_FAILED(device->OpenPropertyStore(STGM_READ, &store));

  wil::unique_prop_variant var;
  RETURN_IF_FAILED(
      store->GetValue(PKEY_Device_ContainerId, var.addressof()));

  RETURN_HR_IF(E_FAIL,
               var.vt != VT_CLSID || var.puuid == nullptr);

  wil::unique_cotaskmem_string wguid;
  RETURN_IF_FAILED(StringFromCLSID(*var.puuid, &wguid));

  int utf8_len = WideCharToMultiByte(
      CP_UTF8, 0,
      wguid.get(), -1,
      nullptr, 0,
      nullptr, nullptr);

  RETURN_HR_IF(E_FAIL, utf8_len <= 0);

  container_id.resize(static_cast<size_t>(utf8_len - 1));

  WideCharToMultiByte(
      CP_UTF8, 0,
      wguid.get(), -1,
      container_id.data(),
      utf8_len,
      nullptr, nullptr);

  return S_OK;
}

// Populates container_id, sample_rate, and num_channels by finding the
// WASAPI device whose friendly name matches device_name.
HRESULT GetDeviceFormatInternal(EDataFlow flow,
                                const std::string& device_name,
                                DeviceNameWithFormat& out) {
  wil::com_ptr_nothrow<IMMDevice> device;
  RETURN_IF_FAILED(GetEndpointByName(flow, device_name, device));

  HRESULT cid_hr =
      GetContainerIdUtf8Internal(device.get(), out.container_id);
  if (FAILED(cid_hr)) {
    RTC_LOG(LS_ERROR) << "GetContainerIdUtf8Internal failed: hr=0x"
                      << std::hex << cid_hr;
    out.container_id.clear();
  }

  wil::com_ptr_nothrow<IAudioClient> client;
  HRESULT act_hr = device->Activate(__uuidof(IAudioClient),
                                    CLSCTX_ALL,
                                    nullptr,
                                    reinterpret_cast<void**>(client.put()));
  if (FAILED(act_hr)) {
    RTC_LOG(LS_ERROR) << "IAudioClient activation failed: hr=0x"
                      << std::hex << act_hr;
    return S_OK;
  }

  wil::unique_cotaskmem_ptr<WAVEFORMATEX> mix_format;
  HRESULT fmt_hr = client->GetMixFormat(wil::out_param(mix_format));
  if (FAILED(fmt_hr)) {
    RTC_LOG(LS_ERROR) << "GetMixFormat failed: hr=0x" << std::hex << fmt_hr;
    return S_OK;
  }

  // typedef struct tWAVEFORMATEX {
  //   WORD  nChannels;
  //   DWORD nSamplesPerSec;
  //   ...
  // }
  out.sample_rate = static_cast<std::uint32_t>(mix_format->nSamplesPerSec);
  out.num_channels = static_cast<std::uint16_t>(mix_format->nChannels);

  return S_OK;
}

}  // namespace

// Fills format info for a playout device by matching its friendly name.
bool GetPlayoutDeviceFormat(const std::string& device_name,
                            DeviceNameWithFormat& out) {
  HRESULT hr = GetDeviceFormatInternal(eRender, device_name, out);
  if (FAILED(hr)) {
    RTC_LOG(LS_ERROR) << "GetPlayoutDeviceFormat failed: hr=0x"
                      << std::hex << hr;
    return false;
  }
  return true;
}

// Fills format info for a recording device by matching its friendly name.
bool GetRecordingDeviceFormat(const std::string& device_name,
                              DeviceNameWithFormat& out) {
  HRESULT hr = GetDeviceFormatInternal(eCapture, device_name, out);
  if (FAILED(hr)) {
    RTC_LOG(LS_ERROR) << "GetRecordingDeviceFormat failed: hr=0x"
                      << std::hex << hr;
    return false;
  }
  return true;
}

#else  // !WEBRTC_WIN

// TODO: Not implemented on non-Windows platforms.
bool GetPlayoutDeviceFormat(const std::string& device_name,
                            DeviceNameWithFormat& out) {
  return false;
}

// TODO: Not implemented on non-Windows platforms.
bool GetRecordingDeviceFormat(const std::string& device_name,
                              DeviceNameWithFormat& out) {
  return false;
}

#endif  // WEBRTC_WIN

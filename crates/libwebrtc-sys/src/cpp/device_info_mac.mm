#if __APPLE__
#include "device_info_mac.h"

DeviceInfoMac::DeviceInfoMac() : DeviceInfoImpl() {
    this->device =
        [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

int32_t DeviceInfoMac::Init() { return 0; }

DeviceInfoMac::~DeviceInfoMac() {}

uint32_t DeviceInfoMac::NumberOfDevices() {
    AVCaptureDeviceDiscoverySession* devices = [AVCaptureDeviceDiscoverySession
        discoverySessionWithDeviceTypes:@[
            AVCaptureDeviceTypeBuiltInWideAngleCamera,
            AVCaptureDeviceTypeExternalUnknown
        ]
                              mediaType:AVMediaTypeVideo
                               position:AVCaptureDevicePositionUnspecified];
    return [devices.devices count];
}

int32_t DeviceInfoMac::GetDeviceName(
    uint32_t deviceNumber, char* deviceNameUTF8, uint32_t deviceNameLength,
    char* deviceUniqueIdUTF8, uint32_t deviceUniqueIdUTF8Length,
    char* /*productUniqueIdUTF8*/, uint32_t /*productUniqueIdUTF8Length*/) {
    AVCaptureDeviceDiscoverySession* devices = [AVCaptureDeviceDiscoverySession
        discoverySessionWithDeviceTypes:@[
            AVCaptureDeviceTypeBuiltInWideAngleCamera,
            AVCaptureDeviceTypeExternalUnknown
        ]
                              mediaType:AVMediaTypeVideo
                               position:AVCaptureDevicePositionUnspecified];
    AVCaptureDevice* device = devices.devices[deviceNumber];
    deviceNameLength = [device.localizedName length];
    memset(deviceNameUTF8, 0, deviceNameLength);
    strcpy(deviceNameUTF8, [device.localizedName UTF8String]);
    deviceUniqueIdUTF8Length = [device.uniqueID length];
    memset(deviceUniqueIdUTF8, 0, deviceUniqueIdUTF8Length);
    strcpy(deviceUniqueIdUTF8, [device.uniqueID UTF8String]);
    return 0;
}

int32_t DeviceInfoMac::CreateCapabilityMap(const char* /*deviceUniqueIdUTF8*/) {
    return -1;
}

int32_t DeviceInfoMac::DisplayCaptureSettingsDialogBox(
    const char* /*deviceUniqueIdUTF8*/, const char* /*dialogTitleUTF8*/,
    void* /*parentWindow*/, uint32_t /*positionX*/, uint32_t /*positionY*/) {
    return -1;
}

std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo>
create_device_info_mac() {
    std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo> ptr(
        new DeviceInfoMac());

    return ptr;
}
#endif

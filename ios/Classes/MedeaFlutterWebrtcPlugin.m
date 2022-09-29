#import "MedeaFlutterWebrtcPlugin.h"
#include "libyuv.h"
#if __has_include(<medea_flutter_webrtc/medea_flutter_webrtc-Swift.h>)
#import <medea_flutter_webrtc/medea_flutter_webrtc-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "medea_flutter_webrtc-Swift.h"
#endif

@implementation MedeaFlutterWebrtcPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMedeaFlutterWebrtcPlugin registerWithRegistrar:registrar];
}
@end

bool libyuv_I420ToARGB(
	const uint8_t* src_y,
	int src_stride_y,
	const uint8_t* src_u,
	int src_stride_u,
	const uint8_t* src_v,
	int src_stride_v,
	uint8_t* dst_argb,
	int dst_stride_argb,
	int width,
	int height
) {
	return I420ToARGB(
		src_y,
		src_stride_y,
		src_u,
		src_stride_u,
		src_v,
		src_stride_v,
		dst_argb,
		dst_stride_argb,
		width,
		height
	) == 0;
}
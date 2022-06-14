#import "MedeaJasonWebrtcPlugin.h"
#if __has_include(<medea_jason_webrtc/medea_jason_webrtc-Swift.h>)
#import <medea_jason_webrtc/medea_jason_webrtc-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "medea_jason_webrtc-Swift.h"
#endif

@implementation MedeaJasonWebrtcPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMedeaJasonWebrtcPlugin registerWithRegistrar:registrar];
}
@end

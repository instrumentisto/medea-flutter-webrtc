#include "macos_system_audio_module.h"
#include <Cocoa/Cocoa.h>
#include <IOSurface/IOSurface.h>
#include <CoreMedia/CMSampleBuffer.h>
#include <CoreVideo/CVPixelBuffer.h>
#include "rtc_base/logging.h"
#include "mac_screen_capture_delegate.h"
#include <vector>

//@interface ScreenCaptureDelegate : NSObject <SCStreamOutput, SCStreamDelegate>
//
//@end

@implementation ScreenCaptureDelegate
  -(id) init {
    RTC_LOG(LS_ERROR) << "init ScreenCaptureDelegate";
    self = [super init];
    return self;
  }

  - (void)stream:(SCStream *)stream didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(SCStreamOutputType)type
  {
    RTC_LOG(LS_ERROR) << "didOutputSampleBuffer";

    if (self.sc != NULL) {
      if (type == SCStreamOutputTypeScreen && !self.sc->audio_only) {
//        screen_stream_video_update(self.sc, sampleBuffer);
      }
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 130000
      else if (@available(macOS 13.0, *)) {
      if (type == SCStreamOutputTypeAudio) {
//        screen_stream_audio_update(self.sc, sampleBuffer);
      }
    }
#endif
    }
  }

  - (void)stream:(SCStream *)stream didStopWithError:(NSError *)error
  {
    RTC_LOG(LS_ERROR) << "didStopWithError";
    NSString *errorMessage;
    switch (error.code) {
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 130000
      case SCStreamErrorUserStopped:
      errorMessage = @"User stopped stream.";
      break;
#endif
      case SCStreamErrorNoCaptureSource:
        errorMessage = @"Stream stopped as no capture source was not found.";
        break;
      default:
        errorMessage = [NSString stringWithFormat:@"Stream stopped with error %ld (\"%s\")", error.code,
                                                  error.localizedDescription.UTF8String];
        break;
    }

//    MACCAP_LOG(LOG_WARNING, "%s", errorMessage.UTF8String);

    self.sc->capture_failed = true;
//    obs_source_update_properties(self.sc->source);
  }
@end


SystemModule::SystemModule() {
  RTC_LOG(LS_ERROR) << "Init start!";
  screenCaptureDelegate = [[ScreenCaptureDelegate alloc] init];
  screenCaptureDelegate.sc = new screen_capture {};
  RTC_LOG(LS_ERROR) << "Init start 2!";

//  RTC_LOG(LS_ERROR) << "Enumerating devices";
//  typedef void (^shareable_content_callback)(SCShareableContent *, NSError *);
//  shareable_content_callback new_content_received = ^void(SCShareableContent *shareable_content, NSError *error) {
//    NSLog( @"Display: '%@'", shareable_content.displays);
//
//    RTC_LOG(LS_ERROR) << "Received display source";
//    //    if (error == nil && sc->shareable_content_available != NULL) {
//    //      sc->shareable_content = [shareable_content retain];
//    //    } else {
//    //#ifdef DEBUG
//    //      MACCAP_ERR("screen_capture_properties: Failed to get shareable content with error %s\n",
//    //                 [[error localizedFailureReason] cStringUsingEncoding:NSUTF8StringEncoding]);
//    //#endif
//    //      MACCAP_LOG(LOG_WARNING, "Unable to get list of available applications or windows. "
//    //                 "Please check if OBS has necessary screen capture permissions.");
//    //    }
//    //    os_sem_post(sc->shareable_content_available);
//  };

  //  os_sem_wait(sc->shareable_content_available);
  //  [sc->shareable_content release];
  //  BOOL onScreenWindowsOnly = (display_capture) ? NO : !sc->show_hidden_windows;
  [[SCStreamConfiguration alloc] init];
//  [SCShareableContent getShareableContentExcludingDesktopWindows:YES onScreenWindowsOnly:NO
//                                               completionHandler:new_content_received];
  RTC_LOG(LS_ERROR) << "EnumerateSystemSource!";


}

SystemModule::~SystemModule() {

}

bool SystemModule::Init() {
  RTC_LOG(LS_ERROR) << "Init start!";
  auto sc = screenCaptureDelegate.sc;
  std::mutex* mutex = new std::mutex();
  mutex->lock();
  typedef void (^shareable_content_callback)(SCShareableContent *, NSError *);
  shareable_content_callback new_content_received = ^void(SCShareableContent *shareable_content, NSError *error) {
    RTC_LOG(LS_ERROR) << "sc callbackl";
//    if (error == nil && sc->shareable_content_available != NULL) {
      sc->shareable_content = shareable_content;
//      RTC_LOG(LS_ERROR) << "shareable content received: " << [shareable_content.windows count];
//    }
    mutex->unlock();
//    os_sem_post(sc->shareable_content_available);
  };
  [SCShareableContent getShareableContentExcludingDesktopWindows:YES onScreenWindowsOnly:NO
                                               completionHandler:new_content_received];
  mutex->lock();

  SCContentFilter *content_filter;
  RTC_LOG(LS_ERROR) << "Init 2";
  sc->capture_failed;
  RTC_LOG(LS_ERROR) << "Init 3";
  if (sc->capture_failed) {
    sc->capture_failed = false;
//    obs_source_update_properties(sc->source);
  }
  RTC_LOG(LS_ERROR) << "Init @3";
  sc->stream_properties = [[SCStreamConfiguration alloc] init];
//  os_sem_wait(sc->shareable_content_available);

  RTC_LOG(LS_ERROR) << "Init 4";
  SCDisplay * (^get_target_display)(void) = ^SCDisplay *
  {
    RTC_LOG(LS_ERROR) << "Init 5";
    for (SCDisplay *display in sc->shareable_content.displays) {
        RTC_LOG(LS_ERROR) << "RETURNING DISPLAY";
      if (display.displayID == sc->display) {
        return display;
      }
    }
    return nil;
  };
  RTC_LOG(LS_ERROR) << "Init 6";

  switch (sc->audio_capture_type) {
    case ScreenCaptureAudioDesktopStream: {
      SCDisplay *target_display = sc->shareable_content.displays[0];
//      SCDisplay *target_display = get_target_display();

      NSArray *empty = [[NSArray alloc] init];
      RTC_LOG(LS_ERROR) << "INIT WITH DISPLAY 1";
      content_filter = [[SCContentFilter alloc] initWithDisplay:target_display excludingWindows:empty];
      RTC_LOG(LS_ERROR) << "INIT WITH DISPLAY 2";
//      [empty release];
    } break;
    case ScreenCaptureAudioApplicationStream: {
      SCDisplay *target_display = get_target_display();
      SCRunningApplication *target_application = nil;
      for (SCRunningApplication *application in sc->shareable_content.applications) {
        if ([application.bundleIdentifier isEqualToString:sc->application_id]) {
          target_application = application;
          break;
        }
      }
      NSArray *target_application_array = [[NSArray alloc] initWithObjects:target_application, nil];

      NSArray *empty = [[NSArray alloc] init];
      content_filter = [[SCContentFilter alloc] initWithDisplay:target_display
                                          includingApplications:target_application_array
                                               exceptingWindows:empty];
//      [target_application_array release];
//      [empty release];
    } break;
  }

  RTC_LOG(LS_ERROR) << "Init 7";
//  os_sem_post(sc->shareable_content_available);
  [sc->stream_properties setQueueDepth:8];

  [sc->stream_properties setCapturesAudio:TRUE];
  [sc->stream_properties setExcludesCurrentProcessAudio:TRUE];
  RTC_LOG(LS_ERROR) << "Init 8";

//  struct obs_audio_info audio_info;
//  BOOL did_get_audio_info = obs_get_audio_info(&audio_info);
//  if (!did_get_audio_info) {
//    MACCAP_ERR("init_audio_screen_stream: No audio configured, returning %d\n", did_get_audio_info);
//    [content_filter release];
//    return did_get_audio_info;
//  }

  RTC_LOG(LS_ERROR) << "Init 9";
  int channel_count = 2;
  if (channel_count > 1) {
    [sc->stream_properties setChannelCount:2];
  } else {
    [sc->stream_properties setChannelCount:channel_count];
  }
  RTC_LOG(LS_ERROR) << "Init 10";

  sc->disp = [[SCStream alloc] initWithFilter:content_filter configuration:sc->stream_properties
                                     delegate:screenCaptureDelegate];
  RTC_LOG(LS_ERROR) << "Init 11";
//  [content_filter release];

  //add a dummy video stream output to silence errors from SCK. frames are dropped by the delegate
  NSError *error = nil;
  BOOL did_add_output = [sc->disp addStreamOutput:screenCaptureDelegate type:SCStreamOutputTypeScreen
                               sampleHandlerQueue:nil
                                            error:&error];
  RTC_LOG(LS_ERROR) << "Init 12";
  if (!did_add_output) {
    RTC_LOG(LS_ERROR) << "NOT did_add_output";
//    MACCAP_ERR("init_audio_screen_stream: Failed to add video stream output with error %s\n",
//               [[error localizedFailureReason] cStringUsingEncoding:NSUTF8StringEncoding]);
//    [error release];
//    [sc->disp release];
    sc->disp = NULL;
    return !did_add_output;
  }
  RTC_LOG(LS_ERROR) << "Init 13";

  did_add_output = [sc->disp addStreamOutput:screenCaptureDelegate type:SCStreamOutputTypeAudio sampleHandlerQueue:nil
                                       error:&error];
  if (!did_add_output) {
    RTC_LOG(LS_ERROR) << "NOT did_add_output";
//    MACCAP_ERR("init_audio_screen_stream: Failed to add audio stream output with error %s\n",
//               [[error localizedFailureReason] cStringUsingEncoding:NSUTF8StringEncoding]);
//    [error release];
//    [sc->disp release];
    sc->disp = NULL;
    return !did_add_output;
  }

  RTC_LOG(LS_ERROR) << "Init 14";
//  os_event_init(&sc->disp_finished, OS_EVENT_TYPE_MANUAL);
//  os_event_init(&sc->stream_start_completed, OS_EVENT_TYPE_MANUAL);

  __block BOOL did_stream_start = false;

  RTC_LOG(LS_ERROR) << "Init 15";
  RTC_LOG(LS_ERROR) << "starting capturing";
  [sc->disp startCaptureWithCompletionHandler:^(NSError *_Nullable error2) {
    did_stream_start = (BOOL) (error2 == nil);
    if (!did_stream_start) {
      RTC_LOG(LS_ERROR) << "stream is not started!!!   " << [[error2 localizedFailureReason] cStringUsingEncoding:NSUTF8StringEncoding];
////      MACCAP_ERR("init_audio_screen_stream: Failed to start capture with error %s\n",
////                 [[error localizedFailureReason] cStringUsingEncoding:NSUTF8StringEncoding]);
//      // Clean up disp so it isn't stopped
////      [sc->disp release];
//      sc->disp = NULL;
    }
    RTC_LOG(LS_ERROR) << "stream is started!!!";
//    os_event_signal(sc->stream_start_completed);
  }];
  RTC_LOG(LS_ERROR) << "capturing was started";
//  os_event_wait(sc->stream_start_completed);

  return did_stream_start;
//  return false;
}

int32_t SystemModule::Terminate() {
  return 0;
}

rtc::scoped_refptr<AudioSource> SystemModule::CreateSource() {
//  RTC_LOG(LS_ERROR) << "CreateSource 1";
//  auto system_source = new SystemSource(this);
//  RTC_LOG(LS_ERROR) << "CreateSource 2";
//  return rtc::scoped_refptr<SystemSource>(system_source);
}

void SystemModule::ResetSource() {
  RTC_LOG(LS_ERROR) << "ResetSource!";

}

void SystemModule::SetRecordingSource(int id) {
  RTC_LOG(LS_ERROR) << "SetRecordingSource!";

}

void SystemModule::SetSystemAudioLevel(float level) {
  RTC_LOG(LS_ERROR) << "SetSystemAudioLevel!";

}

float SystemModule::GetSystemAudioLevel() const {
  RTC_LOG(LS_ERROR) << "GetSystemAudioLevel!";
  return 0.0;
}

int32_t SystemModule::StopRecording() {
  RTC_LOG(LS_ERROR) << "StopRecording!";
  return 0;
}

int32_t SystemModule::StartRecording() {
  RTC_LOG(LS_ERROR) << "StartRecording!";

  return 0;
}

int32_t SystemModule::RecordingChannels() {
//  RTC_LOG(LS_ERROR) << "RecordingChannels!";
  return 1;
}

std::vector<AudioSourceInfo> SystemModule::EnumerateSystemSource() const {
  typedef void (^shareable_content_callback)(SCShareableContent *, NSError *);
//  std::mutex enumerate_mutex;
  std::mutex* enumerate_mutex = new std::mutex();

//  shareable_content_callback new_content_received = ^void(SCShareableContent *shareable_content, NSError *error) {
////    std::vector<AudioSourceInfo> result;
//    RTC_LOG(LS_ERROR) << "Received display source";
//    for (SCWindow* display in shareable_content.windows) {
//
//      RTC_LOG(LS_ERROR) << "Window with title: " << display.title;
//      //      AudioSourceInfo info(display.displayID, std::to_string(display.displayID), display.displayID);
//      //      result.push_back(info);
//      // Perform operations on 'object'
//    }
////    enumerate_mutex->unlock();
//    //    if (error == nil && sc->shareable_content_available != NULL) {
//    //      sc->shareable_content = [shareable_content retain];
//    //    } else {
//    //#ifdef DEBUG
//    //      MACCAP_ERR("screen_capture_properties: Failed to get shareable content with error %s\n",
//    //                 [[error localizedFailureReason] cStringUsingEncoding:NSUTF8StringEncoding]);
//    //#endif
//    //      MACCAP_LOG(LOG_WARNING, "Unable to get list of available applications or windows. "
//    //                 "Please check if OBS has necessary screen capture permissions.");
//    //    }
//    //    os_sem_post(sc->shareable_content_available);
//  };
//
//  //  os_sem_wait(sc->shareable_content_available);
//  //  [sc->shareable_content release];
//  //  BOOL onScreenWindowsOnly = (display_capture) ? NO : !sc->show_hidden_windows;
////  enumerate_mutex->lock();
//  [SCShareableContent getShareableContentExcludingDesktopWindows:YES onScreenWindowsOnly:NO
//                                               completionHandler:new_content_received];

  std::vector<AudioSourceInfo> result;
  result.push_back(AudioSourceInfo(1, "Hello world", 1));
  return result;





//  shareable_content_callback new_content_received = ^void(SCShareableContent *shareable_content, NSError *error) {
//    std::vector<AudioSourceInfo> result;
//    RTC_LOG(LS_ERROR) << "Received display source";
//    for (SCDisplay* display in shareable_content.windows) {
//      RTC_LOG(LS_ERROR) << "Pushing display source to array";
////      AudioSourceInfo info(display.displayID, std::to_string(display.displayID), display.displayID);
////      result.push_back(info);
//      // Perform operations on 'object'
//    }
//    enumerate_mutex->unlock();
////    if (error == nil && sc->shareable_content_available != NULL) {
////      sc->shareable_content = [shareable_content retain];
////    } else {
////#ifdef DEBUG
////      MACCAP_ERR("screen_capture_properties: Failed to get shareable content with error %s\n",
////                 [[error localizedFailureReason] cStringUsingEncoding:NSUTF8StringEncoding]);
////#endif
////      MACCAP_LOG(LOG_WARNING, "Unable to get list of available applications or windows. "
////                 "Please check if OBS has necessary screen capture permissions.");
////    }
////    os_sem_post(sc->shareable_content_available);
//  };
//
////  os_sem_wait(sc->shareable_content_available);
////  [sc->shareable_content release];
////  BOOL onScreenWindowsOnly = (display_capture) ? NO : !sc->show_hidden_windows;
//  enumerate_mutex->lock();
//  [SCShareableContent getShareableContentExcludingDesktopWindows:YES onScreenWindowsOnly:NO
//                                               completionHandler:new_content_received];
//  enumerate_mutex->lock();
//  RTC_LOG(LS_ERROR) << "EnumerateSystemSource!";
//  delete enumerate_mutex;
//  return result;
////  return {};
}
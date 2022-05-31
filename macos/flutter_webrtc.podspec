#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_webrtc'
  s.version          = '0.2.3'
  s.summary          = 'Flutter WebRTC plugin for macOS.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/cloudwebrtc/flutter-webrtc'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'CloudWebRTC' => 'duanweiwei1982@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = ['Classes/**/*']

  s.public_header_files = 'rust/include/**/*'
  $dir = File.dirname(__FILE__) + "/rust/include"
  s.pod_target_xcconfig = { "HEADER_SEARCH_PATHS" => $dir }
  s.vendored_libraries = 'rust/lib/*.a'
  s.platform = :osx, '12.0'
  s.xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'OTHER_LDFLAGS' => '-lc++ -lObjC -framework CoreServices -framework CoreFoundation -framework AudioUnit -framework AudioToolbox -framework CoreAudio',
    # "HEADER_SEARCH_PATHS" => $dir,
  }

  s.dependency 'FlutterMacOS'
  s.osx.deployment_target = '12.0'
end

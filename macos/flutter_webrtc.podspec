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
  s.homepage         = 'https://github.com/instrumentisto/flutter-webrtc'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Instrumentisto Team' => 'developer@instrumentisto.com' }
  s.source           = { :path => '.' }
  s.source_files     = ['Classes/**/*']

  s.vendored_libraries = 'rust/lib/*.dylib'
  s.platform = :osx, '12.0'
  s.static_framework = true

  s.dependency 'FlutterMacOS'
  s.osx.deployment_target = '12.0'
end

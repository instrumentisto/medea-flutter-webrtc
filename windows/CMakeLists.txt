cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "flutter_webrtc")
project(${PROJECT_NAME} LANGUAGES CXX)

set(CMAKE_C_COMPILER "'C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Community\\VC\\Tools\\MSVC\\14.29.30133\\bin\\HostX64\\x64\\cl.exe'")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /WX /W4")

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "flutter_webrtc_plugin")

add_definitions(-DLIB_WEBRTC_API_DLL)

add_library(${PLUGIN_NAME} SHARED
  "flutter_webrtc_plugin.cc"
  "src/flutter_webrtc.cc"
  "src/flutter_webrtc_base.cc"
  "src/flutter_video_renderer.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/rust/src/flutter_webrtc_native.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/cxx/src/cxx.cc"
)

include_directories(
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
  "${CMAKE_CURRENT_SOURCE_DIR}/rust/include"
  "${CMAKE_CURRENT_SOURCE_DIR}/cxx/include"
  # "${CMAKE_CURRENT_SOURCE_DIR}/../crates/libwebrtc-sys/lib/include"
  # "${CMAKE_CURRENT_SOURCE_DIR}/../crates/libwebrtc-sys/lib/include/third_party/abseil-cpp"
  # "${CMAKE_CURRENT_SOURCE_DIR}/../crates/libwebrtc-sys/lib/include/third_party/libyuv/include"
  )
  
  apply_standard_settings(${PLUGIN_NAME})
  set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
  target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
  target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
  "${CMAKE_CURRENT_SOURCE_DIR}/rust/include"
  "${CMAKE_CURRENT_SOURCE_DIR}/cxx/include"
  # "${CMAKE_CURRENT_SOURCE_DIR}/../crates/libwebrtc-sys/lib/include"
  # "${CMAKE_CURRENT_SOURCE_DIR}/../crates/libwebrtc-sys/lib/include/third_party/abseil-cpp"
  # "${CMAKE_CURRENT_SOURCE_DIR}/../crates/libwebrtc-sys/lib/include/third_party/libyuv/include"
)
target_link_libraries(${PLUGIN_NAME} PRIVATE
  flutter
  flutter_wrapper_plugin
  "${CMAKE_CURRENT_SOURCE_DIR}/rust/lib/flutter_webrtc_native.dll.lib"
)

# List of absolute paths to libraries that should be bundled with the plugin
set(flutter_webrtc_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/rust/lib/flutter_webrtc_native.dll"
  PARENT_SCOPE
)

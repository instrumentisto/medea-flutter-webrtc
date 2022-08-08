# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

# Project-level configuration.
set(PROJECT_NAME "medea_flutter_webrtc")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed.
set(PLUGIN_NAME "medea_flutter_webrtc_plugin")
set(CMAKE_CXX_STANDARD 17)

# Define the plugin library target. Its name must not be changed (see comment
# on PLUGIN_NAME above).
#
# Any new source files that you add to the plugin should be added here.
add_library(${PLUGIN_NAME} SHARED
  "medea_flutter_webrtc_plugin.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/rust/src/flutter_webrtc_native.cc"
)

include_directories(
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
  "${CMAKE_CURRENT_SOURCE_DIR}/rust/include"
)

# Apply a standard set of build settings that are configured in the
# application-level CMakeLists.txt. This can be removed for plugins that want
# full control over build settings.
apply_standard_settings(${PLUGIN_NAME})

# Symbols are hidden by default to reduce the chance of accidental conflicts
# between plugins. This should not be removed; any symbols that should be
# exported should be explicitly exported with the FLUTTER_PLUGIN_EXPORT macro.
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

target_compile_options(${PLUGIN_NAME} PRIVATE /zlazy)

# Source include directories and library dependencies. Add any plugin-specific
# dependencies here.
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")

target_link_libraries(${PLUGIN_NAME} PRIVATE
  flutter
  "${CMAKE_CURRENT_SOURCE_DIR}/rust/lib/libflutter_webrtc_native.so"
  )
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)


set(BUILD_BUNDLE_DIR "${PROJECT_BINARY_DIR}/../../bundle")
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
endif()
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}")
set(WEBRTC_BRIDGE "libflutter_webrtc_native.so")
set(WEBRTC_BRIDGE_BRIDGE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/rust/lib/${WEBRTC_BRIDGE}")

install(FILES "${WEBRTC_BRIDGE_BRIDGE_PATH}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}" COMPONENT Runtime)

target_link_libraries(${PLUGIN_NAME} PRIVATE
  flutter
  "${INSTALL_BUNDLE_LIB_DIR}/${WEBRTC_BRIDGE}"
  )

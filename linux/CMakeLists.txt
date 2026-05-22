cmake_minimum_required(VERSION 3.10)
project(runner)

set(BINARY_NAME "primexkey")
set(APPLICATION_ID "com.primexkey.app")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

# Configure build options
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Debug" CACHE
    STRING "Flutter build mode" FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Profile" "Release"
  )
endif()

# Root filesystem for cross-compilation
if(FLUTTER_TARGET_PLATFORM_SYSROOT)
  set(CMAKE_SYSROOT ${FLUTTER_TARGET_PLATFORM_SYSROOT})
  set(CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT})
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
endif()

# Flutter library
set(FLUTTER_LIBRARY "${EPHEMERAL_DIR}/libflutter_linux_gtk.so")

# Published to parent scope for install step
set(FLUTTER_LIBRARY ${FLUTTER_LIBRARY} PARENT_SCOPE)
set(FLUTTER_ICU_DATA_FILE "${EPHEMERAL_DIR}/icudtl.dat" PARENT_SCOPE)
set(PROJECT_BUILD_DIR "${PROJECT_DIR}/build/" PARENT_SCOPE)
set(AOT_LIBRARY "${EPHEMERAL_DIR}/libapp.so" PARENT_SCOPE)

list(APPEND FLUTTER_LIBRARY_HEADERS
  "flutter_linux/fl_basic_message_channel.h"
  "flutter_linux/fl_binary_codec.h"
  "flutter_linux/fl_binary_messenger.h"
  "flutter_linux/fl_dart_project.h"
  "flutter_linux/fl_engine.h"
  "flutter_linux/fl_json_message_codec.h"
  "flutter_linux/fl_json_method_codec.h"
  "flutter_linux/fl_message_codec.h"
  "flutter_linux/fl_method_call.h"
  "flutter_linux/fl_method_channel.h"
  "flutter_linux/fl_method_codec.h"
  "flutter_linux/fl_plugin_registry.h"
  "flutter_linux/fl_plugin_registrar.h"
  "flutter_linux/fl_standard_message_codec.h"
  "flutter_linux/fl_standard_method_codec.h"
  "flutter_linux/fl_string_codec.h"
  "flutter_linux/fl_view.h"
  "flutter_linux/fl_view_controller.h"
)
list(TRANSFORM FLUTTER_LIBRARY_HEADERS PREPEND "${EPHEMERAL_DIR}/")

add_library(flutter INTERFACE)
target_include_directories(flutter INTERFACE
  "${EPHEMERAL_DIR}"
)
target_link_libraries(flutter INTERFACE "${FLUTTER_LIBRARY}")
target_link_libraries(flutter INTERFACE
  ${CMAKE_CURRENT_SOURCE_DIR}/ephemeral/libflutter_linux_gtk.so
)
set_target_properties(flutter PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${EPHEMERAL_DIR}"
)

# Flutter library dependencies
add_library(flutter_wrapper_plugin STATIC
  "flutter/generated_plugin_registrant.cc"
)
set_target_properties(flutter_wrapper_plugin PROPERTIES
  POSITION_INDEPENDENT_CODE ON)
target_link_libraries(flutter_wrapper_plugin PUBLIC flutter)
target_include_directories(flutter_wrapper_plugin PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/flutter"
)

# Flutter library first-party build rules
add_library(flutter_wrapper_app STATIC
  "flutter/generated_plugins.cc"
)
set_target_properties(flutter_wrapper_app PROPERTIES
  POSITION_INDEPENDENT_CODE ON)
target_link_libraries(flutter_wrapper_app PUBLIC flutter)
target_include_directories(flutter_wrapper_app PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/flutter"
)

# === Runner ===
add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)
apply_standard_settings(${BINARY_NAME})
set_target_properties(${BINARY_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${BINARY_NAME} PRIVATE "APPLICATION_ID=\"${APPLICATION_ID}\"")
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE flutter_wrapper_app)

# === Install ===
install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
  COMPONENT Runtime)

foreach(bundled_library ${RUNTIME_LIBRARY_DIRS})
  install(DIRECTORY "${bundled_library}/"
    DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
endforeach(bundled_library)

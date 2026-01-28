cmake_minimum_required(VERSION 3.10)
project(runner LANGUAGES CXX)

set(BINARY_NAME "yamata_launcher")
set(APPLICATION_ID "com.gregoryc.dev.yamata_launcher")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

# Configure build options.
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Debug" CACHE
    STRING "Flutter build mode" FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Profile" "Release")
endif()

# Compilation settings that should be applied to most targets.
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_14)
  target_compile_options(${TARGET} PRIVATE -Wall -Werror)
  target_compile_options(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:-O3>")
  target_compile_definitions(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:NDEBUG>")
endfunction()

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")

# Flutter library and tool build rules.
add_subdirectory(${FLUTTER_MANAGED_DIR})

# System-level dependencies.
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)

add_definitions(-DAPPLICATION_ID="${APPLICATION_ID}")

# Application build
add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)
apply_standard_settings(${BINARY_NAME})
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)
add_dependencies(${BINARY_NAME} flutter_assemble)

# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
include(flutter/generated_plugins.cmake)

# ---- Flutter bundle install (REQUIRED) ----
set(BUILD_BUNDLE_DIR "${PROJECT_BINARY_DIR}/bundle")
set(BUNDLE_LIB_DIR "${BUILD_BUNDLE_DIR}/lib")
set(BUNDLE_DATA_DIR "${BUILD_BUNDLE_DIR}/data")

# Binary
install(TARGETS ${BINARY_NAME}
  RUNTIME DESTINATION "${BUILD_BUNDLE_DIR}"
)

# Flutter engine
install(FILES "${FLUTTER_LIBRARY}"
  DESTINATION "${BUNDLE_LIB_DIR}"
)

# ICU data
install(FILES "${FLUTTER_ICU_DATA_FILE}"
  DESTINATION "${BUNDLE_DATA_DIR}"
)

# Plugins (.so)
if(PLUGIN_BUNDLED_LIBRARIES)
  install(FILES ${PLUGIN_BUNDLED_LIBRARIES}
    DESTINATION "${BUNDLE_LIB_DIR}"
  )
endif()

# Flutter assets
install(DIRECTORY "${PROJECT_BUILD_DIR}/flutter_assets"
  DESTINATION "${BUNDLE_DATA_DIR}"
)
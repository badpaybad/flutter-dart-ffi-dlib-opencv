cmake_minimum_required(VERSION 3.6.0)
set(PROJECT_NAME "DlibOpencvFfi")
project(${PROJECT_NAME})

message(${PROJECT_NAME})
message(${CMAKE_CURRENT_SOURCE_DIR})

set (ANDROID_ABI x86_64) # ABI=('armeabi-v7a' 'arm64-v8a' 'x86' 'x86_64')

include_directories(/work/flutter-dart-ffi-dlib-opencv/android/app/src/main/cppLibs/dlib/include /work/flutter-dart-ffi-dlib-opencv/android/app/src/main/cppLibs/opencv/include)

add_library(lib_dlib SHARED IMPORTED)
set_target_properties(lib_dlib PROPERTIES IMPORTED_LOCATION  /work/flutter-dart-ffi-dlib-opencv/android/app/src/main/cppLibs/dlib/lib/x86_64/libdlib.so)

add_library(lib_opencv SHARED IMPORTED)
set_target_properties(lib_opencv PROPERTIES IMPORTED_LOCATION /work/flutter-dart-ffi-dlib-opencv/android/app/src/main/cppLibs/opencv/lib/x86_64/libopencv_java4.so)

set(SOURCES
        ../../android/app/src/main/cppLibs/dlib.cpp
        ../../android/app/src/main/cppLibs/opencv.cpp
        )
add_library(${PROJECT_NAME} SHARED ${SOURCES})
target_link_libraries(${PROJECT_NAME} lib_opencv lib_dlib)
#target_link_libraries(${PROJECT_NAME} lib_opencv lib_dlib libjpeg)

#target_compile_options(${PROJECT_NAME} PRIVATE
#        -std=++11 -Wall -Wextra -pedantic -Wmissing-prototypes -Wshadow)
#find_package(JPEG QUIET)
#include_directories(${JPEG_INCLUDE_DIR})
#add_library(${PROJECT_NAME} SHARED ${SOURCES})
#target_link_libraries(${PROJECT_NAME} lib_opencv lib_dlib ${JPEG_LIBRARY})
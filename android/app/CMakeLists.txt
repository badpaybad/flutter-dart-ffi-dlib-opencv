cmake_minimum_required(VERSION 3.6.0)
#set (ANDROID_ABI x86_64) # ABI=('armeabi-v7a' 'arm64-v8a' 'x86' 'x86_64')
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src/main/cppLibs/dlib/include ${CMAKE_CURRENT_SOURCE_DIR}/src/main/cppLibs/opencv/include)

add_library(lib_dlib SHARED IMPORTED)
set_target_properties(lib_dlib PROPERTIES IMPORTED_LOCATION  ${CMAKE_CURRENT_SOURCE_DIR}/src/main/cppLibs/dlib/lib/${ANDROID_ABI}/libdlib.so)

add_library(lib_opencv SHARED IMPORTED)
set_target_properties(lib_opencv PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/cppLibs/opencv/${ANDROID_ABI}/libopencv_java4.so)

set(SOURCES
        ../../lib/interop/dlib.cpp
        ../../lib/interop/opencv.cpp
        )
add_library(DlibOpencvFfi SHARED ${SOURCES})
target_link_libraries(DlibOpencvFfi lib_opencv lib_dlib)
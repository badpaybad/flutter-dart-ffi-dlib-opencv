cmake_minimum_required(VERSION 3.6.0)
set(PROJECT_NAME "DlibOpencvFfi")
project(${PROJECT_NAME})

message(${PROJECT_NAME})
message(${CMAKE_CURRENT_SOURCE_DIR})

#set (ANDROID_ABI x86_64) # ABI=('armeabi-v7a' 'arm64-v8a' 'x86' 'x86_64')

include_directories(dlib/include opencv/include)

add_library(lib_dlib SHARED IMPORTED)
set_target_properties(lib_dlib PROPERTIES IMPORTED_LOCATION  ${CMAKE_CURRENT_SOURCE_DIR}/dlib/lib/${ANDROID_ABI}/libdlib.so)

add_library(lib_opencv SHARED IMPORTED)
set_target_properties(lib_opencv PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/opencv/${ANDROID_ABI}/libopencv_java4.so)

set(SOURCES
        ../../../../../lib/interop/dlib.cpp
        ../../../../../lib/interop/opencv.cpp
        )

#target_compile_options(${PROJECT_NAME} PRIVATE
#        -std=++11 -Wall -Wextra -pedantic -Wmissing-prototypes -Wshadow)

add_library(${PROJECT_NAME} SHARED ${SOURCES})
target_link_libraries(${PROJECT_NAME} lib_opencv lib_dlib)
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
set_target_properties(lib_opencv PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/opencv/lib/${ANDROID_ABI}/libopencv_java4.so)


#set(image_handle_source_files
#        external/libjpeg/jcomapi.cpp
#        external/libjpeg/jdapimin.cpp
#        external/libjpeg/jdapistd.cpp
#        external/libjpeg/jdatasrc.cpp
#        external/libjpeg/jdcoefct.cpp
#        external/libjpeg/jdcolor.cpp
#        external/libjpeg/jddctmgr.cpp
#        external/libjpeg/jdhuff.cpp
#        external/libjpeg/jdinput.cpp
#        external/libjpeg/jdmainct.cpp
#        external/libjpeg/jdmarker.cpp
#        external/libjpeg/jdmaster.cpp
#        external/libjpeg/jdmerge.cpp
#        external/libjpeg/jdphuff.cpp
#        external/libjpeg/jdpostct.cpp
#        external/libjpeg/jdsample.cpp
#        external/libjpeg/jerror.cpp
#        external/libjpeg/jidctflt.cpp
#        external/libjpeg/jidctfst.cpp
#        external/libjpeg/jidctint.cpp
#        external/libjpeg/jidctred.cpp
#        external/libjpeg/jmemmgr.cpp
#        external/libjpeg/jmemnobs.cpp
#        external/libjpeg/jquant1.cpp
#        external/libjpeg/jquant2.cpp
#        external/libjpeg/jutils.cpp
#        external/libjpeg/jcapimin.cpp
#        external/libjpeg/jdatadst.cpp
#        external/libjpeg/jcparam.cpp
#        external/libjpeg/jcapistd.cpp
#        external/libjpeg/jcmarker.cpp
#        external/libjpeg/jcinit.cpp
#        external/libjpeg/jcmaster.cpp
#        external/libjpeg/jcdctmgr.cpp
#        external/libjpeg/jccoefct.cpp
#        external/libjpeg/jccolor.cpp
#        external/libjpeg/jchuff.cpp
#        external/libjpeg/jcmainct.cpp
#        external/libjpeg/jcphuff.cpp
#        external/libjpeg/jcprepct.cpp
#        external/libjpeg/jcsample.cpp
#        external/libjpeg/jfdctint.cpp
#        external/libjpeg/jfdctflt.cpp
#        external/libjpeg/jfdctfst.cpp
#        )
#set(image_handle_source_files ${image_handle_source_files}
#        external/image_loader/jpeg_loader.cpp
#        external/image_saver/save_jpeg.cpp
#        )
#
#add_library(libjpeg SHARED ${image_handle_source_files})

set(SOURCES
        dlib.cpp
        opencv.cpp
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
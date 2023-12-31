#!/bin/bash
# Luca Anzalone
#https://github.com/as1605/opencv_flutter_ffi/blob/main/lib/main.dart
#https://github.com/Luca96/dlib-for-android
# -----------------------------------------------------------------------------
# -- DLIB FOR ANDROID
# -----------------------------------------------------------------------------

# Android project path: REPLACE WITH YOUR PROJECT PATH!
PROJECT_PATH='/work/flutter-dart-ffi-dlib-opencv/android'
# Directory for storing native libraries
#NATIVE_DIR="$PROJECT_PATH/app/src/main/cppLibs"
NATIVE_DIR="/work/flutter-dart-ffi-dlib-opencv/dlibopencvbuild/dlib4android.so"
#NATIVE_DIR="/work/dlib4android.so"
# Dlib library path: REPLACE WITH YOUR DLIB PATH!
DLIB_PATH='/work/flutter-dart-ffi-dlib-opencv/dlibopencvbuild/dlib-19.16'
# OpenCV library path: REPLACE WITH YOUR OPENCV PATH!
OPENCV_PATH='/work/flutter-dart-ffi-dlib-opencv/dlibopencvbuild/opencv-4.0.1-android-sdk/OpenCV-android-sdk/sdk/native'
# Android-cmake path: REPLACE WITH YOUR CMAKE PATH!
AndroidCmake='/home/dunp/Android/Sdk/cmake/3.22.1/bin/cmake'
# Android-ndk path: REPLACE WITH YOUR NDK PATH!
#NDK="${ANDROID_NDK:/home/dunp/Android/Sdk/ndk/26.1.10909125}"
#home 23.1.7779620
ANDROID_NDK="/home/dunp/Android/Sdk/ndk/23.1.7779620"
NDK="/home/dunp/Android/Sdk/ndk/23.1.7779620"
#work
#ANDROID_NDK="/home/dunp/Android/Sdk/ndk/21.0.6113669"
#NDK="/home/dunp/Android/Sdk/ndk/21.0.6113669"
TOOLCHAIN="$NDK/build/cmake/android.toolchain.cmake"
# path to strip tool: REPLACE WITH YOURS, ACCORDING TO OS!!
STRIP_PATH="$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin"

# Supported Android ABI: TAKE ONLY WHAT YOU NEED!
ABI=('armeabi-v7a' 'arm64-v8a' 'x86' 'x86_64')

# Declare the array
declare -A STRIP_TOOLS

STRIP_TOOLS=(
    ['armeabi-v7a']=$STRIP_PATH/arm-linux-androideabi-strip
    ['arm64-v8a']=$STRIP_PATH/aarch64-linux-android-strip
    ['x86']=$STRIP_PATH/x86_64-linux-android-strip
    ['x86_64']=$STRIP_PATH/x86_64-linux-android-strip
)

# Minimum supported sdk: SHOULD BE GREATER THAN 16
MIN_SDK=21

# -----------------------------------------------------------------------------
# -- Dlib setup
# ----------------------------------------------------------------------------- 

function compile_dlib {
	cd $DLIB_PATH
	mkdir 'build'

	echo '=> Compiling Dlib...'

	for abi in "${ABI[@]}"
	do
		echo 
		echo "=> Compiling Dlib for ABI: '$abi'..."

		mkdir "build/$abi"
		cd "build/$abi"

		$AndroidCmake  -DBUILD_SHARED_LIBS=1 \
					  -DANDROID_NDK=$NDK \
					  -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN \
					  -DANDROID_ABI=$abi \
					  -DANDROID_PLATFORM="android-$MIN_SDK" \
					  -DANDROID_TOOLCHAIN=clang \
					  -DANDROID_STL=c++_shared \
					  -DANDROID_CPP_FEATURES=rtti exceptions \
            -DCMAKE_BUILD_TYPE=Release \
					  -DCMAKE_CXX_FLAGS="-std=c++11 -frtti -fexceptions" \
					  -DCMAKE_C_FLAGS=-O3 \
					  -DCMAKE_PREFIX_PATH=../../ \
					  -DDLIB_USE_BLAS=ON \
					  -DDLIB_USE_LAPACK=ON \
					  -DDLIB_JPEG_SUPPORT=ON \
					  -DDLIB_PNG_SUPPORT=ON \
					  ../../
 		
 		echo "=> Generating the 'dlib/libdlib.so' for ABI: '$abi'..."
		$AndroidCmake --build .

		echo "=> Stripping libdlib.so for ABI: '$abi'to reduce lib size..."
		${STRIP_TOOLS[$abi]} --strip-unneeded dlib/libdlib.so

		echo '=> done.'
		cd ../../
	done
}

function dlib_setup {
	echo '=> Making directories for Dlib ...'
	mkdir "$NATIVE_DIR/dlib"
	echo "=> '$NATIVE_DIR/dlib' created."
	mkdir "$NATIVE_DIR/dlib/lib"
	echo "=> '$NATIVE_DIR/dlib/lib' created."
	mkdir "$NATIVE_DIR/dlib/include"
	echo "=> '$NATIVE_DIR/dlib/include' created."
	mkdir "$NATIVE_DIR/dlib/include/dlib"
    echo "=> '$NATIVE_DIR/dlib/include/dlib' created."

	echo "=> Copying Dlib headers..."
	cp -v -r "$DLIB_PATH/dlib" "$NATIVE_DIR/dlib/include/dlib"

	echo "=> Copying 'libdlib.so' for each ABI..."
	for abi in "${ABI[@]}"
	do
		mkdir "$NATIVE_DIR/dlib/lib/$abi"
		cp -v "$DLIB_PATH/build/$abi/dlib/libdlib.so" "$NATIVE_DIR/dlib/lib/$abi"
		echo " > Copied libdlib.so for $abi"
	done
}

# COMMENT TO DISABLE COMPILATION
compile_dlib

# -----------------------------------------------------------------------------
# -- OpenCV
# -----------------------------------------------------------------------------

#https://sourceforge.net/projects/opencvlibrary/files/4.0.1/opencv-4.0.1-android-sdk.zip/download

function opencv_setup {
	mkdir "$NATIVE_DIR/opencv"

	echo "=> Copying 'libopencv_java4.so' for each ABI..."
	for abi in "${ABI[@]}"
	do
		mkdir "$NATIVE_DIR/opencv/$abi"
		cp -v "$OPENCV_PATH/libs/$abi/libopencv_java4.so" "$NATIVE_DIR/opencv/$abi"
		echos " > Copied libopencv_java4.so for $abi"
	done
}

# -----------------------------------------------------------------------------
# -- Project setup
# -----------------------------------------------------------------------------

mkdir $NATIVE_DIR

# COMMENT TO NOT COPY DLIB '.so' FILES
dlib_setup

# COMMENT TO NOT COPY OPENCV '.so' FILES
opencv_setup

echo "=> Project configuration completed."

# -----------------------------------------------------------------------------

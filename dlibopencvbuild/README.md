
# dartffi_dlib_opencv

https://github.com/Luca96/dlib-for-android/tree/master

should down load manual flutter sdk dont use snap

https://dart.dev/get-dart#install-using-apt-get

https://docs.flutter.dev/get-started/install/linux

# /work/flutter-dart-ffi-dlib-opencv/android/app/build.gradle
```

android {
....
...
 buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig signingConfigs.debug
        }
    }
    externalNativeBuild {
        cmake {
            path "CMakeLists.txt"
        }
    }
    defaultConfig {
        externalNativeBuild {
            cmake {
                cppFlags '-frtti -fexceptions -std=c++17'
                arguments "-DANDROID_STL=c++_shared"
            }
        }
    }
}
```

# build .so file

prebuild also in this git at NATIVE_DIR="$PROJECT_PATH/app/src/main/cppLibs" , if want build new version dlib opencv goto bellow

## folder download or git clone
Assume root prj folder: /work/flutter-dart-ffi-dlib-opencv/dlibopencvbuild
```
|--android
|--dlib.19.16  # download from http://dlib.net/files/  extract http://dlib.net/files/dlib-19.16.zip
|----dlib
|----docs
|----...
|--opencv-4.0.1-android-sdk  # https://sourceforge.net/projects/opencvlibrary/files/4.0.1/opencv-4.0.1-android-sdk.zip/download
|----OpenCV-android-sdk # https://docs.opencv.org/4.x/da/d2a/tutorial_O4A_SDK.html
|------apk
|------sdk
|------....
```
## goto setupdlibopencv.sh change value to your folder


```

# Android project path: REPLACE WITH YOUR PROJECT PATH!
PROJECT_PATH='/work/flutter-dart-ffi-dlib-opencv/android'
# Directory for storing native libraries
NATIVE_DIR="$PROJECT_PATH/app/src/main/cppLibs"
#NATIVE_DIR="/work/dlib4android.so"
# Dlib library path: REPLACE WITH YOUR DLIB PATH!
DLIB_PATH='/work/flutter-dart-ffi-dlib-opencv/dlib.19.16'
# OpenCV library path: REPLACE WITH YOUR OPENCV PATH!
OPENCV_PATH='/work/flutter-dart-ffi-dlib-opencv/opencv-4.0.1-android-sdk/OpenCV-android-sdk/sdk/native'
# Android-cmake path: REPLACE WITH YOUR CMAKE PATH!
AndroidCmake='/home/dunp/Android/Sdk/cmake/3.22.1/bin/cmake'
# Android-ndk path: REPLACE WITH YOUR NDK PATH!
#NDK="${ANDROID_NDK:/home/dunp/Android/Sdk/ndk/26.1.10909125}"
ANDROID_NDK="/home/dunp/Android/Sdk/ndk/21.0.6113669"
NDK="/home/dunp/Android/Sdk/ndk/21.0.6113669"
TOOLCHAIN="$NDK/build/cmake/android.toolchain.cmake"
# path to strip tool: REPLACE WITH YOURS, ACCORDING TO OS!!
STRIP_PATH="$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin"

```

complete will copy to NATIVE_DIR="$PROJECT_PATH/app/src/main/cppLibs"

                sudo chmod 777 setupdlibopencv.sh 
                ./setupdlibopencv.sh

result will NATIVE_DIR="$PROJECT_PATH/app/src/main/cppLibs"

```
.../app/src/main/cppLibs/
|--dlib
|----include # c file
|----lib # .so files
|--opencv
|----arm64-v8a
|----...

```

# .../android/app/CMakeLists.txt
import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io' show Platform, Directory;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

import 'package:path/path.dart' as path;

class DynamicLibLoader{

  static DynamicLibLoader instance=DynamicLibLoader._();

  DynamicLibLoader._(){
    try {
      dylib_load();
    }catch(ex){
      print("Can not load .so file, you may want call dylib_set");
    }
  }

  ffi.DynamicLibrary get dylib_dlib_opencv => dylib_load();
  ffi.DynamicLibrary? _dylib_dlib_opencv;

  void dylib_set(String so_file_path){
    print("ffi.DynamicLibrary file: $so_file_path");
    _dylib_dlib_opencv = ffi.DynamicLibrary.open(so_file_path);
  }

  ffi.DynamicLibrary dylib_load() {
    if (_dylib_dlib_opencv != null) return _dylib_dlib_opencv!;
    //
    // var libraryPath = path.join(dirInterop, 'dunpserialport', 'libserialport.so');
    //
    // if (Platform.isMacOS) {
    //   libraryPath =
    //       path.join(dirInterop, 'dunpserialport', 'libserialport.dylib');
    // } else if (Platform.isWindows) {
    //   libraryPath =
    //       path.join(dirInterop, 'dunpserialport', 'Debug', 'libserialport.dll');
    // } else if (Platform.isLinux) {
    //   libraryPath = path.join(dirInterop, 'dunpserialport', 'libserialport.so');
    // } else {
    //   //flutter, android
    //   libraryPath = "soFilePath";
    // }

      var libraryPath = "libDlibOpencvFfi.so";
      print("ffi.DynamicLibrary file: $libraryPath");
      _dylib_dlib_opencv = ffi.DynamicLibrary.open(libraryPath);

    return _dylib_dlib_opencv!;
  }

}

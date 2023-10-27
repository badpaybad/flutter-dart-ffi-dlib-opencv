import 'dart:async';
import 'dart:convert';
import 'dart:ffi' ;
import 'dart:io' show Platform, Directory;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

import 'package:path/path.dart' as path;

import 'dylibloader.dart' as DyLibLoader;


final dylib = DyLibLoader.dylib_dlib_opencv;

typedef FfiVoidFunc = Void Function(Pointer<Utf8> text);

typedef DartVoidFunc = void Function(Pointer<Utf8> text);

typedef FfiStringFunc = Pointer<Utf8> Function(Pointer<Utf8> text);

typedef DartStringFunc = Pointer<Utf8> Function(Pointer<Utf8> text);

Future<void> detect_face_load_model(DynamicLibrary dylib,
    String file_path_mmod_human_face_detector_dat) async {
  print("detect_face_load_model:begin");
  DartVoidFunc dunp_func = dylib
      .lookup<NativeFunction<FfiVoidFunc>>('detect_face_load_model')
      .asFunction();
  var filemodel = file_path_mmod_human_face_detector_dat.toNativeUtf8();
  dunp_func(filemodel);
  calloc.free(filemodel);
  print("detect_face_load_model:end");
}

Future<void> detect_face(DynamicLibrary dylib, String file_path_img) async {
  DartStringFunc dunp_func = dylib
      .lookup<NativeFunction<FfiStringFunc>>('detect_face')
      .asFunction();

  var fileimg = file_path_img.toNativeUtf8();
  var obj = dunp_func(fileimg);
  calloc.free(fileimg);
  print("detect_face ${obj.toDartString()}");
}

Future<void> detect_face_cpu(
    DynamicLibrary dylib, String file_path_img) async {
  DartStringFunc dunp_func = dylib
      .lookup<NativeFunction<FfiStringFunc>>('detect_face_cpu')
      .asFunction();

  var fileimg = file_path_img.toNativeUtf8();
  var obj = dunp_func(fileimg);
  calloc.free(fileimg);

  print("detect_face ${obj.toDartString()}");
  var rawData = obj.cast<Uint8>();
  //print('Raw Data: ${rawData.asTypedList(rawData.elementAt(0).value)}');

  // String decodedCode = utf8.decode(rawData.asTypedList(rawData.elementAt(0).value), allowMalformed: true);
  // print("decodedCode: $decodedCode");
  // var utf8xxx= Uint8List.fromList(rawData.asTypedList(rawData.elementAt(0).value));
  // print(utf8.decode(utf8xxx));
  //print('Raw Data: ${utf8.decode(rawData.asTypedList(rawData.elementAt(0).value))}');

  //calloc.free(obj);
}

Future<void> test_string(   DynamicLibrary dylib) async{
  DartStringFunc dunp_func = dylib
      .lookup<NativeFunction<FfiStringFunc>>('test_string')
      .asFunction();
  var input="dunp test".toNativeUtf8();
  print("detect_face ${dunp_func(input).toDartString()}");
}
import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io' show Platform, Directory;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

import 'package:path/path.dart' as path;

import 'dylibloader.dart' as DyLibLoader;

final dylib = DyLibLoader.DynamicLibLoader.instance.dylib_dlib_opencv;

typedef FfiVoidFunc = Void Function(Pointer<Utf8> text);

typedef DartVoidFunc = void Function(Pointer<Utf8> text);

typedef FfiStringFunc = Pointer<Utf8> Function(Pointer<Utf8> text);

typedef DartStringFunc = Pointer<Utf8> Function(Pointer<Utf8> text);

//

typedef Get2DLongArrayFunction = Pointer<Pointer<Int64>> Function(
    Pointer<Utf8> text, Int32 pyramid_up);
typedef Get2DLongArray = Pointer<Pointer<Int64>> Function(
    Pointer<Utf8> text, int pyramid_up);

Future<void> detect_face_load_model(
    DynamicLibrary dylib, String file_path_mmod_human_face_detector_dat) async {
  print("detect_face_load_model:begin");
  DartVoidFunc dunp_func = dylib
      .lookup<NativeFunction<FfiVoidFunc>>('detect_face_load_model')
      .asFunction();
  var filemodel = file_path_mmod_human_face_detector_dat.toNativeUtf8();
  dunp_func(filemodel);
  calloc.free(filemodel);
  print("detect_face_load_model:end");
}

Future<List<BBox>> detect_face(DynamicLibrary dylib, String file_path_img,
    {int pyramid_up = 0}) async {
  var t1 = DateTime.now().millisecondsSinceEpoch;

  Get2DLongArray dunp_func = dylib
      .lookup<NativeFunction<Get2DLongArrayFunction>>('detect_face')
      .asFunction();

  var fileimg = file_path_img.toNativeUtf8();
  var objFromCPP = dunp_func(fileimg, pyramid_up);
  calloc.free(fileimg);

  var facefound = await _parseFromNative(objFromCPP);

  calloc.free(objFromCPP);
  var t2 = DateTime.now().millisecondsSinceEpoch;

  print("detect_face_cpu CNN in ${t2 - t1} miliseconds");

  return facefound;
}

/**
 * Return list of bbox to crop face from image base on x,y,w,h
 */
Future<List<BBox>> detect_face_cpu(DynamicLibrary dylib, String file_path_img,
    {int pyramid_up = 0}) async {
  var t1 = DateTime.now().millisecondsSinceEpoch;

  Get2DLongArray dunp_func = dylib
      .lookup<NativeFunction<Get2DLongArrayFunction>>('detect_face_cpu')
      .asFunction();

  var fileimg = file_path_img.toNativeUtf8();
  var objFromCPP = dunp_func(fileimg, pyramid_up);
  calloc.free(fileimg);

  var t2 = DateTime.now().millisecondsSinceEpoch;

  print("detect_face_cpu in ${t2 - t1} miliseconds");
  var facefound = await _parseFromNative(objFromCPP);
  calloc.free(objFromCPP);
  return facefound;
  //print("detect_face ${obj.toDartString()}");
  //var rawData = obj.cast<Uint8>();
  //print('Raw Data: ${rawData.asTypedList(rawData.elementAt(0).value)}');

  // String decodedCode = utf8.decode(rawData.asTypedList(rawData.elementAt(0).value), allowMalformed: true);
  // print("decodedCode: $decodedCode");
  // var utf8xxx= Uint8List.fromList(rawData.asTypedList(rawData.elementAt(0).value));
  // print(utf8.decode(utf8xxx));
  //print('Raw Data: ${utf8.decode(rawData.asTypedList(rawData.elementAt(0).value))}');

  //calloc.free(obj);
}

Future<List<BBox>> _parseFromNative(Pointer<Pointer<Int64>> pointers) async {
  List<BBox> facefound = [];
  int numrows = pointers[0][0];
  int numcols = pointers[0][1];
  int imgw = pointers[0][2];
  int imgh = pointers[0][2];

  for (var i = 1; i < numrows; i++) {
    if (pointers[i] == nullptr) continue;
    final row = BBox();
    row.x = pointers[i][0];
    row.y = pointers[i][1];
    row.w = pointers[i][2];
    row.h = pointers[i][3];
    row.imgw = imgw;
    row.imgh = imgh;
    facefound.add(row);
  }

  return facefound;
}

Future<void> test_string(DynamicLibrary dylib) async {
  DartStringFunc dunp_func = dylib
      .lookup<NativeFunction<FfiStringFunc>>('test_string_paramUTF8_returnUTF8')
      .asFunction();
  var input = "dunp test".toNativeUtf8();
  print("detect_face ${dunp_func(input).toDartString()}");
}

class BBox {
  int x = 0;
  int y = 0;
  int w = -1;
  int h = -1;
  int imgw = 0;
  int imgh = 0;

  @override
  String toString() {
    return '{"x":$x,"y":$y,"w":$w,"h":$h,"imgw":$imgw,"imgh":$imgh}';
  }
}

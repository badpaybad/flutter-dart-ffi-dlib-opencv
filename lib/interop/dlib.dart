import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io' show Platform, Directory;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

import 'package:image/image.dart' as DartImg;

import 'package:path/path.dart' as path;

import 'dylibloader.dart' as DyLibLoader;

final dylib = DyLibLoader.DynamicLibLoader.instance.dylib_dlib_opencv;

typedef FfiVoidFunc = Void Function(Pointer<Utf8> text);

typedef DartVoidFunc = void Function(Pointer<Utf8> text);
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

typedef FfiStringFunc = Pointer<Utf8> Function(Pointer<Utf8> text);

typedef DartStringFunc = Pointer<Utf8> Function(Pointer<Utf8> text);

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
  int imgh = pointers[0][3];

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

Future<List<dynamic>> convertJpeg2Bmp(Uint8List jpegData) async {
  final DartImg.Image? image = DartImg.decodeImage(jpegData);
  var contentIntList = DartImg.encodeBmp(image!)  ;
  var xxx= DartImg.decodeBmp(contentIntList)!.data!.buffer!.asUint8List();
  return [contentIntList, image!.width, image!.height];
  var contentSize = xxx.length;
  int RGBA32HeaderSize = 122;
  var fileLength = contentSize + RGBA32HeaderSize;
  var headerIntList = Uint8List(fileLength);

  final ByteData bd = headerIntList.buffer.asByteData();
  bd.setUint8(0x0, 0x42);
  bd.setUint8(0x1, 0x4d);
  bd.setInt32(0x2, fileLength, Endian.little);
  bd.setInt32(0xa, RGBA32HeaderSize, Endian.little);
  bd.setUint32(0xe, 108, Endian.little);
  bd.setUint32(0x12, image!.width, Endian.little);
  bd.setUint32(0x16, -image!.height, Endian.little);
  bd.setUint16(0x1a, 1, Endian.little);
  bd.setUint32(0x1c, 32, Endian.little); // pixel size
  bd.setUint32(0x1e, 3, Endian.little); //BI_BITFIELDS
  bd.setUint32(0x22, contentSize, Endian.little);
  bd.setUint32(0x36, 0x000000ff, Endian.little);
  bd.setUint32(0x3a, 0x0000ff00, Endian.little);
  bd.setUint32(0x3e, 0x00ff0000, Endian.little);
  bd.setUint32(0x42, 0xff000000, Endian.little);

  headerIntList.setRange(
    RGBA32HeaderSize,
    fileLength,
    contentIntList,
  );

  return [headerIntList, image!.width, image!.height];
}

typedef process_func = Pointer<Pointer<Int64>> Function(
    Pointer<Uint8> bytes, Int32 size, Int32 width, Int32 height);
typedef ProcessFunc = Pointer<Pointer<Int64>> Function(
    Pointer<Uint8> bytes, int size, int width, int height);

Future<List<BBox>> detect_face_from_bmp_array(
    DynamicLibrary dylib, Uint8List data, int width, int height) async {
  ProcessFunc dunp_func = dylib
      .lookup<NativeFunction<process_func>>('detect_face_from_bmp_array')
      .asFunction();

  final pointerData = calloc<Uint8>(sizeOf<Uint8>() * data.length);
  for (var i = 0; i < data.length; i++) {
    pointerData[i] = data[i];
  }
  var objFromCPP = dunp_func(pointerData, data.length, width, height);
  var facefound = await _parseFromNative(objFromCPP);
  calloc.free(objFromCPP);
  calloc.free(pointerData);

  return facefound;
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

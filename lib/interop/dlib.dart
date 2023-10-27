import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
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

//

typedef Get2DLongArrayFunction = Pointer<Pointer<Int64>> Function(
    Pointer<Utf8> text);
typedef Get2DLongArray = Pointer<Pointer<Int64>> Function(Pointer<Utf8> text);


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

// Future<void> detect_face(DynamicLibrary dylib, String file_path_img) async {
//   DartStringFunc dunp_func =
//       dylib.lookup<NativeFunction<FfiStringFunc>>('detect_face').asFunction();
//
//   var fileimg = file_path_img.toNativeUtf8();
//   var obj = dunp_func(fileimg);
//   calloc.free(fileimg);
//   print("detect_face ${obj.toDartString()}");
// }
/**
 * Return list of bbox to crop face from image base on x,y,w,h
 */
Future<List<BBox>> detect_face_cpu(
    DynamicLibrary dylib, String file_path_img) async {
  Get2DLongArray dunp_func = dylib
      .lookup<NativeFunction<Get2DLongArrayFunction>>('detect_face_cpu')
      .asFunction();

  var fileimg = file_path_img.toNativeUtf8();
  var objFromCPP = dunp_func(fileimg);
  calloc.free(fileimg);

  List<BBox> facefound = [];
  int numrows= objFromCPP[0][0];
  int numcols= objFromCPP[0][1];

  for (var i = 1;i<numrows; i++) {
    if( objFromCPP[i] == nullptr) continue;
    final row = BBox();
    row.x=objFromCPP[i][0];
    row.y=objFromCPP[i][1];
    row.w=objFromCPP[i][2];
    row.h=objFromCPP[i][3];
    facefound.add(row);
  }
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

Future<void> test_string(DynamicLibrary dylib) async {
  DartStringFunc dunp_func = dylib
      .lookup<NativeFunction<FfiStringFunc>>('test_string_paramUTF8_returnUTF8')
      .asFunction();
  var input = "dunp test".toNativeUtf8();
  print("detect_face ${dunp_func(input).toDartString()}");
}


class BBox{
  int x=0;
  int y=0;
  int w=-1;
  int h=-1;

  @override
  String toString(){
    return '{"x": $x, "y": $y, "w": $w, "h": $h}';
  }

}
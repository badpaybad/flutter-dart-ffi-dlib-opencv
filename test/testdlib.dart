import '../lib/interop/dlib.dart';
import '../lib/interop/dylibloader.dart';

void main() async {
  DynamicLibLoader.instance.dylib_set(
      "/work/flutter-dart-ffi-dlib-opencv/test/build4pc/build/libDlibOpencvFfi.so");
  var facefounds_gpu = await detect_face(
      DynamicLibLoader.instance.dylib_dlib_opencv,
      "/work/flutter-dart-ffi-dlib-opencv/assets/weights/dunp.jpg");
  print("-------1 => $facefounds_gpu bbox shold be x:582,y:496,w:771,h:771");
}

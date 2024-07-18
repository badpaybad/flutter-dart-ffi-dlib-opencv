import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as DartImage;

import 'package:flutter/services.dart' show rootBundle;

class tflitepredict {
  List _preprocessImage(DartImage.Image image) {
    // Convert the image to a float32 list and normalize the pixel values
    var input = List.generate(
        1,
        (_) => List.generate(
            3, (_) => List.generate(112, (_) => List.filled(112, 0.0))));

    for (int y = 0; y < 112; y++) {
      for (int x = 0; x < 112; x++) {
        var pixel = image.getPixel(x, y);
        input[0][0][y][x] = DartImage.getRed(pixel) / 255.0;
        input[0][1][y][x] = DartImage.getGreen(pixel) / 255.0;
        input[0][2][y][x] = DartImage.getBlue(pixel) / 255.0;
      }
    }

    return input;
  }

  List _preprocessImage_112_112(DartImage.Image image) {
    // Convert the image to a float32 list and normalize the pixel values
    var input = List.generate(
        1,
        (_) => List.generate(
            3, (_) => List.generate(112, (_) => List.filled(112, 0.0))));

    for (int y = 0; y < 112; y++) {
      for (int x = 0; x < 112; x++) {
        var pixel = image.getPixel(x, y);
        input[0][0][y][x] = DartImage.getRed(pixel) / 255.0;
        input[0][1][y][x] = DartImage.getGreen(pixel) / 255.0;
        input[0][2][y][x] = DartImage.getBlue(pixel) / 255.0;
      }
    }

    return input;
  }

  List _preprocessImage_1_256_256_3(DartImage.Image image) {
    //Input Shape: [  1 256 256   3]
    // Convert the image to a float32 list and normalize the pixel values
    List<List<List<List<double>>>> input = List.generate(
      1,
      (_) => List.generate(
        256,
        (_) => List.generate(
          256,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );

    for (int y = 0; y < 256; y++) {
      for (int x = 0; x < 256; x++) {
        var pixel = image.getPixel(x, y);
        input[0][y][x][0] = DartImage.getRed(pixel) / 255.0;
        input[0][y][x][1] = DartImage.getGreen(pixel) / 255.0;
        input[0][y][x][2] = DartImage.getBlue(pixel) / 255.0;
      }
    }

    return input;
  }

  Future<dynamic> chunom_detection() async {
    var modelfileasset = "assets/chunom_model.tflite";
    var interpreter = await Interpreter.fromAsset(modelfileasset);
    var imageInput = DartImage.decodeImage(
        (await rootBundle.load('assets/chunom_test.jpg'))
            .buffer
            .asUint8List())!;
    var resizedImage =
        DartImage.copyResize(imageInput, width: 256, height: 256);
    List input = _preprocessImage_1_256_256_3(resizedImage);
    var output0 = List.generate(
      1,
      (_) => List.generate(
        12276,
        (_) => List.filled(4, 0.0),
      ),
    );
    var output1 = List<double>.filled(1 * 12276 * 2, 0).reshape([1, 12276, 2]);
    interpreter.runForMultipleInputs([input], {0: output0, 1: output1});
    print(
        'Model run successfully with output [[[x,y,w,h],...]: $output0');
//1 12276 4 : [[[x,y,w,h],...]]
     return output0;
  }

  void getfacevector() {
    var modelfileasset = "updated_resnet100.tflite";
    Interpreter.fromAsset(modelfileasset).then((value) async {
      print("Interpreter-----1");
      var _interpreter = value;
      var bytes = await rootBundle.load('assets/dunp1.png');
      print("Interpreter-----2");
      var imageInput = DartImage.decodeImage(bytes.buffer.asUint8List())!;
      var resizedImage =
          DartImage.copyResize(imageInput, width: 112, height: 112);
      print("Interpreter-----3");
      List input = _preprocessImage(resizedImage);
      var output = List<double>.filled(512, 0).reshape([1, 512]);
      print("Interpreter-----4");
      _interpreter!.run(input, output);
      print("Interpreter-----5");
      List<double> faceVector = output[0];
      print("Interpreter-----6");
      print({faceVector: faceVector});
    });
  }
}

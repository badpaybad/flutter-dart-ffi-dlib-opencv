
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as DartImage;

import 'package:flutter/services.dart' show rootBundle;
class tflitepredict{

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

  void getfacevector() {
    var modelfileasset="updated_resnet100.tflite";
    Interpreter.fromAsset(modelfileasset)
        .then((value) async {
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
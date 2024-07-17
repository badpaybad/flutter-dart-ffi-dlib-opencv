import 'dart:io';

import 'package:flutter/material.dart';
import 'interop/dlib.dart' as DlibFfi;
import 'interop/dlib.dart';
import 'interop/opencv.dart' as OpenCv;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:image/image.dart' as DartImg;

void permissionsRequest() {
  if (!Platform.isLinux && !Platform.isMacOS && !Platform.isWindows) {
    [
      Permission.accessMediaLocation,
      Permission.camera,
      Permission.audio,
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.ignoreBatteryOptimizations,
      //Permission.accessNotificationPolicy,
      Permission.notification,
      Permission.mediaLibrary,
      Permission.microphone,
      Permission.manageExternalStorage,
      Permission.storage,
      //add more permission to request here.
    ].request().then((statuses) async {
      String temp = "";
      for (var pk in statuses.keys) {
        temp = "$temp\r\n$pk: ${statuses[pk]}";
      }
    });
  }
}

Future<String> dirApp() async {
  print("dirToSaveOfflineFile");
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  print("APP temp dir: $tempPath");
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  print("APP doc dir: $appDocPath");

  return "/${trim(appDocPath, "/")}";
}

String trim(String src, String char) {
  String pattern = r'^[' + char + r']+|[' + char + r']+$';

  RegExp regex = RegExp(pattern);
  String trimmedStr = src.replaceAll(regex, '');

  return trimmedStr;
}

Future<void> copyAssetToFile(String assetPath, String pathFileName) async {
  try {
    // Get the directory for storing files
    // Directory appDocDir = await getApplicationDocumentsDirectory();
    // String destPath = '${appDocDir.path}/$fileName';
    //
    // // Check if the file already exists
    // File destFile = File(destPath);
    // if (await destFile.exists()) {
    //   // File already exists, you can handle this case accordingly
    //   return;
    // }

    // Load the asset
    ByteData data = await rootBundle.load(assetPath);

    // Write the asset data to the file
    List<int> bytes = data.buffer.asUint8List();
    await File(pathFileName).writeAsBytes(bytes);
  } catch (e) {
    print('Error copying asset: $e');
  }
}

Future<String> get_file_path_mmod_human_face_detector_dat() async {
  var dir = await dirApp();

  await copyAssetToFile("assets/weights/mmod_human_face_detector.dat",
      "$dir/mmod_human_face_detector.dat");

  await copyAssetToFile("assets/weights/dunp.jpg", "$dir/dunp.jpg");

  return "$dir/mmod_human_face_detector.dat";
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  permissionsRequest();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  String appDir = "";

  String _fileSample = "";
  String _logsText = "Press button pluss";

  List<Widget> _bboxes = [];
  Widget? _stackImageAndBoxes = null;

  @override
  void initState() {
    super.initState();

    _init_Poc_Code() async {
      print(DlibFfi.dylib);
      print(OpenCv.dylib);
      var dir = await dirApp();
      appDir = dir;
      var fileimg = "$dir/dunp.jpg";
      _fileSample = fileimg;
      var filemodel = await get_file_path_mmod_human_face_detector_dat();
      await DlibFfi.detect_face_load_model(DlibFfi.dylib, filemodel);
      print("-------");
      print(filemodel);
      print(fileimg);

      _detectAndDrawBBox();
    }

    _init_Poc_Code();
  }

  Uint8List? _bmpImagge;

  Future<List<BBox>> detectFaceByCpu() async {
    var facefounds = await DlibFfi.detect_face_cpu(DlibFfi.dylib, _fileSample);
    print(
        "-------1 => $facefounds bbox shold be similar x:582,y:496,w:771,h:771");
    //
    return facefounds;
  }

  Future<List<BBox>> detectFaceByCNN() async {
    var facefounds_gpu = await DlibFfi.detect_face(DlibFfi.dylib, _fileSample);
    print(
        "-------1 => $facefounds_gpu bbox shold be similar x:582,y:496,w:771,h:771");
    return facefounds_gpu;
  }

  Future<void> _btnPlussOnClick() async {
    _detectAndDrawBBox();
  }

  Future<void> _detectAndDrawBBox() async {
    while (sizeScreen == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    var f1 = detectFaceByCpu();
    var f2 = detectFaceByCNN();

    var res = await Future.wait([f1, f2]);

    // var t1 = DateTime.now().millisecondsSinceEpoch;
    // var rrbmp =
    //     await DlibFfi.convertJpeg2Bmp(await File(_fileSample).readAsBytes());
    // var t2 = DateTime.now().millisecondsSinceEpoch;
    //  var f3Found = await DlibFfi.detect_face_from_bmp_array(
    //      DlibFfi.dylib, rrbmp[0], rrbmp[1], rrbmp[2]);
    // var t3 = DateTime.now().millisecondsSinceEpoch;
    // _bmpImagge= rrbmp[0];
    //
    // if(mounted)  setState(() {
    //
    // });
    //
    // print("convert jpeg2bmp in ${t2 - t1} call face by array ${t3 - t2} found ");

    var cpufound = res[0];
    var gpufoud = res[1];
    _bboxes = [];
    cpufound.addAll(gpufoud);
    if (cpufound.isEmpty) {
      _logsText = "No found any face";
      if (mounted) setState(() {});
      return;
    }
    int imgw = cpufound.first.imgw;
    int imgh = cpufound.first.imgh;

    if(imgw==0 || imgh==0){

      var imgxxx=await DartImg.decodeJpg(File(_fileSample).readAsBytesSync().toList());
      imgw=imgxxx!.width;
      imgh=imgxxx!.height;
    }

    double ratio = imgh / imgw;
    var sizeW = sizeScreen!.width;
    var sizeH = sizeScreen!.width * ratio;
    var rw = sizeW / imgw;
    var rh = sizeH / imgh;
    for (var b in cpufound) {
      Container cb = Container(
        width: b.w * rw,
        height: b.h * rh,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 1),
            color: Colors.transparent),
        child: Text("HOG: $b"),
      );
      var bp = Positioned(
        top: b.x * rw,
        left: b.y * rh,
        width: b.w * rw,
        height: b.h * rh,
        child: cb,
      );
      _bboxes.add(bp);
    }
    for (var b in gpufoud) {
      Container cb = Container(
        width: b.w * rw,
        height: b.h * rh,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.green, width: 1),
            color: Colors.transparent),
        child: Text("CNN: $b"),
      );
      var bp = Positioned(
        top: b.x * rw,
        left: b.y * rh,
        width: b.w * rw,
        height: b.h * rh,
        child: cb,
      );
      _bboxes.add(bp);
    }

    var stak = Stack(
      children: [
        Positioned(
            left: 0,
            top: 0,
            width: sizeW,
            height: sizeH,
            child: Image.file(
              File(_fileSample),
              width: sizeW,
              height: sizeH,
            )),
        ..._bboxes
      ],
    );

    _stackImageAndBoxes = SizedBox(
      width: sizeW,
      height: sizeH,
      child: stak,
    );

    _logsText = "Done: Do again Press button pluss";
    setState(() {
      _counter++;
    });
  }

  Size? sizeScreen;

  @override
  Widget build(BuildContext context) {
    sizeScreen = MediaQuery.of(context).size;

    print("sizeScreen: $sizeScreen");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: _stackImageAndBoxes == null
                    ? Text("Waiting init PoC code")
                    : _stackImageAndBoxes!),
            //Expanded(child: _bmpImagge==null?Text(""):Image.memory(_bmpImagge!)),
            Text(
              _logsText,
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _btnPlussOnClick,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

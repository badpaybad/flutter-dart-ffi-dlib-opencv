import 'dart:io';

import 'package:flutter/material.dart';
import 'interop/dlib.dart' as DlibFfi;
import 'interop/opencv.dart' as OpenCv;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

  _initModel() async {
    print(DlibFfi.dylib);
    print(OpenCv.dylib);
    var dir = await dirApp();
    var fileimg = "$dir/dunp.jpg";
    var filemodel = await get_file_path_mmod_human_face_detector_dat();
    await DlibFfi.detect_face_load_model(DlibFfi.dylib, filemodel);
    print("-------");
    print(filemodel);
    print(fileimg);
    await DlibFfi.detect_face(DlibFfi.dylib, fileimg);
    print("-------1");
  }

  _initModel();
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

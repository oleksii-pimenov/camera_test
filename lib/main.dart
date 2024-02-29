import 'dart:async';
import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
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
        // the application has a purple toolbar. Then, without quitting the app,
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

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraState _currentState;

  Future<String?> capturePhoto() async {
    Completer<String?> completer = Completer();

    // Simulate capturing a photo, replace with actual camera logic
    _currentState.when(
      onPhotoMode: (photoState) async {
        final photoPath = await path(CaptureMode.photo);
        photoState.takePhoto(onPhoto: (CaptureRequest freshPhoto) {
          freshPhoto.when(single: (SingleCaptureRequest freshSinglePhoto) {
            completer.complete(freshSinglePhoto.file!.path);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Photo Taken"),
                  content: Image.file(File(
                      freshSinglePhoto.file!.path)), // Display the taken photo
                  actions: <Widget>[
                    TextButton(
                      child: Text("Close"),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                  ],
                );
              },
            );
          });
        });
      },
      // Handle other necessary states
    );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      CameraAwesomeBuilder.custom(
        sensorConfig: SensorConfig.single(
          sensor: Sensor.position(SensorPosition.front),
          aspectRatio: CameraAspectRatios.ratio_4_3,
          zoom: 0.0,
        ),
        previewAlignment: Alignment.center,
        previewFit: CameraPreviewFit.cover,
        saveConfig: SaveConfig.photo(
          exifPreferences: ExifPreferences(saveGPSLocation: false),
          pathBuilder: (sensors) async {
            try {
              if (Platform.isAndroid) {
                print('ANDROID FOV ${await CamerawesomePlugin.getHfov()}');
              } else {
                print('IOS FOV ${await CamerawesomePlugin.getHfov()}');
              }
            } catch (e) {}
            dynamic tempPath = await path(CaptureMode.photo);
            return SingleCaptureRequest(tempPath, sensors.first);
          },
        ),
        builder: (cameraState, Preview previewRect) {
          _currentState = cameraState;
          return const SizedBox();
        },
      ),
      Positioned(
        bottom: 20,
        child: ElevatedButton(
            onPressed: () {
              capturePhoto();
            },
            child: const Text('Capture')),
      )
    ]);
  }

  Future<String> path(CaptureMode captureMode) async {
    final Directory extDir = await getTemporaryDirectory();
    final tempDir =
        await Directory('${extDir.path}/test').create(recursive: true);
    // Use a timestamp to ensure the file name is unique
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = '${tempDir.path}/$fileName';
    print('Unique path $filePath');
    return filePath;
  }
}

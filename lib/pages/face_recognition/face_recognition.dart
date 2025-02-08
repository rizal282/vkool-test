import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FaceRecognition extends StatefulWidget {
  const FaceRecognition({super.key});

  @override
  State<FaceRecognition> createState() => _FaceRecognitionState();
}

class _FaceRecognitionState extends State<FaceRecognition> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isProcessing = false;
  List<double> _smileHistory = [];

   Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        Fluttertoast.showToast(msg: "Kamera tidak tersedia");
        return;
      }

      _cameraController = CameraController(cameras.last, ResolutionPreset.medium);
      await _cameraController!.initialize();

      if (!mounted) return;
      setState(() {});
      _startImageStream();
      print("INITIALIZED =====================================");
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal mengakses kamera: $e");
    }
  }

  void _initializeFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(enableClassification: true),
    );
  }

  void _startImageStream() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    _cameraController!.startImageStream((CameraImage image) async {
      if (_isProcessing || _faceDetector == null) return;
      _isProcessing = true;

      try {
        final bytes = _concatenatePlanes(image.planes);
        final inputImage = InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: InputImageRotation.rotation0deg,
            format: InputImageFormat.nv21,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );
        
        print("START IMAGE STREAM =====================================");

        await _processCameraImage(inputImage);
      } catch (e) {
        debugPrint("Error processing image: $e");
      }

      _isProcessing = false;
    });
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer buffer = WriteBuffer();
    for (Plane plane in planes) {
      buffer.putUint8List(plane.bytes);
    }
    return buffer.done().buffer.asUint8List();
  }

  Future<void> _processCameraImage(InputImage inputImage) async {
    print("CAMERA PROCESSING =====================================");

    if (_faceDetector == null) return;

    final List<Face> faces = await _faceDetector!.processImage(inputImage);

    print("DETECT FACES =====================================");

    if (faces.isNotEmpty) {
      final smileProb = faces.first.smilingProbability;
      if (smileProb != null) {
        print("DETECT SMILE =====================================");
        detectSmile(smileProb);
      }
    }
  }

  void detectSmile(double smileProb) {
    _smileHistory.add(smileProb);
    if (_smileHistory.length > 5) {
      _smileHistory.removeAt(0);
    }

    final avgSmile = _smileHistory.reduce((a, b) => a + b) / _smileHistory.length;

    print("AVG SMILE ====================================================================== $avgSmile");

    if (avgSmile > 0.4) {
      _takePicture();
      _smileHistory.clear();
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      final XFile file = await _cameraController!.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final path = join(directory.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
      await File(file.path).copy(path);

      Fluttertoast.showToast(msg: "Foto tersimpan: $path");
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      debugPrint("Error take picture: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeFaceDetector();
  }


  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Face Recognition & Smile Detection")),
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? Center(child: CircularProgressIndicator())
          : CameraPreview(_cameraController!),
    );
  }
}

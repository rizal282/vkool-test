import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FaceRecognition extends StatefulWidget {
  @override
  _FaceRecognitionState createState() => _FaceRecognitionState();
}

class _FaceRecognitionState extends State<FaceRecognition> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  bool _isDetecting = false;
  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
        enableClassification: true,
        enableContours: true,
        enableLandmarks: true),
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      print("Initializing camera...");
      _cameras = await availableCameras();
      _cameraController =
          CameraController(_cameras[1], ResolutionPreset.medium);
      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }

      print("Camera initialized successfully!");
      _startFaceDetection();
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  void _startFaceDetection() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print("Camera is not initialized properly.");
      return;
    }

    print("Starting face detection...");

    _cameraController!.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      await Future.delayed(
          Duration(milliseconds: 300)); // Delay kecil agar tidak bertumpuk

      try {
        print("Processing image from stream...");

        // Tambahkan log untuk melihat format gambar dari kamera
        print("Camera image format: ${image.format.group}");

        final bytes = _convertYUV420toUint8List(image);
        if (bytes == null) {
          print("Failed to convert image bytes.");
          _isDetecting = false;
          return;
        }

        final inputImage = InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation:
                InputImageRotation.rotation270deg, // Bisa dicoba ubah rotation
            format: InputImageFormat.nv21, // Pastikan format NV21
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );

        final faces = await faceDetector.processImage(inputImage);
        print("Detected faces: ${faces.length}");

        if (faces.isEmpty) {
          print("No faces detected. Check lighting and camera angle.");
        }

        for (Face face in faces) {
          print("Face detected at: ${face.boundingBox}");

          final double? smileProb = face.smilingProbability;
          print("Smile probability: ${smileProb ?? 'Not Supported'}");

          if (smileProb != null && smileProb > 0.7) {
            await _takePicture();
          }
        }
      } catch (e) {
        print("Error processing image: $e");
      } finally {
        _isDetecting = false;
      }
    });
  }

  Uint8List? _convertYUV420toUint8List(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;
      final int yRowStride = image.planes[0].bytesPerRow;

      final int uvRowStride = image.planes[1].bytesPerRow;
      final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

      final Uint8List yBuffer = image.planes[0].bytes;
      final Uint8List uBuffer = image.planes[1].bytes;
      final Uint8List vBuffer = image.planes[2].bytes;

      final Uint8List nv21 = Uint8List(width * height * 3 ~/ 2);
      int index = 0;

      // Copy Y plane
      for (int i = 0; i < height; i++) {
        nv21.setRange(index, index + width,
            yBuffer.sublist(i * yRowStride, i * yRowStride + width));
        index += width;
      }

      // Copy UV planes
      for (int i = 0; i < height ~/ 2; i++) {
        for (int j = 0; j < width ~/ 2; j++) {
          final int uIndex = i * uvRowStride + j * uvPixelStride;
          final int vIndex = i * uvRowStride + j * uvPixelStride;

          nv21[index++] = vBuffer[vIndex]; // V (Cb)
          nv21[index++] = uBuffer[uIndex]; // U (Cr)
        }
      }

      return nv21;
    } catch (e) {
      print("Error converting YUV420 to NV21: $e");
      return null;
    }
  }

  Future<void> _takePicture() async {
    print("Taking picture...");

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print("Camera is not ready to take a picture.");
      return;
    }

    try {
      final XFile file = await _cameraController!.takePicture();
      saveToDCIM(file.path);
      // final directory = await getApplicationDocumentsDirectory();
      // final path = join(directory.path, '${DateTime.now()}.jpg');
      // await File(file.path).copy(path);

      // print("Picture saved at: $path");
      Fluttertoast.showToast(msg: "Picture taken!");
    } catch (e) {
      print("Error taking picture: $e");
    }
  }

  Future<void> saveToDCIM(String filePath) async {
  try {
    // Dapatkan direktori DCIM
    Directory? dcimDir = Directory('/storage/emulated/0/DCIM/VKommerce');

    // Jika folder belum ada, buat folder baru
    if (!dcimDir.existsSync()) {
      dcimDir.createSync(recursive: true);
    }

    // Buat nama file berdasarkan timestamp
    String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    String newFileName = "IMG_$timestamp.jpg";

    // Path tujuan di DCIM
    File newFile = File("${dcimDir.path}/$newFileName");

    // Salin file ke DCIM
    File(filePath).copySync(newFile.path);

    // Tampilkan pesan sukses
    Fluttertoast.showToast(msg: "Gambar disimpan di DCIM");

    print("File berhasil disimpan di: ${newFile.path}");
  } catch (e) {
    print("Gagal menyimpan file: $e");
  }
}

  @override
  void dispose() {
    _cameraController?.dispose();
    faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Face Recognition & Smile Detection")),
      body: _isCameraInitialized
          ? CameraPreview(_cameraController!)
          : Center(child: CircularProgressIndicator()),
    );
  }
}

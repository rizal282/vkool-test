import 'package:camera/camera.dart';
import 'package:ecommerce_vkool/data/service/face_detector_service.dart';
import 'package:flutter/material.dart';

class FaceRecognitionPage extends StatefulWidget {
  const FaceRecognitionPage({super.key});

  @override
  State<FaceRecognitionPage> createState() => _FaceRecognitionPageState();
}

class _FaceRecognitionPageState extends State<FaceRecognitionPage> {
  CameraController? _cameraController;
  late List<CameraDescription> cameras;
  bool isProcessing = false;
  FaceDetectorService faceDetectorService = FaceDetectorService();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    print("Camera Initialized!");
    cameras = await availableCameras();
    _cameraController = CameraController(cameras[1], ResolutionPreset.medium);

    await _cameraController!.initialize();

    _cameraController!.startImageStream((image) async {
      print("Image Prosessss!");

      if(!isProcessing){
        isProcessing = true;
        bool smiling = await faceDetectorService.detectSmile(image);

        if(smiling){
          print("Taking picture!!");
          _takePicture();
        }

        isProcessing = false;
      }
    });

    setState(() {});
  }

  Future<void> _takePicture() async {
    try {
      final XFile picture = await _cameraController!.takePicture();
      print("Foto diambil: ${picture.path}");
    } catch (e) {
      print("Gagal mengambil foto $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    faceDetectorService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cameraController == null || !_cameraController!.value.isInitialized
        ? Center(child: CircularProgressIndicator())
        : CameraPreview(_cameraController!),
    );
  }
}
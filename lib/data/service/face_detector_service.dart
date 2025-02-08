import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorService {
  final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
          enableClassification: true, enableContours: true));

  Future<bool> detectSmile(CameraImage image) async {
    final InputImageRotation rotation = InputImageRotation.rotation0deg;
    final InputImageFormat format = InputImageFormat.yuv_420_888;
    final InputImageMetadata metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow);

    final inputImage =
        InputImage.fromBytes(bytes: image.planes[0].bytes, metadata: metadata);

    final faces = await faceDetector.processImage(inputImage);

    if (faces.isNotEmpty) {
      for (Face face in faces) {
        if (face.smilingProbability != null && face.smilingProbability! > 0.7) {
          return true;
        }
      }
    }

    return false;
  }

  void dispose() {
    faceDetector.close();
  }
}

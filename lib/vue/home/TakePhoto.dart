// A screen that allows users to take a picture using a given camera.
import 'dart:collection';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Model/FileCustom.dart';
import '../../outil/Constant.dart';

class TakePicture extends StatefulWidget {
  const TakePicture({
    super.key,
    required this.cameras,
    required this.callback,
  });

  final Function callback;
  final List<CameraDescription> cameras;

  @override
  TakePictureState createState() => TakePictureState();
}

class TakePictureState extends State<TakePicture> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late int _selectedCameraIndex = 0; // Indice de la caméra actuellement sélectionnée

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras[_selectedCameraIndex], // Utiliser la caméra actuellement sélectionnée
      ResolutionPreset.ultraHigh,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleCamera() async {
    // Changer l'indice de la caméra sélectionnée
    _selectedCameraIndex = (_selectedCameraIndex + 1) % widget.cameras.length;
    final newCamera = widget.cameras[_selectedCameraIndex];

    // Arrêter le contrôleur de la caméra actuel
    await _controller.dispose();

    // Initialiser le contrôleur de la nouvelle caméra
    _controller = CameraController(
      newCamera,
      ResolutionPreset.ultraHigh,
    );
    _initializeControllerFuture = _controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _takePhoto() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      var compresseImage = await Constant.compressImage(await image.readAsBytes(), 90);
      FileCustom file = FileCustom(compresseImage, image.name);

      if (!context.mounted) return;
      Navigator.of(context).pop(context);
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
            image: file, callback: widget.callback,
          ),
        ),
      );
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePhoto, // Appeler la méthode _takePhoto lorsqu'on appuie sur le bouton
        child: const Icon(Icons.camera), // Utiliser une icône pour le bouton
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _toggleCamera,
            child: Icon(Icons.switch_camera),
          ),
        ],
      ),
    );
  }
}


class DisplayPictureScreen extends StatelessWidget {
  final FileCustom image;
  final Function callback;

  const DisplayPictureScreen({super.key, required this.image,required this.callback,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.amber,
              child: Image.memory(
                image.fileBytes!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.of(context).pop(context);
          callback(image);
        },
        child: const Icon(Icons.check),
      ),
    );
  }

}
// A screen that allows users to take a picture using a given camera.
import 'dart:collection';
import 'dart:io';

import 'package:pouic/Model/FileCustom.dart';
import 'package:pouic/Model/pouireal_model.dart';
import 'package:pouic/vue/home/pouireal/pouireal_viewmodel.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../outil/Constant.dart';
import '../../../outil/LoginSingleton.dart';
import '../../widget/LoadingDialog.dart';

class TakePicturePouireal extends StatefulWidget {
  const TakePicturePouireal(
      {super.key, required this.cameras, required this.callback});

  final List<CameraDescription> cameras;
  final Function callback;

  @override
  TakePicturePouirealState createState() => TakePicturePouirealState();
}

class TakePicturePouirealState extends State<TakePicturePouireal> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late int _selectedCameraIndex =
      0; // Indice de la caméra actuellement sélectionnée

  bool takePhoto = false;

  @override
  void initState() {
    super.initState();
    takePhoto = false;
    _controller = CameraController(
      widget.cameras[_selectedCameraIndex],
      // Utiliser la caméra actuellement sélectionnée
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
      setState(() {
        takePhoto = true;
      });
      await _initializeControllerFuture;
      final XFile image = await _controller.takePicture();

      // Attendre un court instant pour permettre à la caméra de se stabiliser
      await Future.delayed(Duration(milliseconds: 250));

      // Basculer vers la deuxième caméra
      await _toggleCamera();

      // Attendre que la deuxième caméra soit initialisée
      await _initializeControllerFuture;

      // Prendre la deuxième photo
      final XFile image2 = await _controller.takePicture();

      FileCustom imageCompresse1 = FileCustom(
          await Constant.compressImage(await image.readAsBytes(), 90),
          image.name);
      FileCustom imageCompresse2 = FileCustom(
          await Constant.compressImage(await image2.readAsBytes(), 90),
          image2.name);

      if (!context.mounted) return;

      Navigator.of(context).pop(context);

      // Naviguer vers la page d'affichage des photos avec les deux chemins d'image
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPicturePouirealLocal(
            image1: imageCompresse1,
            image2: imageCompresse2,
            callback: widget.callback,
          ),
        ),
      );
    } catch (e) {
      // Gérer les erreurs ici
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              width: double.infinity,
              // Le Container prend toute la largeur disponible
              height: double.infinity,
              // Le Container prend toute la hauteur disponible
              child: CameraPreview(
                  _controller), // Afficher CameraPreview à l'intérieur du Container
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Visibility(
        visible: !takePhoto,
        child: FloatingActionButton(
          onPressed: _takePhoto,
          // Appeler la méthode _takePhoto lorsqu'on appuie sur le bouton
          child: const Icon(Icons.camera), // Utiliser une icône pour le bouton
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        actions: [
          Visibility(
            visible: !takePhoto,
            child: TextButton(
              onPressed: _toggleCamera,
              child: Icon(Icons.switch_camera),
            ),
          ),
        ],
      ),
    );
  }
}

class DisplayPicturePouirealLocal extends StatefulWidget {
  final FileCustom image1;
  final FileCustom image2;

  final Function callback;

  const DisplayPicturePouirealLocal(
      {super.key,
      required this.image1,
      required this.image2,
      required this.callback});

  @override
  _DisplayPicturePouirealLocalState createState() =>
      _DisplayPicturePouirealLocalState();
}

class _DisplayPicturePouirealLocalState
    extends State<DisplayPicturePouirealLocal> {
  final LoginModel lm = LoginModelProvider.getInstance(() {}).loginModel!;
  bool isFlipped =
      false; // État pour suivre si les images sont inversées ou non
  String description = "";

  PouirealViewModel pouirealViewModel = PouirealViewModel();

  int compteur = 0;

  double _imageLeft = 16.0;
  double _imageTop = 16.0;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body:(_isLoading)?LoadingDialog(): Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                // Réduire le ListView pour qu'il s'adapte à son contenu
                children: [
                  Stack(
                    children: [
                      // Container pour occuper tout l'espace avec la première image
                      Container(
                          width: double.infinity,
                          child: Image.memory(
                            isFlipped
                                ? widget.image2.fileBytes!
                                : widget.image1.fileBytes!,
                            fit: BoxFit.fitWidth,
                          )
                      ),
                      Positioned(
                        left: _imageLeft,
                        top: _imageTop,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isFlipped = !isFlipped;
                            });
                          },
                          onPanUpdate: (details) {
                            setState(() {
                              // Mettez à jour la position de l'image en fonction du déplacement
                              _imageLeft += details.delta.dx;
                              _imageTop += details.delta.dy;
                            });
                          },
                          child: Image.memory(
                            isFlipped
                                ? widget.image1.fileBytes!
                                : widget.image2.fileBytes!,
                            width: 100.0,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Entrez votre Description',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.newline,
                      minLines: 1,
                      maxLines: 100,
                      onChanged: (value) {
                        description = value;
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onPress,
        child: const Icon(Icons.check),
      ),
    );
  }

  void _onPress() async {
    setState(() {
      _isLoading=true;
    });
    Stream<PouirealModel> stream = pouirealViewModel
        .postPouireal(PouirealPostModel(lm.user, description, DateTime.now()));
    stream.listen((pouirealModelTmp) {
      compteur = 2;

      Stream<PouirealModel> streamImage1 = pouirealViewModel.postPouirealFile(
          pouirealModelTmp.id, 1, widget.image1);
      streamImage1.listen((pouirealModelTmp) {
        afterTwoPostImage();
      }, onError: (error) {
        print("Erreur : $error");
      });

      Stream<PouirealModel> streamImage2 = pouirealViewModel.postPouirealFile(
          pouirealModelTmp.id, 2, widget.image2);
      streamImage2.listen((pouirealModelTmp) {
        afterTwoPostImage();
      }, onError: (error) {
        print("Erreur : $error");
      });
    }, onError: (error) {
      print("Erreur : $error");
    });
  }

  void afterTwoPostImage() {
    compteur--;
    if (compteur == 0) {
      Navigator.of(context).pop(context);
      widget.callback();
    }
  }
}

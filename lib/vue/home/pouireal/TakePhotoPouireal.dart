// A screen that allows users to take a picture using a given camera.
import 'dart:collection';
import 'dart:io';

import 'package:Pouic/Model/FileCustom.dart';
import 'package:Pouic/Model/pouireal_model.dart';
import 'package:Pouic/vue/home/pouireal/pouireal_viewmodel.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../outil/Constant.dart';
import '../../../outil/LoginSingleton.dart';

class TakePicturePouireal extends StatefulWidget {
  const TakePicturePouireal({
    super.key,
    required this.cameras,
    required this.callback
  });

  final List<CameraDescription> cameras;
  final Function callback;

  @override
  TakePicturePouirealState createState() => TakePicturePouirealState();
}

class TakePicturePouirealState extends State<TakePicturePouireal> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late int _selectedCameraIndex = 0; // Indice de la caméra actuellement sélectionnée

  bool takePhoto=false;

  @override
  void initState() {
    super.initState();
    takePhoto=false;
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
      setState(() {
        takePhoto=true;
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

      if (!context.mounted) return;


      Navigator.of(context).pop(context);

      // Naviguer vers la page d'affichage des photos avec les deux chemins d'image
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPicturePouirealLocal(
            image1: image,
            image2: image2,
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
              width: double.infinity, // Le Container prend toute la largeur disponible
              height: double.infinity, // Le Container prend toute la hauteur disponible
              child: CameraPreview(_controller), // Afficher CameraPreview à l'intérieur du Container
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton:Visibility(
        visible: !takePhoto,
        child:  FloatingActionButton(
          onPressed: _takePhoto, // Appeler la méthode _takePhoto lorsqu'on appuie sur le bouton
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
  final XFile image1;
  final XFile image2;

  final Function callback;

  const DisplayPicturePouirealLocal({
    super.key,
    required this.image1,
    required this.image2,
    required this.callback
  });

  @override
  _DisplayPicturePouirealLocalState createState() => _DisplayPicturePouirealLocalState();
}

class _DisplayPicturePouirealLocalState extends State<DisplayPicturePouirealLocal> {
  final LoginModel lm = LoginModelProvider.getInstance(() {}).loginModel!;
  bool isFlipped = false; // État pour suivre si les images sont inversées ou non
  String description ="";

  PouirealViewModel pouirealViewModel = PouirealViewModel();

  int compteur = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child:SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  // Image1 ou Image2 en arrière-plan en fonction de l'état isFlipped
                  Image.file(
                    File(isFlipped ? widget.image2.path : widget.image1.path),
                    fit: BoxFit.contain,
                  ),
                  // Bouton pour inverser les images
                  Positioned(
                    left: 16.0,
                    top: 16.0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isFlipped = !isFlipped; // Inverser l'état isFlipped
                        });
                      },
                      child: Image.file(
                        File(isFlipped ? widget.image1.path : widget.image2.path),
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
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          FileCustom imageCompresse1 =  FileCustom(await Constant.compressImage(await widget.image1.readAsBytes(),90),widget.image1.name);
          FileCustom imageCompresse2 =  FileCustom(await Constant.compressImage(await widget.image2.readAsBytes(),90),widget.image2.name);


          Stream<PouirealModel> stream = pouirealViewModel.postPouireal(PouirealPostModel(lm.user, description, DateTime.now()));
          stream.listen((pouirealModelTmp) {

            compteur=2;

            Stream<PouirealModel> streamImage1 = pouirealViewModel.postPouirealFile(pouirealModelTmp.id, 1,imageCompresse1 );
            streamImage1.listen((pouirealModelTmp) {

              afterTwoPostImage();

            }, onError: (error) {
              print("Erreur : $error");
            });



            Stream<PouirealModel> streamImage2 = pouirealViewModel.postPouirealFile(pouirealModelTmp.id, 2,imageCompresse2);
            streamImage2.listen((pouirealModelTmp) {

              afterTwoPostImage();

            }, onError: (error) {
              print("Erreur : $error");
            });

          }, onError: (error) {
            print("Erreur : $error");
          });


        }, // Appeler la méthode _takePhoto lorsqu'on appuie sur le bouton
        child: const Icon(Icons.check), // Utiliser une icône pour le bouton
      ),
    );
  }


  void afterTwoPostImage(){
    compteur--;
    if(compteur==0){
      Navigator.of(context).pop(context);
      widget.callback();
    }
  }


}


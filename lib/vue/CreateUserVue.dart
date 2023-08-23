import 'dart:io';

import 'package:discution_app/Controller/UserController.dart';
import 'package:discution_app/Controller/UserCreate.dart';
import 'package:discution_app/Model/UserListeModel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import '../Model/UserModel.dart';

class CreateUserVue extends StatefulWidget {
  const CreateUserVue({super.key});

  final String title="CreateUser Vue";


  @override
  State<CreateUserVue> createState() => _CreateUserVueState();
}

class _CreateUserVueState extends State<CreateUserVue> {
  final userNameUnique = TextEditingController();
  final userName = TextEditingController();
  final email = TextEditingController();
  final mdp = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  UserListe users=UserListe();
  UserCreate userCreate = UserCreate();

  img.Image? avatar;

  get http => null;

  Future<void> _pickImage() async {
    File? _pickedImage;
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }

    if (_pickedImage != null) {
      // Charger l'image
      final originalImage = img.decodeImage(_pickedImage!.readAsBytesSync());

      // Redimensionner l'image en gardant le ratio
      final resizedImage = img.copyResize(originalImage!, height: 150);

      avatar=resizedImage;

      print("taille de limage en bytes : " +avatar!.lengthInBytes.toString());

    }
  }

  void createUser(){
    if (_formKey.currentState!.validate()) {
      User user;
      if(avatar!=null){
        user = User(email.text, userNameUnique.text, userName.text, img.encodeJpg(avatar!));
      }
      else{
        user = User(email.text, userNameUnique.text, userName.text,null);
      }
      userCreate.create(user, mdp.text, reponseCreateUser);
    }

  }
  void reponseCreateUser(User? u){
    if(u!=null){
      print(u.toJsonString());
      Navigator.pop(context);
    }
    else{
      showAlertDialog(context,"Erreur","erreur lors de la requette a l'api");
    }
  }

  @override
  void dispose() {
    userNameUnique.dispose();
    userName.dispose();
    email.dispose();
    mdp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
    key: _formKey,
    child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: userNameUnique,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Entrée votre userNameUnique',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  return null; // Valide
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: userName,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Entrée votre userName',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  return null; // Valide
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: email,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Entrée votre email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  return null; // Valide
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                obscureText: true,
                controller: mdp,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Entrée votre mdp',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  return null; // Valide
                },
              ),
            ),
            InkWell(
              onTap: _pickImage,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: ClipOval(
                  child: avatar != null
                      ? Image.memory(
                    img.encodeJpg(avatar!),
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.add_a_photo, size: 50),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                createUser();
                },
              child: Text('Créer sont compte'),
            ),
          ],
        ),
      ),
    ),
    );
  }
  showAlertDialog(BuildContext context,String titre,String erreur) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(titre),
      content: Text(erreur),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
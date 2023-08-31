import 'dart:io';

import 'package:dio/dio.dart';
import 'package:discution_app/Controller/UserController.dart';
import 'package:discution_app/Controller/UserC.dart';
import 'package:discution_app/Model/UserListeModel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import '../Model/UserModel.dart';
import '../outil/Constant.dart';

class CreateUserVue extends StatefulWidget {
  CreateUserVue({super.key,required this.user,required this.created});
  final User user;
  final bool created;
  final String title="CreateUser Vue";


  @override
  State<CreateUserVue> createState() => _CreateUserVueState();
}

class _CreateUserVueState extends State<CreateUserVue> {
  final userNameUnique = TextEditingController();
  final userName = TextEditingController();
  final email = TextEditingController();
  final mdp = TextEditingController();
  File imageFile = File('');

  final _formKey = GlobalKey<FormState>();

  UserListe users=UserListe();
  UserC userCreate = UserC();

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      File imageTmp = File(pickedImage.path);

      if (imageTmp.lengthSync() > 5 * 1024 * 1024) {
        print('Veuillez sélectionner une image de moins de 5 Mo.');
        Constant.showAlertDialog(context, "Erreur", "Veuillez sélectionner une image de moins de 5 Mo.");
        return;
      }

      if (imageTmp.path.toLowerCase().endsWith('.png')||imageTmp.path.toLowerCase().endsWith('.jpg')||imageTmp.path.toLowerCase().endsWith('.jpeg')||imageTmp.path.toLowerCase().endsWith('.gif')) {
        imageFile = imageTmp;
      } else {
        print('Veuillez sélectionner une image au format PNG jpg jpeg ou gif.');
        Constant.showAlertDialog(context, "erreur", "Veuillez sélectionner une image au format PNG jpg jpeg ou gif.");
        return;
      }

      setState(() {
        // Mettre à jour l'interface utilisateur
      });
    }
  }

  void createUser(){
    if (_formKey.currentState!.validate()) {
      widget.user.email=email.text;
      widget.user.uniquePseudo=userNameUnique.text;
      widget.user.pseudo=userName.text;
      if(widget.created){
        userCreate.create(widget.user,imageFile, mdp.text, reponseCreateUser,reponseCreateUserError);
      }
      else{
        userCreate.modify(widget.user,imageFile, mdp.text, reponseCreateUser,reponseCreateUserError);
      }
    }

  }
  void reponseCreateUser(User u){
    print(u.toJsonString());
    Navigator.pop(context);
  }
  void reponseCreateUserError(DioException ex){
    if(ex.response!=null && ex.response!.data["message"] != null){
      Constant.showAlertDialog(context,"Erreur",ex.response!.data["message"]);
    }
    else{
      Constant.showAlertDialog(context, "Erreur", "Une erreur s'est produite lors de la création de l'utilisateur.");
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
  void initState() {
    super.initState();
    if (!widget.created) {
      userNameUnique.text = widget.user.uniquePseudo;
      userName.text = widget.user.pseudo;
      email.text = widget.user.email;
    }
  }

  Widget buildImageOrIcon() {
    if (imageFile.existsSync()) {
      return Image.file(
        imageFile,
        fit: BoxFit.cover,
      );
    } else {
      return Constant.buildImageOrIcon(
          Constant.baseUrlAvatarUser+"/"+widget.user.uniquePseudo,
          Icon(Icons.add_a_photo)
      );
    }
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
                  labelText: 'Entrée votre @',
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
                  RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Veuillez entrer une adresse e-mail valide';
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
                  RegExp passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

                  if (!passwordRegex.hasMatch(value)) {
                    return 'Le mot de passe doit contenir au moins 8 caractères, dont une majuscule, une minuscule, un chiffre et un caractère spécial';
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
                  child: buildImageOrIcon(),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                createUser();
                },
              child: Text((widget.created==true)?'Créer sont compte':'modifier sont compte'),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
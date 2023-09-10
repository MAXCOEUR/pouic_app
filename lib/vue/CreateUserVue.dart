import 'dart:io';

import 'package:dio/dio.dart';
import 'package:discution_app/Controller/UserController.dart';
import 'package:discution_app/Controller/UserC.dart';
import 'package:discution_app/Model/FileCustom.dart';
import 'package:discution_app/Model/UserListeModel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
  final bio = TextEditingController();
  FileCustom? imageFile;

  final _formKey = GlobalKey<FormState>();

  UserListe users=UserListe();
  UserC userCreate = UserC();

  Future<void> _pickImage() async {
    FilePickerResult? pickedImage = await FilePicker.platform.pickFiles(type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],);

    if (pickedImage != null) {
      PlatformFile file = pickedImage.files.first;
      late Uint8List? fileBytes;
      late String fileName= file.name;

      if(kIsWeb){
        fileBytes = file.bytes;
      }else{
        File localFile = File(file.path!);
        fileBytes = await localFile.readAsBytes();
      }

      if(fileBytes!=null){
        if(fileName.split(".").last.toLowerCase()!="gif"){
          if (fileBytes.length >= 1000000) {
            if(kIsWeb){
              fileBytes = await Constant.compressImage(fileBytes, 20);
            }
            else if (!Platform.isWindows) {
              fileBytes = await Constant.compressImage(fileBytes, 20);
            }
          }
        }
        if (fileBytes.length > 1000000) {
          print('Veuillez sélectionner une image de moins de 1 Mo.');
          Constant.showAlertDialog(context, "Erreur", "Veuillez sélectionner une image de moins de 1 Mo.");
          return;
        }

        setState(() {
          imageFile = FileCustom(fileBytes, fileName);
        });
      }
    }
  }


  void createUser(){
    if (_formKey.currentState!.validate()) {
      widget.user.email=email.text;
      widget.user.uniquePseudo=userNameUnique.text;
      widget.user.pseudo=userName.text;
      widget.user.extansion=imageFile?.fileName.split('.').last.toLowerCase();
      if(bio.text==""){
        widget.user.bio=null;
      }else{
        widget.user.bio=bio.text;
      }
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
    imageFile=null;
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
    bio.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    if (!widget.created) {
      userNameUnique.text = widget.user.uniquePseudo;
      userName.text = widget.user.pseudo;
      email.text = widget.user.email;
      if(widget.user.bio!=null){
        bio.text=widget.user.bio!;
      }
    }
  }

  Widget buildImageOrIcon() {
    if (imageFile!=null) {
      return Image.memory(
        imageFile!.fileBytes!,
        fit: BoxFit.cover,
      );
    } else {
      return Constant.buildAvatarUser(widget.user,75,false);
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
            Container(
              margin: EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: TextFormField(
                controller: userNameUnique,
                maxLength: 80,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Entrée votre @',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'le champ @ est obligatoir et unique';
                  }
                  return null; // Valide
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: TextFormField(
                controller: userName,
                maxLength: 80,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Entrée votre Pseudo',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'le champ Pseudo est obligatoir ';
                  }
                  return null; // Valide
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: TextFormField(
                controller: email,
                maxLength: 255,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
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
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical:2),
              child: TextField(
                controller: bio,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(), // Utilisez OutlineInputBorder pour un champ extensible
                  labelText: 'Entrée votre bio',
                ),
                maxLines: null, // Permet un nombre illimité de lignes
                maxLength: 200, // Limite le nombre de caractères à 200
                keyboardType: TextInputType.multiline, // Permet de saisir sur plusieurs lignes
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: TextFormField(
                obscureText: true,
                controller: mdp,
                maxLength: 255,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Entrée votre mdp',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  RegExp passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,255}$');

                  if (!passwordRegex.hasMatch(value)|| value.length>=255) {
                    return 'Le mot de passe doit contenir entre 8 et 255 caractères, dont une majuscule, une minuscule, un chiffre et un caractère spécial (@\$!%*?&)';
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
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:Pouic/Controller/UserController.dart';
import 'package:Pouic/Controller/UserC.dart';
import 'package:Pouic/Model/FileCustom.dart';
import 'package:Pouic/Model/UserListeModel.dart';
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
  final String title="User";


  @override
  State<CreateUserVue> createState() => _CreateUserVueState();
}

class _CreateUserVueState extends State<CreateUserVue> {
  final userNameUnique = TextEditingController();
  final userName = TextEditingController();
  final email = TextEditingController();
  final oldMdp = TextEditingController();
  final mdp = TextEditingController();
  final confMdp = TextEditingController();
  final bio = TextEditingController();

  late bool displayMdp;
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
      widget.user.extension=imageFile?.fileName.split('.').last.toLowerCase();
      if(bio.text==""){
        widget.user.bio=null;
      }else{
        widget.user.bio=bio.text;
      }
      userCreate.create(widget.user,imageFile, mdp.text, reponseCreateUser,reponseCreateUserError);
    }

  }
  void modifyUser(){
    if (_formKey.currentState!.validate()) {
      widget.user.email=email.text;
      widget.user.uniquePseudo=userNameUnique.text;
      widget.user.pseudo=userName.text;
      widget.user.extension=imageFile?.fileName.split('.').last.toLowerCase();
      if(bio.text==""){
        widget.user.bio=null;
      }else{
        widget.user.bio=bio.text;
      }
      userCreate.modify(widget.user,imageFile,reponseCreateUser,reponseCreateUserError);

      if(displayMdp){
        userCreate.modifyMdp(oldMdp.text, mdp.text, reponseMoifyMdp, reponseCreateUserError);
      }

    }

  }
  void reponseCreateUser(User u){
    if(widget.created||!displayMdp){
      print(u.toJsonString());
      imageFile=null;
      Navigator.pop(context);
    }

  }
  void reponseMoifyMdp(){
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
      displayMdp=false;
    }
    else{
      displayMdp=true;
    }
  }

  Widget buildImageOrIcon() {
    if (imageFile!=null) {
      return Image.memory(
        imageFile!.fileBytes!,
        fit: BoxFit.cover,
      );
    } else {
      return Constant.buildAvatarUser(widget.user,75,false,context);
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
                  labelText: '@',
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
                  labelText: 'Pseudonyme',
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
                  labelText: 'Email',
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
                  labelText: 'Bio',
                ),
                maxLines: null, // Permet un nombre illimité de lignes
                maxLength: 200, // Limite le nombre de caractères à 200
                keyboardType: TextInputType.multiline, // Permet de saisir sur plusieurs lignes
              ),
            ),
            if(!widget.created&&displayMdp==true)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: TextFormField(
                  obscureText: true,
                  controller: oldMdp,
                  maxLength: 255,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Ancien mdp',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ce champ est requis';
                    }
                    return null; // Valide
                  },
                ),
              ),
            if(displayMdp)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: TextFormField(
                obscureText: true,
                controller: mdp,
                maxLength: 255,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nouveau mdp',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  RegExp passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#+_\-()\[\]{}|:;"<>,.?/`=^!&*~§])(?!.*[\\s])[A-Za-z\d@$!%*?&#+_\-()\[\]{}|:;"<>,.?\/`=^!&*~§]{8,255}$');

                  if (!passwordRegex.hasMatch(value)|| value.length>=255) {
                    return 'entre 8 et 255 caractère,\n'+
                        'une majuscule, une minuscule,\n'+
                        'un chiffre et\n'+
                        'un caractère spécial (@\$!%*?&#+_\-()\[\]{}|:;"<>,.?/`=^!&*~§)';
                  }
                  return null; // Valide
                },
              ),
            ),
            if(displayMdp)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: TextFormField(
                  obscureText: true,
                  controller: confMdp,
                  maxLength: 255,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Confirmation du nouveau mdp',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ce champ est requis';
                    }

                    if (value!=mdp.text) {
                      return 'les deux messages ne sont pas égaux';
                    }
                    return null; // Valide
                  },
                ),
              ),
            if(!widget.created&&displayMdp==false)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    displayMdp=true;
                  });
                },
                child: Text('Modifier le mot de passe'),
              ),
            SizedBox(height: 16),
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
            if(widget.created)
            ElevatedButton(
              onPressed: () {
                createUser();
                },
              child: Text('Créer sont compte'),
            ),
            if(!widget.created)
              ElevatedButton(
                onPressed: () {
                  modifyUser();
                },
                child: Text('Modifier le compte'),
              ),
          ],
        ),
      ),
    ),
    );
  }
}
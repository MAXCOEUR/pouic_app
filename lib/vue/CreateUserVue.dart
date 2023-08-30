import 'dart:io';

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

      if (imageTmp.path.toLowerCase().endsWith('.png')) {
        imageFile = imageTmp;
      } else {
        print('Veuillez sélectionner une image au format PNG.');
        Constant.showAlertDialog(context, "erreur", "Veuillez sélectionner une image au format PNG.");
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
  void reponseCreateUserError(Exception ex){
    Constant.showAlertDialog(context,"Erreur","erreur lors de la requette a l'api : "+ex.toString());
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
          Constant.baseUrlAvatarUser+"/"+widget.user.uniquePseudo+".png",
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
import 'dart:io';

import 'package:discution_app/Controller/ConversationC.dart';
import 'package:discution_app/Controller/UserController.dart';
import 'package:discution_app/Controller/UserC.dart';
import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/UserListeModel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import '../Model/UserModel.dart';
import '../outil/Constant.dart';

class CreateConversationVue extends StatefulWidget {
  CreateConversationVue(
      {super.key, required this.conversation, required this.created});

  final LoginModel lm = Constant.loginModel!;
  final String title = "CreateConversation Vue";
  Conversation conversation;
  bool created;

  @override
  State<CreateConversationVue> createState() => _CreateConversationVueState();
}

class _CreateConversationVueState extends State<CreateConversationVue> {
  final name = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  List<String> listUser = [];

  ConversationC conversationC = ConversationC();

  Future<void> _pickImage() async {
    File? _pickedImage;
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

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

      widget.conversation.image = img.encodeJpg(resizedImage);

      print("taille de limage en bytes : " +
          resizedImage.lengthInBytes.toString());
    }
  }

  void createConversation() {
    if (_formKey.currentState!.validate()) {
      widget.conversation.name = name.text;
      widget.conversation.uniquePseudo_admin = widget.lm.user.uniquePseudo;
      if (widget.created) {
        conversationC.create(
            widget.conversation, reponseCreateConversation, reponseError);
      } else {
        conversationC.putConv(
            widget.conversation, reponsePutConversation, reponseError);
      }
    }
  }

  void reponseCreateConversation() {
    print("la conversation a été creer");
    Navigator.pop(context);
  }

  void reponsePutConversation() {
    print("la conversation a été modifié");
    Navigator.pop(context);
  }

  void reponseGetUserSortConversation(List<dynamic> list) {
    setState(() {
      for (int i = 0; i < list.length; i++) {
        listUser.add(list[i]["uniquePseudo_user"]);
      }
    });
  }

  void reponseError(Exception ex) {
    Constant.showAlertDialog(context, "Erreur",
        "erreur lors de la requette a l'api : " + ex.toString());
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (!widget.created) {
      name.text = widget.conversation.name;
      conversationC.getUserShort(
          widget.conversation, reponseGetUserSortConversation, reponseError);
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: name,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Entrée le nom de la conversation',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ce champ est requis';
                    }
                    return null; // Valide
                  },
                ),
              ),
              if (!widget.created)
                Padding(padding: EdgeInsets.all(10), // Ajoute du padding autour du DropdownButton
                    child:Row(
                      children: [
                        Text("Administrateur : "),
                        Expanded(
                          child: DropdownButton<String>(
                            value: widget.conversation.uniquePseudo_admin, // Valeur sélectionnée par défaut
                            items: listUser.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              widget.conversation.uniquePseudo_admin=newValue!;
                            },
                          ),
                        ),
                      ],
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
                    child: widget.conversation.image != null
                        ? Image.memory(
                            widget.conversation.image!,
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.add_a_photo, size: 50),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  createConversation();
                },
                child: Text((widget.created == true)
                    ? 'Créer la conversation'
                    : 'Modifier la conversation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

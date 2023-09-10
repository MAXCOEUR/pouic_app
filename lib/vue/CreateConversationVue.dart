import 'dart:io';

import 'package:discution_app/Controller/ConversationC.dart';
import 'package:discution_app/Controller/UserController.dart';
import 'package:discution_app/Controller/UserC.dart';
import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/FileCustom.dart';
import 'package:discution_app/Model/UserListeModel.dart';
import 'package:discution_app/outil/LoginSingleton.dart';
import 'package:discution_app/outil/SocketSingleton.dart';
import 'package:discution_app/vue/home/message/MessagerieView.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

import '../Model/UserModel.dart';
import '../outil/Constant.dart';

class CreateConversationVue extends StatefulWidget {
  CreateConversationVue(
      {super.key, required this.conversation, required this.created});

  final LoginModel lm = LoginModelProvider.getInstance((){}).loginModel!;
  final String title = "CreateConversation Vue";
  Conversation conversation;
  bool created;

  @override
  State<CreateConversationVue> createState() => _CreateConversationVueState();
}

class _CreateConversationVueState extends State<CreateConversationVue> {
  final name = TextEditingController();
  FileCustom? imageFile;

  final _formKey = GlobalKey<FormState>();
  List<String> listUser = [];

  ConversationC conversationC = ConversationC();

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

      if(fileBytes!=null) {
        if (fileName.split(".").last.toLowerCase() != "gif") {
          if (fileBytes.length >= 1000000) {
            if(kIsWeb){
              fileBytes = await Constant.compressImage(fileBytes, 20);
            }
            else if (!Platform.isWindows) {
              fileBytes = await Constant.compressImage(fileBytes, 20);
            }
          }
        }
        if (fileBytes!.length > 1000000) {
          print('Veuillez sélectionner une image de moins de 1 Mo.');
          Constant.showAlertDialog(context, "Erreur",
              "Veuillez sélectionner une image de moins de 1 Mo.");
          return;
        }

        setState(() {
          imageFile = FileCustom(fileBytes, fileName);
        });
      }
    }
  }


  void createConversation() {
    if (_formKey.currentState!.validate()) {
      widget.conversation.name = name.text;
      widget.conversation.extension=imageFile?.fileName.split('.').last.toLowerCase();
      if (widget.created) {
        conversationC.create(
            widget.conversation,imageFile, reponseCreateConversation, reponseError);
      } else {
        conversationC.putConv(
            widget.conversation,imageFile, reponsePutConversation, reponseError);
      }
    }
  }

  void reponseCreateConversation(Conversation conversation) {
    print("la conversation a été creer");
    SocketSingleton.instance.socket.emit('joinConversation', {'idConversation': conversation.id});
    imageFile=null;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MessagerieView(conv:conversation)),
    );
  }

  void reponsePutConversation() {
    print("la conversation a été modifié");
    imageFile=null;
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

  Widget buildImageOrIcon() {
      if (imageFile!=null) {
        return Image.memory(
          imageFile!.fileBytes!,
          fit: BoxFit.cover,
        );
      } else {
        return Constant.buildImageConversation(widget.conversation,75,true);
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
                    if (value == null || value.isEmpty || value.length>=255) {
                      return 'Ce champ est requis et < 255 caractères';
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
                    child: buildImageOrIcon(),
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

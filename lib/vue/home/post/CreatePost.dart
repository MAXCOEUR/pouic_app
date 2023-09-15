import 'dart:io';
import 'dart:typed_data';

import 'package:discution_app/Controller/PostController.dart';
import 'package:discution_app/Model/FileCustom.dart';
import 'package:discution_app/Model/PostModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/outil/LoginSingleton.dart';
import 'package:discution_app/vue/home/post/PostItemListeView.dart';
import 'package:discution_app/vue/home/message/FileCustomMessage.dart';
import 'package:discution_app/vue/widget/CustomAppBar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';

class CreatePost extends StatefulWidget {
  final LoginModel lm = LoginModelProvider.getInstance(() {}).loginModel!;
  PostModel? post;
  CreatePost(this.post);

  final String title = "Conversations";

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  TextEditingController _messageController = TextEditingController();
  List<FileCustom> listeFile = [];

  bool isRecording = false;
  String? filePath;

  void onDeleteItem(PostModel post){
    Navigator.pop(context);

  }
  Future<void> pickAndAddFilesToList() async {
    FilePickerResult? pickedFiles =
    await FilePicker.platform.pickFiles(allowMultiple: true);

    if (pickedFiles != null) {
      for (PlatformFile file in pickedFiles.files) {
        late Uint8List? fileBytes;
        late String fileName = file.name;

        if (kIsWeb) {
          fileBytes = file.bytes;
        } else {
          File localFile = File(file.path!);
          fileBytes = await localFile.readAsBytes();
        }

        if (fileName.length >= 255) {
          print("le ficher ${fileName} a un nom de plus de 255 caractere");
          Constant.showAlertDialog(context, "Erreur",
              "le ficher ${fileName} a un nom de plus de 255 caractere");
          return;
        }

        if (fileName.toLowerCase().endsWith(".mp4") ||
            fileName.toLowerCase().endsWith(".avi")) {
          if (fileBytes!.length < 50000000) {
            setState(() {
              listeFile.add(FileCustom(fileBytes, fileName));
            });
          } else {
            Constant.showAlertDialog(
                context, "Erreur", "la video ${fileName} fait plus de 50Mo");
          }
        } else if (fileName.toLowerCase().endsWith(".mp3") ||
            fileName.toLowerCase().endsWith(".aac")) {
          if (fileBytes!.length < 7000000) {
            setState(() {
              listeFile.add(FileCustom(fileBytes, fileName));
            });
          } else {
            Constant.showAlertDialog(
                context, "Erreur", "le audio ${fileName} fait plus de 7Mo");
          }
        } else if (fileName.toLowerCase().endsWith(".jpg") ||
            fileName.toLowerCase().endsWith(".jpeg") ||
            fileName.toLowerCase().endsWith(".png")) {
          if (fileBytes != null) {
            if (fileBytes.length >= 1000000) {
              if (kIsWeb) {
                fileBytes = await Constant.compressImage(fileBytes, 90);
                print(fileBytes.length);
              } else if (!Platform.isWindows) {
                fileBytes = await Constant.compressImage(fileBytes, 90);
                print(fileBytes.length);
              }
            }
            if (fileBytes.length > 1000000) {
              Constant.showAlertDialog(
                  context, "Erreur", "l\'image ${fileName} fait plus de 1 Mo");
              break;
            }
            setState(() {
              listeFile.add(FileCustom(fileBytes, fileName));
            });
          }
        } else if (fileName.toLowerCase().endsWith(".gif")) {
          if (fileBytes!.length < 1000000) {
            setState(() {
              listeFile.add(FileCustom(fileBytes, fileName));
            });
          } else {
            Constant.showAlertDialog(
                context, "Erreur", "le gif ${fileName} fait plus de 1Mo");
          }
        } else {
          if (fileBytes!.length < 10000000) {
            setState(() {
              listeFile.add(FileCustom(fileBytes, fileName));
            });
          } else {
            Constant.showAlertDialog(
                context, "Erreur", "le fichier ${fileName} fait plus de 10Mo");
          }
        }
      }
    }
  }
  void sendMessage() {
    String messageText = _messageController.text;
    if(messageText.isNotEmpty){
      PostController.sendPost(messageText,listeFile,widget.post);
      Navigator.pop(context);
    }else{
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Erreur"),
            content: Text("Le champ de texte est obligatoire."),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }
  void _startRecording() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (filePath == null) {
        final appDir = await getTemporaryDirectory();
        filePath = '${appDir.path}/recording.mp3';
      }
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        if (!isRecording) {
          await RecordMp3.instance.start(filePath!, (type) {});
          setState(() {
            isRecording = true;
          });
        }
      }
    }
  }

  void _stopRecording(LongPressEndDetails lped) async {
    if (Platform.isAndroid || Platform.isIOS) {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        if (isRecording) {
          await RecordMp3.instance.stop();
          listeFile.clear();
          isRecording = false;
          if (filePath != null) {
            File file = File(filePath!);
            Uint8List? fileBytes = await file.readAsBytes();
            if (file.existsSync()) {
              listeFile.add(FileCustom(fileBytes, file.uri.pathSegments.last));
            }
          }
          setState(() {});
        }
      }
    }
  }

  Widget file(int index) {
    FileCustom file = listeFile[index];
    bool isImage = file.fileName.toLowerCase().endsWith('.png') ||
        file.fileName.toLowerCase().endsWith('.jpg') ||
        file.fileName.toLowerCase().endsWith('.jpeg') ||
        file.fileName.toLowerCase().endsWith('.gif');

    return Container(
      margin: EdgeInsets.all(SizeMarginPading.p1),
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeBorder.radius),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Stack(children: [
        Positioned(
          // will be positioned in the top right of the container
            top: 0,
            right: 0,
            height: 20,
            width: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error, // border color
                shape: BoxShape.circle,
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    listeFile.removeAt(index);
                  });
                },
                child: Icon(
                  Icons.close,
                  size: 15,
                ),
              ),
            )),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                child: isImage
                    ? Image.memory(
                  file.fileBytes!,
                  fit: BoxFit.cover,
                )
                    : Icon(
                  Icons.insert_drive_file,
                  size: 50,
                ),
              ),
              SizedBox(height: SizeMarginPading.p1),
              Text(
                path.basename(file.fileName),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
      ]),
    );
  }

  Widget SendMessageBar() {
    return Container(
      margin: EdgeInsets.all(SizeMarginPading.h1),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(SizeBorder.radius),
      ),
      child: Column(
        children: [
          if (listeFile.isNotEmpty)
            Wrap(
              direction: Axis.horizontal, // Définir l'orientation horizontale
              spacing: 8.0, // Espace entre les éléments
              runSpacing: 8.0, // Espace entre les lignes
              children: List.generate(listeFile.length, (index) {
                return file(index);
              }),
            ),
          Container(
            margin: EdgeInsets.all(SizeMarginPading.h1),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    // Appeler une fonction pour ajouter des fichiers à la liste listeFile
                    pickAndAddFilesToList();
                  },
                ),
                SizedBox(width: SizeMarginPading.h3),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Votre message',
                    ),
                    onSubmitted: (String messageText) {
                      sendMessage();
                    },
                    textInputAction: TextInputAction.done,
                    minLines: 1,
                    maxLines: 10000,
                  ),
                ),
                SizedBox(width: SizeMarginPading.h3),
                GestureDetector(
                    onLongPress: _startRecording,
                    onLongPressEnd: _stopRecording,
                    onTap: () {
                      sendMessage();
                    },
                    child: Container(
                      padding: EdgeInsets.all(SizeMarginPading.h3),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius:
                          BorderRadius.circular(SizeBorder.radius)),
                      child: Text((isRecording) ? 'Enregistrement' : 'Envoyer',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.background)),
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        arrowReturn: true,
      ),
      body: SingleChildScrollView(
      child: Column(
        children: [
          if (widget.post!=null)
            PostItemListeView(DeleteCallBack: onDeleteItem,post: widget.post!),
          SendMessageBar(),
        ],
      ),
      )
    );
  }

}
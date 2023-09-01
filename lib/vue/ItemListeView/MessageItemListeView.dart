import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:discution_app/Controller/MessagesController.dart';
import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/FileModel.dart';
import 'package:discution_app/Model/MessageModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Api.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/outil/LaunchFile.dart';
import 'package:discution_app/outil/LoginSingleton.dart';
import 'package:discution_app/vue/home/UserDetailView.dart';
import 'package:discution_app/vue/widget/AudioPlayerWidget.dart';
import 'package:discution_app/vue/widget/PhotoView.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageItemListeView extends StatelessWidget {
  final MessageModel message;
  final LoginModel lm = LoginModelProvider.getInstance(() {}).loginModel!;
  late final BuildContext context;
  late Offset _tapPosition;

  MessageItemListeView(
      {super.key, required this.message, required this.context});

  Widget imageFileWidget(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      scale: 0.1,
    );
  }

  Widget videoFileWidget() {
    return Icon(
      Icons.play_circle,
      size: 50,
    );
  }

  Widget audioFileWidget(String url) {
    return AudioPlayerWidget(
      audioUrl: url,
    );
  }

  Widget genericFileWidget() {
    return Icon(
      Icons.insert_drive_file,
      size: 50,
    );
  }

  Widget viewFile(FileModel file, bool isImage, bool isVideo, bool isAudio) {
    if (isImage) {
      return imageFileWidget(
          Constant.baseUrlFilesMessages + "/" + file.linkFile);
    } else if (isVideo) {
      return videoFileWidget();
    } else if (isAudio) {
      return audioFileWidget(
          Constant.baseUrlFilesMessages + "/" + file.linkFile);
    } else {
      return genericFileWidget();
    }
  }

  Widget file(int index) {
    FileModel file = message.files[index];
    bool isImage = file.name.endsWith('.png') ||
        file.name.endsWith('.jpg') ||
        file.name.endsWith('.jpeg') ||
        file.name.endsWith('.gif');
    bool isVideo = file.name.endsWith('.mp4') || file.name.endsWith('.avi');
    bool isaudio = file.name.endsWith('.mp3') || file.name.endsWith('.aac');
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onLongPress: () {
              FileGestion.downloadFile(
                  Constant.baseUrlFilesMessages + "/" + file.linkFile,
                  file.name,
                  context);
            },
            onTap: () {
              if (isImage) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PhotoViewCustom(
                          Constant.baseUrlFilesMessages + "/" + file.linkFile)),
                );
              } else {
                FileGestion.Open(
                    Constant.baseUrlFilesMessages + "/" + file.linkFile,
                    file.name);
              }
            },
            child: Container(
                height: 120, child: viewFile(file, isImage, isVideo, isaudio)),
          ),
          SizedBox(width: SizeMarginPading.h3),
          Container(
            constraints: BoxConstraints(
              minWidth: 80, // Largeur minimale de 80
              maxWidth: 150, // Largeur maximale de 120
            ),
            child: Text(
              file.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  void showEditDialog(BuildContext context) {
    final edit = TextEditingController(text: message.message);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Modifier"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: edit,
                decoration: InputDecoration(labelText: "Nouveau texte"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
            ),
            TextButton(
              child: Text("Valider"),
              onPressed: () {
                MessagesController.edit(message,edit.text, deleteCallBack, callBackError);
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
            ),
          ],
        );
      },
    );
  }


  void DetailUser(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserDetailleView(user)),
    );
  }
  void onDelete(){
    MessagesController.delete(message, deleteCallBack, callBackError);
  }
  void onEdit(){
    showEditDialog(context);
  }
  void deleteCallBack(){

  }
  void callBackError(Exception ex){
    Constant.showAlertDialog(context, "Erreur",
        "erreur lors de la requette a l'api : " + ex.toString());
  }
  void showContextMenu(BuildContext context,var _tapPosition,VoidCallback onDelete, VoidCallback onEdit) {
    if(message.user!=lm.user) return ;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
          _tapPosition & const Size(40, 40), // smaller rect, the touch area
          Offset.zero & overlay.size   // Bigger rect, the entire screen
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          value: "supprimer",
          child: Row(
            children: [
              Icon(Icons.delete),
              SizedBox(width: 8.0),
              Text("Supprimer"),
            ],
          ),
        ),
        PopupMenuItem(
          value: "modifier",
          child: Row(
            children: [
              Icon(Icons.edit),
              SizedBox(width: 8.0),
              Text("Modifier"),
            ],
          ),
        ),
      ],
      elevation: 8.0,
    ).then((selectedValue) {
      if (selectedValue == "supprimer") {
        onDelete(); // Appeler la fonction onDelete
      } else if (selectedValue == "modifier") {
        onEdit(); // Appeler la fonction onEdit
      }
    });
  }
  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: (){
        print("long");
        showContextMenu(context,_tapPosition, onDelete, onEdit);
        },
      onTapDown: _storePosition ,
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: SizeMarginPading.h1, vertical: SizeMarginPading.p2),
        padding: EdgeInsets.all(SizeMarginPading.p1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.background,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                DetailUser(message.user);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: ClipOval(
                  child: Constant.buildImageOrIcon(
                      Constant.baseUrlAvatarUser +
                          "/" +
                          message.user.uniquePseudo,
                      Icon(Icons.account_circle),
                      false),
                ),
              ),
            ),
            SizedBox(width: SizeMarginPading.h3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            DetailUser(message.user);
                          },
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  message.user.pseudo,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: SizeFont.h3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: SizeMarginPading.h3),
                              // Espacement entre le pseudo et la date
                              Flexible(
                                child: Text(
                                  "@" + message.user.uniquePseudo,
                                  style: TextStyle(
                                    fontSize: SizeFont.p1,
                                    // Taille de police plus petite
                                    color: Colors.grey, // Couleur plus discrète
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: SizeMarginPading.h3),
                      // Espacement entre le pseudo et la date
                      Text(
                        DateFormat('MM/dd/yyyy HH:mm')
                            .format(message.date.toLocal()),
                        style: TextStyle(
                          fontSize: SizeFont.p2, // Taille de police plus petite
                          color: Colors.grey, // Couleur plus discrète
                        ),
                      ),
                      SizedBox(width: SizeMarginPading.h3),
                      if (!message.isread)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.message,
                        style: TextStyle(fontSize: 16),
                        softWrap:
                            true, // Permettre le wrapping automatique du texte
                      ),
                      if (message.files.isNotEmpty)
                        Container(
                            width: double.infinity,
                            child: Wrap(
                              direction: Axis.horizontal,
                              // Orientation horizontale
                              alignment: WrapAlignment.start,
                              // Alignement des éléments à gauche
                              spacing: 8,
                              // Espacement horizontal entre les éléments
                              runSpacing: 8,
                              // Espacement vertical entre les lignes
                              children:
                                  List.generate(message.files.length, (index) {
                                return file(index);
                              }),
                            )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

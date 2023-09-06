import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:discution_app/Controller/MessagesController.dart';
import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/FileModel.dart';
import 'package:discution_app/Model/MessageModel.dart';
import 'package:discution_app/Model/MessageParentModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Api.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/outil/LaunchFile.dart';
import 'package:discution_app/outil/LoginSingleton.dart';
import 'package:discution_app/vue/home/UserDetailView.dart';
import 'package:discution_app/vue/home/message/AudioPlayerWidget.dart';
import 'package:discution_app/vue/home/message/FileCustomMessage.dart';
import 'package:discution_app/vue/widget/PhotoView.dart';
import 'package:discution_app/vue/home/message/parent.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageItemListeView extends StatelessWidget {
  final MessageModel message;
  Function setParent;
  final LoginModel lm = LoginModelProvider.getInstance(() {}).loginModel!;
  late final BuildContext context;
  late Offset _tapPosition;

  MessageItemListeView(
      {super.key, required this.message, required this.context,required this.setParent});






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
                onSubmitted: (String value) {
                  MessagesController.edit(
                      message, edit.text, deleteCallBack, callBackError);
                  Navigator.of(context).pop();
                },
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
                MessagesController.edit(
                    message, edit.text, deleteCallBack, callBackError);
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

  void onDelete() {
    MessagesController.delete(message, deleteCallBack, callBackError);
  }

  void onEdit() {
    showEditDialog(context);
  }

  void deleteCallBack() {}

  void callBackError(Exception ex) {
    Constant.showAlertDialog(context, "Erreur",
        "erreur lors de la requette a l'api : " + ex.toString());
  }

  void showMenuSonMessage(BuildContext context, var _tapPosition,
      VoidCallback onDelete, VoidCallback onEdit) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
          _tapPosition & const Size(40, 40), // smaller rect, the touch area
          Offset.zero & overlay.size // Bigger rect, the entire screen
          ),
      items: <PopupMenuEntry>[
        const PopupMenuItem(
          value: "repondre",
          child: Row(
            children: [
              Icon(Icons.reply),
              SizedBox(width: 8.0),
              Text("Repondre"),
            ],
          ),
        ),
        if(message.user == lm.user)
        const PopupMenuItem(
          value: "supprimer",
          child: Row(
            children: [
              Icon(
                Icons.delete,
                color: Colors.red,
              ),
              SizedBox(width: 8.0),
              Text("Supprimer"),
            ],
          ),
        ),
        if(message.user == lm.user)
        const PopupMenuItem(
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
      } else if (selectedValue == "repondre") {
        setParent(MessageParentModel(message.id, message.user, message.message, message.date,message.files));
      }
    });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  Widget Message() {
    return Container(
      padding: EdgeInsets.all(SizeMarginPading.p1),
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
              child: Constant.buildAvatarUser(message.user,30,false),
            ),
          ),
        ),
        SizedBox(width: SizeMarginPading.h3),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
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
                            return FileCustomMessage(message.files[index]);
                          }),
                        )),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        print("long");
        showMenuSonMessage(context, _tapPosition, onDelete, onEdit);
      },
      onDoubleTap: () {
        print("like");
      },
      onTapDown: _storePosition,
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeBorder.radius),
            color: Theme.of(context).colorScheme.background,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Parent(message.parent),
              SizedBox(width: SizeMarginPading.h3),
              Message(),
            ],
          )
      ),
    );
  }

}

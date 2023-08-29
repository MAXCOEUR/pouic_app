import 'dart:io';

import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/FileModel.dart';
import 'package:discution_app/Model/MessageModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/vue/PhotoView.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class MessageItemListeView extends StatelessWidget {
  final MessageModel message;
  final LoginModel lm = Constant.loginModel!;
  late final BuildContext context;

  MessageItemListeView({super.key, required this.message,required this.context});

  Widget file(int index) {
    FileModel file = message.files[index];
    bool isImage = file.name.endsWith('.png') ||
        file.name.endsWith('.jpg') ||
        file.name.endsWith('.jpeg');
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PhotoViewCustom(Constant.baseUrlFilesMessages + "/" + file.linkFile)),
              );
            },
            child:Container(
              height: 120,
              child: isImage
                  ? Image.network(
                Constant.baseUrlFilesMessages + "/" + file.linkFile,
                fit: BoxFit.cover,
              )
                  : Icon(
                Icons.insert_drive_file,
                size: 50,
              ),
            ),
          ),
          SizedBox(height: 5),
          Container(
            constraints: BoxConstraints(
              minWidth: 80, // Largeur minimale de 80
              maxWidth: 150, // Largeur maximale de 120
            ),
            child: Text(
              path.basename(file.name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: ClipOval(
              child: Constant.buildImageOrIcon(
                  Constant.baseUrlAvatarUser + "/" + message.user.uniquePseudo +
                      ".png",
                  Icon(Icons.account_circle)),
            ),
          ),
          SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Ajoutez ici la logique à exécuter lorsque le pseudo est cliqué
                      },
                      child: Text(
                        message.user.pseudo,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 5), // Espacement entre le pseudo et la date
                    Text(
                      DateFormat('MM/dd/yyyy HH:mm')
                          .format(message.date.toLocal()),
                      style: TextStyle(
                        fontSize: 12, // Taille de police plus petite
                        color: Colors.grey, // Couleur plus discrète
                      ),
                    ),
                    SizedBox(width: 5),
                    if (!message.isread)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme
                              .of(context)
                              .colorScheme
                              .error,
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
                      softWrap: true, // Permettre le wrapping automatique du texte
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
                            children: List.generate(
                                message.files.length, (index) {
                              return file(index);
                            }),
                          )

                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


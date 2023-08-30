import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/FileModel.dart';
import 'package:discution_app/Model/MessageModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/outil/LaunchFile.dart';
import 'package:discution_app/vue/widget/AudioPlayerWidget.dart';
import 'package:discution_app/vue/widget/PhotoView.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageItemListeView extends StatelessWidget {
  final MessageModel message;
  final LoginModel lm = Constant.loginModel!;
  late final BuildContext context;

  MessageItemListeView(
      {super.key, required this.message, required this.context});

  Widget imageFileWidget(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
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
      return imageFileWidget(Constant.baseUrlFilesMessages + "/" + file.linkFile);
    } else if (isVideo) {
      return videoFileWidget();
    } else if (isAudio) {
      return audioFileWidget(Constant.baseUrlFilesMessages + "/" + file.linkFile);
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
              height: 120,
              child: viewFile(file,isImage,isVideo,isaudio)
            ),
          ),
          SizedBox(height: 5),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: SizeMarginPading.h1, vertical: SizeMarginPading.p2),
      padding: EdgeInsets.all(SizeMarginPading.p1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.background,
      ),
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
                  Constant.baseUrlAvatarUser +
                      "/" +
                      message.user.uniquePseudo +
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: SizeFont.h3,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    // Espacement entre le pseudo et la date
                    Text(
                      "@" + message.user.uniquePseudo,
                      style: TextStyle(
                        fontSize: SizeFont.p1, // Taille de police plus petite
                        color: Colors.grey, // Couleur plus discrète
                      ),
                    ),
                    SizedBox(width: 5),
                    // Espacement entre le pseudo et la date
                    Text(
                      DateFormat('MM/dd/yyyy HH:mm')
                          .format(message.date.toLocal()),
                      style: TextStyle(
                        fontSize: SizeFont.p2, // Taille de police plus petite
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
    );
  }
}

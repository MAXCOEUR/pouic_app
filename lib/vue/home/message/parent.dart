import 'package:Pouic/Model/MessageParentModel.dart';
import 'package:Pouic/outil/Constant.dart';
import 'package:Pouic/vue/home/message/FileCustomMessage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Parent extends StatelessWidget{
  MessageParentModel? parent;
  Parent(this.parent);

  @override
  Widget build(BuildContext context) {
    if (parent == null) {
      return Container();
    }
    return Container(
      margin: EdgeInsets.all(SizeMarginPading.h1),
      padding: EdgeInsets.all(SizeMarginPading.p1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeBorder.radius),
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // La Row s'ajustera automatiquement à la largeur de ses enfants
        children: [
          SizedBox(width: SizeMarginPading.h1),
          Container(
            width: 1.0, // Largeur de la ligne verticale
            height: 40.0, // Hauteur de la ligne verticale
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          SizedBox(width: SizeMarginPading.h1),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: ClipOval(
              child: Constant.buildAvatarUser(parent!.user,30,true,context)
            ),
          ),
          SizedBox(width: SizeMarginPading.h3),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        parent!.user.pseudo,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: SizeFont.h3,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: SizeMarginPading.h3),
                    // Espacement entre le pseudo et la date
                    Flexible(
                      child: Text(
                        "@" + parent!.user.uniquePseudo,
                        style: TextStyle(
                          fontSize: SizeFont.p1,
                          // Taille de police plus petite
                          color: Theme.of(context).colorScheme.inversePrimary, // Couleur plus discrète
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: SizeMarginPading.h3),
                    // Espacement entre le pseudo et la date
                    Text(
                      DateFormat('MM/dd/yyyy HH:mm')
                          .format(parent!.date.toLocal()),
                      style: TextStyle(
                        fontSize: SizeFont.p2, // Taille de police plus petite
                        color: Theme.of(context).colorScheme.inversePrimary, // Couleur plus discrète
                      ),
                    ),
                    SizedBox(width: SizeMarginPading.h3),
                  ],
                ),
                Text(
                  parent!.message,
                  style: TextStyle(
                    fontSize: SizeFont.p1,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                  softWrap: true, // Permettre le wrapping automatique du texte
                ),
                if (parent!.files.isNotEmpty)
                  Container(
                      //width: double.infinity,
                    child: FileCustomMessage.generateFileCustomMessages(parent!.files,context),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

  }

}
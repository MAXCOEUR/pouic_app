import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:discution_app/Controller/MessagesController.dart';
import 'package:discution_app/Controller/PostController.dart';
import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/FileModel.dart';
import 'package:discution_app/Model/MessageModel.dart';
import 'package:discution_app/Model/MessageParentModel.dart';
import 'package:discution_app/Model/PostModel.dart';
import 'package:discution_app/Model/ReactionModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Api.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/outil/LaunchFile.dart';
import 'package:discution_app/outil/LoginSingleton.dart';
import 'package:discution_app/vue/home/UserDetailView.dart';
import 'package:discution_app/vue/home/message/AudioPlayerWidget.dart';
import 'package:discution_app/vue/home/message/FileCustomMessage.dart';
import 'package:discution_app/vue/home/message/ReactionView.dart';
import 'package:discution_app/vue/widget/EmojiListDialog.dart';
import 'package:discution_app/vue/widget/PhotoView.dart';
import 'package:discution_app/vue/home/message/parent.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:popup_menu/popup_menu.dart';

class PostItemListeView extends StatefulWidget {
  final PostModel post;
  Function DeleteCallBack;

  PostItemListeView({Key? key, required this.post,required this.DeleteCallBack}) : super(key: key);

  @override
  _PostItemListeViewState createState() => _PostItemListeViewState();
}

class _PostItemListeViewState extends State<PostItemListeView> {
  //final PostController messagesController;
  final LoginModel lm = LoginModelProvider.getInstance(() {}).loginModel!;
  late Offset _tapPosition;

  void showEditDialog(BuildContext context) {
    final edit = TextEditingController(text: widget.post.message);

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
                  PostController.edit(
                      widget.post, edit.text, editCallBack, callBackError);
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
                PostController.edit(
                    widget.post, edit.text, editCallBack, callBackError);
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
    PostController.delete(widget.post, deleteCallBack, callBackError);
  }

  void onEdit() {
    showEditDialog(context);
  }

  void deleteCallBack(PostModel post) {
    widget.DeleteCallBack(post);
  }
  void editCallBack(PostModel post_) {
    if(mounted){
      setState(() {
        widget.post.message=post_.message;
      });
    }
  }

  void callBackError(Exception ex) {
    Constant.showAlertDialog(context, "Erreur",
        "erreur lors de la requette a l'api : " + ex.toString());
  }

  void sendReactionCallBack(Reaction reaction){
    setState(() {
      widget.post.amIlike=true;
      if (widget.post.addReaction(reaction)){
        widget.post.nbr_reaction++;
      }
    });
  }
  void deleteReactionCallBack(){
    setState(() {
      widget.post.amIlike=false;
      widget.post.deleteReaction(lm.user.uniquePseudo);
      widget.post.nbr_reaction--;
    });
  }
/*  void deleteReaction(){
    messagesController.deleteReactionToSocket(message.id_conversation, message.id);
  }*/

  void showMenuSonMessage(BuildContext context, var _tapPosition,
      VoidCallback onDelete, VoidCallback onEdit) {
    final RenderBox overlay = context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
          _tapPosition & const Size(40, 40), // smaller rect, the touch area
          Offset.zero & overlay.size // Bigger rect, the entire screen
          ),
      items: <PopupMenuEntry>[
        if (widget.post.user == lm.user)
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
        if (widget.post.user == lm.user)
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
      }
    });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  void _showPopupMenu(TapDownDetails details) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(details.globalPosition, details.globalPosition),
      Offset.zero & overlay.size,
    );

    await showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: "emoji_list",
          child: EmojiList(
            popularEmojis: Constant.popularEmojis,
            onEmojiSelected: (String emoji) {PostController.sendReaction(widget.post,emoji,sendReactionCallBack,callBackError);},
          ),
        ),
      ],
    );

    // Gérez la valeur sélectionnée ici si nécessaire
  }

  Widget Post(PostModel post) {
    return Container(
      padding: EdgeInsets.all(SizeMarginPading.h3),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              DetailUser(post.user);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: ClipOval(
                child: Constant.buildAvatarUser(post.user, 30, false),
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
                        post.user.pseudo,
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
                        "@" + post.user.uniquePseudo,
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
                          .format(post.date.toLocal()),
                      style: TextStyle(
                        fontSize: SizeFont.p2, // Taille de police plus petite
                        color: Colors.grey, // Couleur plus discrète
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.message,
                      style: TextStyle(fontSize: 16),
                      softWrap:
                          true, // Permettre le wrapping automatique du texte
                    ),
                    if (post.files.isNotEmpty)
                      Container(
                          child: FileCustomMessage.generateFileCustomMessages(
                              post.files, context)),
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        print("repondre");
                      },
                      child: Row(
                        children: [
                          Icon(Icons.reply, size: 16.0), // Icône plus petite
                          SizedBox(width: 2.0), // Espace réduit
                          Text(Constant.formatNumber(widget.post.nbr_reponse),
                              style: TextStyle(fontSize: 12.0)), // Texte plus petit
                        ],
                      ),
                    ),
                    SizedBox(width: 32.0), // Espace entre les boutons
                    InkWell(
                      onTapDown: (details) {
                        if(widget.post.amIlike){
                          PostController.deleteReaction(widget.post,deleteReactionCallBack,callBackError);
                        }else{
                          _storePosition(details);
                          _showPopupMenu(details);
                        }

                        },
                      child: Row(
                        children: [
                          Icon(
                            widget.post.amIlike
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16.0, // Icône plus petite
                            color: widget.post.amIlike ? Colors.red : null,
                          ),
                          SizedBox(width: 2.0), // Espace réduit
                          Text(Constant.formatNumber(widget.post.nbr_reaction),
                              style: TextStyle(fontSize: 12.0)), // Texte plus petit
                        ],
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onLongPress: () {
          print("long");
          showMenuSonMessage(context, _tapPosition, onDelete, onEdit);
        },
        onTapDown: _storePosition,
        child: Container(
          //padding: EdgeInsets.all(SizeMarginPading.h3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeBorder.radius),
            color: Theme.of(context).colorScheme.background,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.post.parent != null)
                PostItemListeView(post: widget.post.parent!,DeleteCallBack: widget.DeleteCallBack),
              SizedBox(width: SizeMarginPading.h3),
              Post(widget.post),
            ],
          ),
        ),
      ),
    ]);
  }
}

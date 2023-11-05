import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:Pouic/Controller/MessagesController.dart';
import 'package:Pouic/Controller/PostController.dart';
import 'package:Pouic/Model/ConversationModel.dart';
import 'package:Pouic/Model/FileModel.dart';
import 'package:Pouic/Model/MessageModel.dart';
import 'package:Pouic/Model/MessageParentModel.dart';
import 'package:Pouic/Model/PostModel.dart';
import 'package:Pouic/Model/ReactionModel.dart';
import 'package:Pouic/Model/UserModel.dart';
import 'package:Pouic/outil/Api.dart';
import 'package:Pouic/outil/Constant.dart';
import 'package:Pouic/outil/LaunchFile.dart';
import 'package:Pouic/outil/LoginSingleton.dart';
import 'package:Pouic/vue/home/UserDetailView.dart';
import 'package:Pouic/vue/home/message/AudioPlayerWidget.dart';
import 'package:Pouic/vue/home/message/FileCustomMessage.dart';
import 'package:Pouic/vue/home/message/ReactionView.dart';
import 'package:Pouic/vue/home/post/CreatePost.dart';
import 'package:Pouic/vue/home/post/PostChildrenView.dart';
import 'package:Pouic/vue/widget/EmojiListDialog.dart';
import 'package:Pouic/vue/widget/PhotoView.dart';
import 'package:Pouic/vue/home/message/parent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:url_launcher/url_launcher.dart';

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
  void onCopie(){
    Clipboard.setData(ClipboardData(text: widget.post.message));
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
      VoidCallback onDelete, VoidCallback onEdit, VoidCallback onCopy) {
    final RenderBox overlay = context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
          _tapPosition & const Size(40, 40), // smaller rect, the touch area
          Offset.zero & overlay.size // Bigger rect, the entire screen
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          value: "copier",
          child: Row(
            children: [
              Icon(Icons.copy),
              SizedBox(width: 8.0),
              Text("Copier"),
            ],
          ),
        ),
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
      } else if (selectedValue == "copier") {
        onCopy(); // Appeler la fonction onCopy
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
                child: Constant.buildAvatarUser(post.user, 30, false,context),
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
                    Linkify(
                      onOpen: (link) async {
                        if (await canLaunch(link.url)) {
                          await launch(link.url);
                        } else {
                          throw 'Impossible d\'ouvrir le lien : ${link.url}';
                        }
                      },
                      text: post.message,
                      style: TextStyle(fontSize: 16),
                      linkStyle: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                          fontSize: 16,
                      ),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CreatePost(post)),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.reply), // Icône plus petite
                          SizedBox(width: 2.0), // Espace réduit
                          Text(Constant.formatNumber(widget.post.nbr_reponse),
                              ), // Texte plus petit
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
                             // Icône plus petite
                            color: widget.post.amIlike ? Colors.red : null,
                          ),
                          SizedBox(width: 2.0), // Espace réduit
                          Text(Constant.formatNumber(widget.post.nbr_reaction),
                              ), // Texte plus petit
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
          showMenuSonMessage(context, _tapPosition, onDelete, onEdit,onCopie);
        },
        onTapDown: _storePosition,
        onTap: (){Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostChildrenView(post:widget.post)),
        );},
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

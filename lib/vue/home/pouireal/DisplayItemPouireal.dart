import 'package:pouic/Model/pouireal_model.dart';
import 'package:pouic/vue/home/pouireal/pouireal_viewmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../Model/ReactionModel.dart';
import '../../../Model/UserModel.dart';
import '../../../outil/Constant.dart';
import '../../../outil/LoginSingleton.dart';
import '../../widget/EmojiListDialog.dart';
import '../UserDetailView.dart';

class DisplayItemPouirealView extends StatefulWidget {
  final PouirealModel pouirealModel;
  final Function onDelete;

  DisplayItemPouirealView({
    super.key,
    required this.pouirealModel,
    required this.onDelete,
  });

  @override
  DisplayItemPouirealViewState createState() => DisplayItemPouirealViewState();
}

class DisplayItemPouirealViewState extends State<DisplayItemPouirealView> {
  final LoginModel lm = LoginModelProvider.getInstance(() {}).loginModel!;
  PouirealViewModel pouirealViewModel = PouirealViewModel();
  Offset _tapPosition = Offset(0, 0);

  String image1 = Constant.baseUrlPouireal + "/";
  String image2 = Constant.baseUrlPouireal + "/";

  double _imageLeft = 16.0;
  double _imageTop = 16.0;

  bool isFlipped = false;

  void DetailUser(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserDetailleView(user)),
    );
  }

  void showMenuSonMessage() {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
          _tapPosition & const Size(40, 40), // smaller rect, the touch area
          Offset.zero & overlay.size // Bigger rect, the entire screen
          ),
      items: <PopupMenuEntry>[
        if (widget.pouirealModel.user == lm.user)
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
        PopupMenuItem(
          value: "emojis",
          child: EmojiList(
            popularEmojis: Constant.popularEmojis,
            // Liste d'exemple d'emojis populaires
            onEmojiSelected: (emoji) {
              Stream<Reaction> stream = pouirealViewModel.postPouirealReaction(
                  widget.pouirealModel, emoji);
              stream.listen((reaction) {
                List<Reaction> reacRemove = [];
                for (Reaction reac in widget.pouirealModel.reactions) {
                  if (reac.user == reaction.user) {
                    reacRemove.add(reac);
                  }
                }
                for (Reaction reac in reacRemove) {
                  widget.pouirealModel.reactions.remove(reac);
                }
                setState(() {
                  widget.pouirealModel.reactions.add(reaction);
                });
              }, onError: (error) {
                print("Erreur : $error");
              });
            },
          ),
        ),
      ],
      elevation: 8.0,
    ).then((selectedValue) {
      if (selectedValue == "supprimer") {
        widget.onDelete(widget.pouirealModel); // Appeler la fonction onDelete
      }
    });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  Widget createCardReaction(BuildContext context, int index) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(right: 8, top: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: ClipOval(
            child: Constant.buildAvatarUser(
                widget.pouirealModel.reactions[index].user, 50, false, context),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(5.0), // Padding autour du texte
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white
                  .withOpacity(0.5), // Couleur blanc semi-transparente
            ),
            child: Text(
              widget.pouirealModel.reactions[index].reaction,
              style: TextStyle(fontSize: 16), // Ajustez la taille du texte ici
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    image1 += widget.pouirealModel.picture1 ?? "";
    image2 += widget.pouirealModel.picture2 ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onDoubleTapDown: _storePosition,
        onDoubleTap: () {
          showMenuSonMessage();
        },
        onLongPress: () {
          showMenuSonMessage();
        },
        onTapDown: _storePosition,
        child: Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius:
                  BorderRadius.circular(16), // Définir le rayon du border
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        DetailUser(widget.pouirealModel.user);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: EdgeInsets.only(right: 8, bottom: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: ClipOval(
                          child: Constant.buildAvatarUser(
                              widget.pouirealModel.user, 30, false, context),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        widget.pouirealModel.user.pseudo,
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
                        "@" + widget.pouirealModel.user.uniquePseudo,
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
                          .format(widget.pouirealModel.date.toLocal()),
                      style: TextStyle(
                        fontSize: SizeFont.p2,
                        // Taille de police plus petite
                        color: Colors.grey, // Couleur plus discrète
                      ),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: isFlipped ? image2 : image1,
                      key: Key(isFlipped ? image2 : image1),
                      fit: BoxFit.contain,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    // Bouton pour inverser les images
                    Positioned(
                      left: _imageLeft,
                      top: _imageTop,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isFlipped = !isFlipped; // Inverser l'état isFlipped
                          });
                        },
                        onPanUpdate: (details) {
                          setState(() {
                            // Mettez à jour la position de l'image en fonction du déplacement
                            _imageLeft += details.delta.dx;
                            _imageTop += details.delta.dy;
                          });
                        },
                        child: CachedNetworkImage(
                          imageUrl: isFlipped ? image1 : image2,
                          key: Key(isFlipped ? image1 : image2),
                          width: 100.0,
                          fit: BoxFit.contain,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 60,
                  child: CustomScrollView(
                    scrollDirection: Axis.horizontal,
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          createCardReaction,
                          childCount: widget.pouirealModel.reactions.length,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 8),
                  padding: EdgeInsets.all(8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    // Définir le rayon du border
                    border: Border.all(
                      // Ajouter une bordure
                      color: Colors.black, // Couleur de la bordure
                      width: 2, // Largeur de la bordure
                    ),
                  ),
                  child: Text(
                    widget.pouirealModel.description ?? "",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )));
  }
}

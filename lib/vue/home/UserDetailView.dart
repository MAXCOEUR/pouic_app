import 'dart:io';

import 'package:pouic/Controller/ConversationC.dart';
import 'package:pouic/Controller/PostController.dart';
import 'package:pouic/Controller/UserC.dart';
import 'package:pouic/Model/ConversationModel.dart';
import 'package:pouic/Model/PostListeModel.dart';
import 'package:pouic/Model/PostModel.dart';
import 'package:pouic/Model/UserModel.dart';
import 'package:pouic/outil/Constant.dart';
import 'package:pouic/outil/LoginSingleton.dart';
import 'package:pouic/outil/SocketSingleton.dart';
import 'package:pouic/vue/CreateUserVue.dart';
import 'package:pouic/vue/home/message/MessagerieView.dart';
import 'package:pouic/vue/home/post/PostItemListeView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widget/CustomAppBar.dart';

class UserDetailleView extends StatefulWidget {
  final LoginModel lm = LoginModelProvider.getInstance(() {}).loginModel!;
  final User user;

  UserDetailleView(this.user, {super.key});

  @override
  State<UserDetailleView> createState() => _UserListeViewState();
}

class _UserListeViewState extends State<UserDetailleView> {
  UserC userCreate = UserC();
  ConversationC conversationC = ConversationC();

  late PostController postsController;
  PostListe postListe = PostListe();

  final ScrollController _scrollController = ScrollController();
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    if (widget.user.sont_amis == null) {
      userCreate.isFriend(widget.user, reponseIsAmis, reponseError);
    }

    postsController = PostController(postListe, reponseUpdate);

    postsController.initListeUserPost(widget.user, reponseUpdate, reponseError);
    _scrollController.addListener(_onScroll);
  }

  void reponseIsAmis(bool isamis) {
    if (mounted) {
      setState(() {
        widget.user.sont_amis = isamis;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoadingMore) {
      // Lorsque l'utilisateur atteint le bas de la liste
      setState(() {
        isLoadingMore =
            true; // Définir isLoadingMore à true pour indiquer le chargement
      });

      postsController.addUserPost_inListe(
          postListe.posts[postListe.posts.length - 1].id,
          widget.user,
          reponseScroll,
          reponseError);
    }
  }
  reponseScroll() {
    if (mounted) {
      setState(() {isLoadingMore = false;});
    }
  }

  reponseError(Exception ex) {
    Constant.showAlertDialog(context, "Erreur",
        "erreur lors de la requette a l'api : " + ex.toString());
  }

  reponseUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget UserView() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Container(
            width: 125,
            height: 125,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: ClipOval(
                child: Constant.buildAvatarUser(widget.user, 100, true,context)),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // Étirer les enfants à la largeur de la Column
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.all(SizeMarginPading.h3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(SizeBorder.radius),
                ),
                child: Container(
                  padding: EdgeInsets.all(SizeMarginPading.h1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.pseudo,
                        style: TextStyle(
                          fontSize: SizeFont.h3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "@" + widget.user.uniquePseudo,
                        style: TextStyle(fontSize: SizeFont.p1),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.user.bio != null)
                Container(
                  margin: EdgeInsets.all(SizeMarginPading.h3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(SizeBorder.radius),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(SizeMarginPading.h1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "bio : ",
                          style: TextStyle(
                              fontSize: SizeFont.p1,
                              fontWeight: FontWeight.bold),
                        ),
                        Linkify(
                          onOpen: (link) async {
                            if (await canLaunch(link.url)) {
                              await launch(link.url);
                            } else {
                              throw 'Impossible d\'ouvrir le lien : ${link.url}';
                            }
                          },
                          text: widget.user.bio!,
                          style: TextStyle(fontSize: SizeFont.p1),
                          linkStyle: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontSize: SizeFont.p1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: SizeMarginPading.h1),
        // Espace entre les textes et les boutons
        if (widget.user == widget.lm.user)
          profilButtonWidget()
        else if (widget.user.sont_amis == null || widget.user.sont_amis == false)
          ajouterAmisButtonWidget()
        else
          amisButtonsWidget(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        arrowReturn: true,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              UserView(),
            ]),
          ),
          if (postListe.posts.length==0)
            SliverList(
              delegate: SliverChildListDelegate([
                Text("L'utilisateur n'a fait aucun post."),
              ]),
            ),
          if (postListe.posts.length>0)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                PostModel post = postListe.posts[index];
                return Container(
                  child: PostItemListeView(
                      post: post, DeleteCallBack: onDeleteItem),
                  margin: EdgeInsets.all(SizeMarginPading.h3),
                );
              },
              childCount: postListe.posts.length,
            ),
          ),
        ],
      ),
    );
  }

  void onDeleteItem(PostModel post) {
    if (mounted) {
      setState(() {
        postsController.deletePost(post);
      });
    }
  }

  Widget amisButtonsWidget() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(SizeMarginPading.p1),
          child: ElevatedButton(
            onPressed: () {
              Conversation conversation = Conversation(
                  0,
                  widget.lm.user.pseudo + " " + widget.user.pseudo,
                  widget.lm.user.uniquePseudo,
                  null,
                  0);

              conversationC.create(conversation, null,
                  reponseCreateConversation, retourCreateConversationError);
            },
            child: Icon(Icons.chat),
          ),
        ),
        Container(
          margin: EdgeInsets.all(SizeMarginPading.p1),
          child: ElevatedButton(
            onPressed: () {
              userCreate.deleteAmis(
                  widget.user, retourSuppretionAmis, retourSuppretionAmisError);
            },
            child: Icon(Icons.cancel),
          ),
        ),
      ],
    );
  }

  void reponseCreateConversation(Conversation conversation) {
    print("la conversation a été creer");
    SocketSingleton.instance.socket
        .emit('joinConversation', {'idConversation': conversation.id});
    conversationC.addUser(
        widget.user, conversation, reponseAddAmis, retourAddAmisError);
  }

  void reponseAddAmis(User user, Conversation conversation) {
    print("la conversation a été creer");
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MessagerieView(conv: conversation)),
    );
  }

  Widget ajouterAmisButtonWidget() {
    return Container(
      margin: EdgeInsets.all(SizeMarginPading.p1),
      child: ElevatedButton(
        onPressed: () {
          userCreate.addAmis(widget.user, retourAddAmis, retourAddAmisError);
        },
        child: Icon(Icons.person_add),
      ),
    );
  }
  Widget profilButtonWidget() {
    return Container(
      margin: EdgeInsets.all(SizeMarginPading.p1),
      child: ElevatedButton(
        onPressed: () async {
          // Utilisez await pour attendre la fermeture de la page CreateUserVue
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateUserVue(created: false, user: widget.lm.user),
            ),
          );

          // Après la fermeture de CreateUserVue, rafraîchissez la page parente avec setState
          setState(() {
            // Placez ici le code de rafraîchissement que vous souhaitez effectuer
          });
        },
        child: Icon(Icons.person),
      ),

    );
  }

  void retourSuppretionAmis(User user) {
    setState(() {
      widget.user.sont_amis = false;
    });
  }

  void retourSuppretionAmisError(Exception ex) {
    Constant.showAlertDialog(context, "Erreur",
        "erreur lors de la requette a l'api : " + ex.toString());
  }

  void retourAddAmis(User u) {
    Constant.showAlertDialog(context, "demande envoyé",
        "la demande a été envoyé a " + u.uniquePseudo);
  }

  void retourAddAmisError(Exception ex) {
    Constant.showAlertDialog(context, "Erreur",
        "erreur lors de la requette a l'api : " + ex.toString());
  }

  void retourCreateConversationError(Exception ex) {
    Constant.showAlertDialog(context, "Erreur",
        "erreur lors de la requette a l'api : " + ex.toString());
  }
}

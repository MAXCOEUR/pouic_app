import 'dart:io';

import 'package:discution_app/Controller/ConversationC.dart';
import 'package:discution_app/Controller/UserC.dart';
import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/outil/LoginSingleton.dart';
import 'package:discution_app/outil/SocketSingleton.dart';
import 'package:discution_app/vue/home/message/MessagerieView.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        arrowReturn: true,
      ),
      body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: ClipOval(
                      child: Constant.buildAvatarUser(widget.user, 150, true)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      margin: EdgeInsets.all(SizeMarginPading.h1),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(SizeBorder.radius),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(SizeMarginPading.h1),
                        child: Column(
                          children: [
                            Text(widget.user.pseudo,
                                style: TextStyle(
                                  fontSize: SizeFont.h3,
                                  fontWeight: FontWeight.bold,
                                )),
                            Text("@" + widget.user.uniquePseudo,
                                style: TextStyle(fontSize: SizeFont.p1)),
                          ],
                        ),
                      )),
                  if (widget.user.bio != null)
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(SizeMarginPading.h1),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius:
                              BorderRadius.circular(SizeBorder.radius),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(SizeMarginPading.h1),
                          child: Row(
                            children: [
                              Text(
                                "bio : ",
                                style: TextStyle(
                                    fontSize: SizeFont.p1,
                                    fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Text(
                                  widget.user.bio!,
                                  style: TextStyle(fontSize: SizeFont.p1),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: SizeMarginPading.h1),
              // Espace entre les textes et les boutons
              if (widget.user.sont_amis == null ||
                  widget.user.sont_amis == false)
                ajouterAmisButtonWidget()
              else
                amisButtonsWidget(),
            ],
          ),

      ),
    );
  }

  Widget amisButtonsWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            Conversation conversation = Conversation(
                0,
                widget.lm.user.pseudo + " " + widget.user.pseudo,
                widget.lm.user.uniquePseudo,
                null,
                0);

            conversationC.create(conversation, null, reponseCreateConversation,
                retourCreateConversationError);
          },
          child: Text("Nouvelle Conversation"),
        ),
        SizedBox(width: SizeMarginPading.h1), // Espace entre les boutons
        ElevatedButton(
          onPressed: () {
            userCreate.deleteAmis(
                widget.user, retourSuppretionAmis, retourSuppretionAmisError);
          },
          child: Text("Supprimer des Amis"),
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
    return ElevatedButton(
      onPressed: () {
        userCreate.addAmis(widget.user, retourAddAmis, retourAddAmisError);
      },
      child: Text("Ajouter en Amis"),
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

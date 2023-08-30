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

class UserDetailleView extends StatefulWidget{
  final LoginModel lm= LoginModelProvider.instance.loginModel!;
  final User user;
  UserDetailleView(this.user,{super.key});

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
      body: Center(
        child: Column(
          children: [
              Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child:Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: ClipOval(
                  child: Constant.buildImageOrIcon(
                      Constant.baseUrlAvatarUser+"/"+widget.user.uniquePseudo+".png",
                      Icon(Icons.account_circle)
                  ),
                ),
              ),
              ),
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(SizeBorder.radius),
        ),
        child:Container(
          padding: EdgeInsets.all(SizeMarginPading.h1),
          child: Column(
            children:
            [
              Text("@" + widget.user.uniquePseudo,style: TextStyle(fontSize: SizeFont.h3)),
              Text("Pseudo : " + widget.user.pseudo,style: TextStyle(fontSize: SizeFont.p1)),
            ],
          ),
        )
      ),

            SizedBox(height: SizeMarginPading.h1), // Espace entre les textes et les boutons
            if (widget.user.sont_amis == null || widget.user.sont_amis == false)
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
            Conversation conversation = Conversation(0, widget.lm.user.pseudo+" "+widget.user.pseudo, widget.lm.user.uniquePseudo, 0);

            conversationC.create(conversation,File(""), reponseCreateConversation, retourCreateConversationError);
          },
          child: Text("Nouvelle Conversation"),
        ),
        SizedBox(width: SizeMarginPading.h1), // Espace entre les boutons
        ElevatedButton(
          onPressed: () {
            userCreate.deleteAmis(widget.user, retourSuppretionAmis,retourSuppretionAmisError);
          },
          child: Text("Supprimer des Amis"),
        ),
      ],
    );
  }
  void reponseCreateConversation(Conversation conversation) {
    print("la conversation a été creer");
    SocketSingleton.instance.socket.emit('joinConversation', {'idConversation': conversation.id});
    conversationC.addUser(widget.user,conversation, reponseAddAmis,retourAddAmisError);
  }
  void reponseAddAmis(User user,Conversation conversation) {
    print("la conversation a été creer");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MessagerieView(conv:conversation)),
    );
  }

  Widget ajouterAmisButtonWidget() {
    return ElevatedButton(
      onPressed: () {
        userCreate.addAmis(widget.user, retourAddAmis,retourAddAmisError);
      },
      child: Text("Ajouter en Amis"),
    );
  }

  void retourSuppretionAmis(User user){
    setState(() {
      widget.user.sont_amis=false;
    });
  }
  void retourSuppretionAmisError(Exception ex){
    Constant.showAlertDialog(context,"Erreur","erreur lors de la requette a l'api : "+ex.toString());
  }
  void retourAddAmis(User u){
    Constant.showAlertDialog(context,"demande envoyé","la demande a été envoyé a "+u.uniquePseudo);
  }
  void retourAddAmisError(Exception ex){
    Constant.showAlertDialog(context,"Erreur","erreur lors de la requette a l'api : "+ex.toString());
  }
  void retourCreateConversationError(Exception ex){
    Constant.showAlertDialog(context,"Erreur","erreur lors de la requette a l'api : "+ex.toString());
  }
}
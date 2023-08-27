import 'package:discution_app/Controller/UserC.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:flutter/material.dart';

import '../widget/CustomAppBar.dart';

class UserDetailleView extends StatefulWidget{
  final LoginModel lm= Constant.loginModel!;
  final User user;
  UserDetailleView(this.user,{super.key});

  @override
  State<UserDetailleView> createState() => _UserListeViewState();
}

class _UserListeViewState extends State<UserDetailleView> {

  UserC userCreate = UserC();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        userImageBytes: widget.lm.user.Avatar,
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
                  child: widget.user.Avatar != null
                      ? Image.memory(
                    widget.user.Avatar!,
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.account_circle, size: 150),
                ),
              ),
              ),
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child:Container(
          child: Column(
            children:
            [
              Text("Pseudo Unique : " + widget.user.uniquePseudo),
              Text("Pseudo : " + widget.user.pseudo),
            ],
          ),
        )
      ),
      ),

            SizedBox(height: 20), // Espace entre les textes et les boutons
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
            // Action à effectuer pour le bouton "Nouvelle Conversation"
          },
          child: Text("Nouvelle Conversation"),
        ),
        SizedBox(width: 20), // Espace entre les boutons
        ElevatedButton(
          onPressed: () {
            userCreate.deleteAmis(widget.user, retourSuppretionAmis,retourSuppretionAmisError);
          },
          child: Text("Supprimer des Amis"),
        ),
      ],
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

  void retourSuppretionAmis(){
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
}
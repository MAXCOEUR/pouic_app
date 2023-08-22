import 'package:dio/dio.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/vue/CreateUserVue.dart';
import 'package:flutter/material.dart';
import 'package:discution_app/vue/ConversationsVue.dart';

import '../Controller/LoginController.dart';
import 'dart:convert';



class LoginVue extends StatefulWidget {
  const LoginVue({super.key});

  final String title="Login";

  @override
  State<LoginVue> createState() => _LoginVueState();
}

class _LoginVueState extends State<LoginVue> {
  final userName_Email = TextEditingController();
  final mdp = TextEditingController();

  final Login loginController=Login();

  @override
  void dispose() {
    userName_Email.dispose();
    mdp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: userName_Email,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Entrée votre username ou mail',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                obscureText: true,
                controller: mdp,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Entrée votre mdp',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Code à exécuter lorsque le bouton est pressé
                print('le username ou email est : '+userName_Email.text+" | le mdp est : "+mdp.text);
                loginUser();

                //Navigator.push(
                //context,
                //MaterialPageRoute(builder: (context) => const ConversationsVue()),
                //);
              },
              child: Text('validé'),
            ),ElevatedButton(
              onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateUserVue()),
                );
              },
              child: Text('créer sont compte'),
            ),
          ],
        ),
      ),
    );
  }
  void loginUser() {
    loginController.ask('nouveauPseudo', 'nouveauMotDePasse',reponseLoginUser);
  }
  void reponseLoginUser(LoginModel? lm){
    if(lm!=null){
      print(lm.toJsonString());
    }
    else{
      showAlertDialog(context,"Erreur","erreur lors de la requette a l'api");
    }
  }


  showAlertDialog(BuildContext context,String titre,String erreur) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(titre),
      content: Text(erreur),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}



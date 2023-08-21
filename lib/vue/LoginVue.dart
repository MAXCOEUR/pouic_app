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


    loginController.ask('nouveauPseudo', 'nouveauMotDePasse').then((response) {
      if (response != null) {
        print('Réponse : ${response.data.toString()}');
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        print('Réponse : ${jsonData["token"]}');

        dynamic userMap=jsonData["user"];

        User u = User(userMap["email"], userMap["uniquePseudo"], userMap["pseudo"], userMap["Avatar"]);
        print(u.toJsonString());
      } else {
        print('Échec de la requête');
      }
    });
  }

}

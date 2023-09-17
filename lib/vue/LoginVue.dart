
import 'package:dio/dio.dart';
import 'package:Pouic/Model/UserModel.dart';
import 'package:Pouic/outil/LoginSingleton.dart';
import 'package:Pouic/vue/CreateUserVue.dart';
import 'package:flutter/material.dart';
import 'package:Pouic/vue/home/HomeView.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Controller/LoginController.dart';

import '../outil/Constant.dart';



class LoginVue extends StatefulWidget {
  Function updateMain;
  LoginVue({super.key,required this.updateMain});
  final String title="Login";

  @override
  State<LoginVue> createState() => _LoginVueState();
}

class _LoginVueState extends State<LoginVue> {
  final userName_Email = TextEditingController();
  final mdp = TextEditingController();

  User user = User(email:"", uniquePseudo: "",pseudo:  "",bio: null,extension: null);

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
        //backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Image.asset(
                    'assets/logo.png',
                  )),
            ),
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
            Container(
              margin: EdgeInsets.all(SizeMarginPading.h3),
              child: ElevatedButton(
                onPressed: () {
                  // Code à exécuter lorsque le bouton est pressé
                  print('le username ou email est : ' +
                      userName_Email.text +
                      " | le mdp est : " +
                      mdp.text);
                  loginUser();
                },
                child: Text('valider'),
              ),
            ),
            Container(
              margin: EdgeInsets.all(SizeMarginPading.h3),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CreateUserVue(created: true, user: user)),
                  );
                },
                child: Text('créer sont compte'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void loginUser() {
    loginController.ask(userName_Email.text, mdp.text,reponseLoginUser,reponseLoginUserErreur);
  }
  void reponseLoginUser(LoginModel lm){
    LoginModelProvider.getInstance((){}).setLoginModel(lm);
    widget.updateMain();
  }
  void reponseLoginUserErreur(DioException ex){
    if(ex.response!=null && ex.response!.data["message"] != null){
      Constant.showAlertDialog(context,"Erreur",ex.response!.data["message"]);
    }
    else{
      Constant.showAlertDialog(context, "Erreur", "Une erreur s'est produite lors de la connextion");
    }
  }
}



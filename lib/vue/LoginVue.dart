
import 'package:Pouic/vue/ResetPassword.dart';
import 'package:Pouic/vue/widget/LoadingDialog.dart';
import 'package:dio/dio.dart';
import 'package:Pouic/Model/UserModel.dart';
import 'package:Pouic/outil/LoginSingleton.dart';
import 'package:Pouic/vue/CreateUserVue.dart';
import 'package:flutter/material.dart';
import 'package:Pouic/vue/home/HomeView.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Controller/LoginController.dart';

import '../HomeTmp.dart';
import '../outil/Constant.dart';



class LoginVue extends StatefulWidget {
  LoginVue({super.key});
  final String title="Login";
  static String HIVE_LOGIN="LOGIN";

  @override
  State<LoginVue> createState() => _LoginVueState();
}

class _LoginVueState extends State<LoginVue> {
  final userName_Email = TextEditingController();
  final mdp = TextEditingController();

  User user = User(email:"", uniquePseudo: "",pseudo:  "",bio: null,extension: null);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Login loginController=Login();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loginUserHive();
  }

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
      body: (_isLoading)?LoadingDialog(): SingleChildScrollView(
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
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Champ de texte pour l'username ou l'email
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: TextFormField(
                        controller: userName_Email,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Entrez votre username ou mail',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ce champ est obligatoire.';
                          }
                          return null; // Retourne null s'il n'y a pas d'erreur
                        },
                      ),
                    ),

                    // Champ de texte pour le mot de passe
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: TextFormField(
                        obscureText: true,
                        controller: mdp,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Entrez votre mdp',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ce champ est obligatoire.';
                          }
                          return null; // Retourne null s'il n'y a pas d'erreur
                        },
                      ),
                    ),

                    // Bouton "Valider"
                    Container(
                      margin: EdgeInsets.all(SizeMarginPading.h3),
                      child: ElevatedButton(
                        onPressed: () {
                          // Valide le formulaire avant d'exécuter le code
                          if (_formKey.currentState!.validate()) {
                            // Code à exécuter lorsque le bouton est pressé
                            print('le username ou email est : ' +
                                userName_Email.text +
                                " | le mdp est : " +
                                mdp.text);
                            loginUser();
                          }
                        },
                        child: Text('Valider'),
                      ),
                    ),
                  ],
                ),
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
                child: Text('Créer son compte'),
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
                            ResetPassword()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey, // Couleur de fond différente
                ),
                child: Text(
                  'Mot de passe Perdu ?',
                  style: TextStyle(
                    color: Colors.white, // Couleur de texte blanc
                    fontSize: 16.0, // Taille de police
                    fontStyle: FontStyle.italic, // Style de police italique
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
  void loginUserHive() async{
    try{
      setState(() {
        _isLoading=true;
      });
      var hiveBox = await Hive.openBox(LoginVue.HIVE_LOGIN);
      String email = hiveBox.get("email");
      String mdp = hiveBox.get("mdp");
      loginController.ask(email, mdp,reponseLoginUser,reponseLoginUserErreurHive);
    }catch(ex){
      print(ex);
      setState(() {
        _isLoading=false;
      });
    }

  }
  void loginUser() async {
    var hiveBox = await Hive.openBox(LoginVue.HIVE_LOGIN);
    setState(() {
      _isLoading=true;
    });
    loginController.ask(userName_Email.text, mdp.text,reponseLoginUser,reponseLoginUserErreur);
    hiveBox.put("email", userName_Email.text);
    hiveBox.put("mdp", mdp.text);
  }
  void reponseLoginUser(LoginModel lm){
    LoginModelProvider.getInstance((){}).setLoginModel(lm);
    HomeTmp.update(context);
    setState(() {
      _isLoading=false;
    });
  }
  void reponseLoginUserErreur(DioException ex){
    setState(() {
      _isLoading=false;
    });
    if(ex.response!=null && ex.response!.data["message"] != null){
      Constant.showAlertDialog(context,"Erreur",ex.response!.data["message"]);
    }
    else{
      Constant.showAlertDialog(context, "Erreur", "Une erreur s'est produite lors de la connexion");
    }
  }
  void reponseLoginUserErreurHive(DioException ex){
    setState(() {
      _isLoading=false;
    });
  }
}



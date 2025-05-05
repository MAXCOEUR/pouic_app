import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pouic/outil/LoginSingleton.dart';
import 'package:pouic/vue/LoginVue.dart';
import 'package:pouic/vue/home/HomeView.dart';
import 'package:flutter/material.dart';

import 'Controller/LoginController.dart';
import 'outil/Constant.dart';

class HomeTmp extends StatefulWidget {

  static const String TOKEN_KEY = "auth_token";
  static void update(BuildContext context) {
    final state = context.findAncestorStateOfType<_HomeTmpState>();
    state?._update();
  }

  @override
  State<HomeTmp> createState() => _HomeTmpState();
}

class _HomeTmpState extends State<HomeTmp> {

  final Login loginController=Login();

  final storage = FlutterSecureStorage();

  void reponseLoginUser(LoginModel lm){
    storage.write(key: HomeTmp.TOKEN_KEY, value: lm.token);
    LoginModelProvider.getInstance((){}).setLoginModel(lm);
    _update();
  }
  void reponseLoginUserErreur(DioException ex){
    storage.delete(key: HomeTmp.TOKEN_KEY);
    if(ex.response!=null && ex.response!.data["message"] != null){
      Constant.showAlertDialog(context,"Erreur",ex.response!.data["message"]);
    }
    else{
      Constant.showAlertDialog(context, "Erreur", "Une erreur s'est produite lors de la connexion");
    }
  }

  @override
  void initState() {
    super.initState();
    initToken();
  }

  Future initToken() async{
    // Lire le token
    String? token = await storage.read(key: 'auth_token');
    if(token!=null){
      loginController.askToken(token, reponseLoginUser, reponseLoginUserErreur);
    }

  }

  void _update() {
    print(LoginModelProvider.getInstance(() {}).loginModel);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginModelProvider.getInstance(() {}).loginModel != null
          ? HomeView()
          : LoginVue(),
    );
  }
}

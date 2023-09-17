import 'package:Pouic/outil/LoginSingleton.dart';
import 'package:Pouic/vue/LoginVue.dart';
import 'package:Pouic/vue/home/HomeView.dart';
import 'package:flutter/material.dart';

class HomeTmp extends StatefulWidget {
  @override
  State<HomeTmp> createState() => HomeTmpState();
}

class HomeTmpState extends State<HomeTmp> {

  void update(){
    print(LoginModelProvider.getInstance(update).loginModel);
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginModelProvider.getInstance(update).loginModel != null ? HomeView(updateMain: update,) : LoginVue(updateMain: update,),
    );
  }

}
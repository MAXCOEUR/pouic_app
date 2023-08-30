import 'package:discution_app/outil/LoginSingleton.dart';
import 'package:discution_app/vue/LoginVue.dart';
import 'package:discution_app/vue/home/HomeView.dart';
import 'package:flutter/material.dart';

class HomeTmp extends StatefulWidget {

  @override
  State<HomeTmp> createState() => _HomeTmpState();
}

class _HomeTmpState extends State<HomeTmp> {
  void update(){
    print("update");
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginModelProvider.instance.loginModel != null ? HomeView(updateMain: update,) : LoginVue(updateMain: update,),
    );
  }

}
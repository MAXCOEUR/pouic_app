import 'package:pouic/outil/LoginSingleton.dart';
import 'package:pouic/vue/LoginVue.dart';
import 'package:pouic/vue/home/HomeView.dart';
import 'package:flutter/material.dart';

class HomeTmp extends StatefulWidget {
  static void update(BuildContext context) {
    final state = context.findAncestorStateOfType<_HomeTmpState>();
    state?._update();
  }

  @override
  State<HomeTmp> createState() => _HomeTmpState();
}

class _HomeTmpState extends State<HomeTmp> {
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

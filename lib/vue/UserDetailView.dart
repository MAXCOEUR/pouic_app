import 'package:flutter/material.dart';

import '../Controller/UserController.dart';
import '../Model/UserListeModel.dart';
import '../Model/UserModel.dart';
import '../outil/Constant.dart';

class UserDetailleView extends StatefulWidget{
  final LoginModel lm= Constant.loginModel!;
  final User user;
  UserDetailleView(this.user,{super.key});

  @override
  State<UserDetailleView> createState() => _UserListeViewState();
}

class _UserListeViewState extends State<UserDetailleView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50), // Hauteur de la nouvelle barre
          child: CustomAppBar(
              userImageBytes: widget.lm.user.Avatar
          ),
        ),
        body: Column(
            children: [
              Container(
                width: 150,
                height: 150,
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
            ]
        )
    );
  }
}
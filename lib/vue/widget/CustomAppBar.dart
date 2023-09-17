import 'dart:typed_data';

import 'package:Pouic/Model/UserModel.dart';
import 'package:Pouic/outil/Constant.dart';
import 'package:Pouic/outil/LoginSingleton.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  User u = LoginModelProvider.getInstance(() {})
      .loginModel!
      .user; // Les octets de l'image de l'utilisateur
  bool arrowReturn;

  CustomAppBar({required this.arrowReturn});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: arrowReturn,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Scaffold.of(context).openDrawer(); // Ouvre le Drawer
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: ClipOval(
                child: Constant.buildAvatarUser(u,30,false,context),
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.background,
            ),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Image.asset(
                  'assets/logo.png',
                )),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(50);
}

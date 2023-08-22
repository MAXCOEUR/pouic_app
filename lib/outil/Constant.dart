import 'dart:typed_data';

import 'package:discution_app/Model/UserModel.dart';
import 'package:flutter/material.dart';

class Constant{
  static LoginModel? loginModel;
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Uint8List? userImageBytes; // Les octets de l'image de l'utilisateur

  CustomAppBar({required this.userImageBytes});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: ClipOval(
              child: userImageBytes != null
                  ? Image.memory(
                userImageBytes!,
                fit: BoxFit.cover,
              )
                  : Icon(Icons.account_circle),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.background,
            ),
            child:Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child:Image.asset('assets/logo.png',)
            ),
          ),

          SizedBox(width: 40),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}
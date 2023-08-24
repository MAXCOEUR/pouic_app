import 'dart:typed_data';

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Uint8List? userImageBytes; // Les octets de l'image de l'utilisateur
  bool arrowReturn;

  CustomAppBar({required this.userImageBytes,required this.arrowReturn});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: arrowReturn,
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
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(50);
}
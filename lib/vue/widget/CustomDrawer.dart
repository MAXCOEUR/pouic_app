import 'dart:typed_data';

import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/vue/CreateUserVue.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget implements PreferredSizeWidget {

  LoginModel lm = Constant.loginModel!;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: ClipOval(
                    child: lm.user.Avatar != null
                        ? Image.memory(
                      lm.user.Avatar!,
                      fit: BoxFit.cover,
                    )
                        : Icon(Icons.account_circle),
                  ),
                ),
                SizedBox(height: 20),
                Text(lm.user.uniquePseudo),
                Text(lm.user.pseudo),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text("Profil"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateUserVue(created: false,user:lm.user)),
              );
            },
          ),
          // Autres éléments du panneau latéral
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(50);
}
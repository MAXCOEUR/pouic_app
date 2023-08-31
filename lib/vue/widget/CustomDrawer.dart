import 'dart:typed_data';

import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/outil/LoginSingleton.dart';
import 'package:discution_app/vue/CreateUserVue.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget implements PreferredSizeWidget {
  Function updateMain;
  CustomDrawer({required this.updateMain});

  LoginModel lm = LoginModelProvider.getInstance((){}).loginModel!;

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
                    child: Constant.buildImageOrIcon(
                        Constant.baseUrlAvatarUser+"/"+lm.user.uniquePseudo+".png",
                        Icon(Icons.account_circle)
                    ),
                  ),
                ),
                SizedBox(height: SizeMarginPading.h3),
                Text("@"+lm.user.uniquePseudo,style: TextStyle(fontSize: SizeFont.h3)),
                Text(lm.user.pseudo,style: TextStyle(fontSize: SizeFont.p1)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text("Profil",style: TextStyle(fontSize: SizeFont.p1)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateUserVue(created: false,user:lm.user)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Deconexion",style: TextStyle(fontSize: SizeFont.p1)),
            onTap: () {
              LoginModelProvider.getInstance((){}).setLoginModel(null);
              updateMain();
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(50);
}
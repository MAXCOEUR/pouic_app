import 'dart:typed_data';

import 'package:Pouic/Model/UserModel.dart';
import 'package:Pouic/outil/Constant.dart';
import 'package:Pouic/outil/LoginSingleton.dart';
import 'package:Pouic/vue/CreateUserVue.dart';
import 'package:Pouic/vue/home/UserDetailView.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget implements PreferredSizeWidget {
  Function updateMain;

  CustomDrawer({required this.updateMain});

  LoginModel lm = LoginModelProvider.getInstance(() {}).loginModel!;

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
                    child: Constant.buildAvatarUser(lm.user,80,true,context),
                  ),
                ),
                SizedBox(height: SizeMarginPading.h3),
                Text(
                  "@" + lm.user.uniquePseudo,
                  style: TextStyle(fontSize: SizeFont.h3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  lm.user.pseudo,
                  style: TextStyle(fontSize: SizeFont.p1),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text("Profil", style: TextStyle(fontSize: SizeFont.p1)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserDetailleView(lm.user)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Deconexion", style: TextStyle(fontSize: SizeFont.p1)),
            onTap: () {
              LoginModelProvider.getInstance(() {}).setLoginModel(null);
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

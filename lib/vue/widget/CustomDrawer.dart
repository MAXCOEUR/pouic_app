import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pouic/HomeTmp.dart';
import 'package:pouic/Model/UserModel.dart';
import 'package:pouic/outil/Api.dart';
import 'package:pouic/outil/Constant.dart';
import 'package:pouic/outil/LoginSingleton.dart';
import 'package:pouic/vue/CreateUserVue.dart';
import 'package:pouic/vue/home/UserDetailView.dart';
import 'package:flutter/material.dart';

import '../LoginVue.dart';

class CustomDrawer extends StatelessWidget implements PreferredSizeWidget {

  CustomDrawer();
  final storage = FlutterSecureStorage();
  LoginModel lm = LoginModelProvider.getInstance(() {}).loginModel!;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: EdgeInsets.all( 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
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
            title: Text("Déconnexion", style: TextStyle(fontSize: SizeFont.p1)),
            onTap:  () {
              deconexion(context);
            },
          ),
        ],
      ),
    );
  }

  deconexion(context) async{
    storage.delete(key: HomeTmp.TOKEN_KEY);
    setNullTokenNotification();
    LoginModelProvider.getInstance(() {}).setLoginModel(null);

    HomeTmp.update(context);
  }

  setNullTokenNotification() async {
    LoginModel loginModel = LoginModelProvider.getInstance((){}).loginModel!;
    String AuthorizationToken='Bearer '+loginModel.token;
    final reposeToken = await Api.instance.putData("user/tokenNotification", {'token': null}, null, {'Authorization': AuthorizationToken});
    if(reposeToken.statusCode==201){
      print("tokenNotification reussie");
    }else{
      print("tokenNotification error");
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(50);
}

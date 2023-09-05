import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/vue/home/UserDetailView.dart';
import 'package:discution_app/vue/widget/PhotoView.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

class Constant {
  static const String ServeurApi = "http://46.227.18.31:3000";
  static const String baseUrlAvatarUser = ServeurApi + "/uploads/AvatarUser";
  static const String baseUrlAvatarConversation =
      ServeurApi + "/uploads/ImageConversation";
  static const String baseUrlFilesMessages = ServeurApi + "/uploads/messages";

  static showAlertDialog(BuildContext context, String titre, String erreur) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(titre),
      content: Text(erreur),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  static Widget buildAvatarUser(User u,double size, bool clicable){
    Icon icon = Icon(Icons.account_circle,size: size,);
    String? avatar=u.getNameImage();
    if(avatar==null){
      return icon;
    }
    else{
      return _buildImageOrIcon(
          Constant.baseUrlAvatarUser + "/" + avatar ,
          icon,
          false
      );
    }

  }
  static Widget buildImageConversation(Conversation c,double size, bool clicable){
    Icon icon = Icon(Icons.comment,size: size,);
    String? image=c.getNameImage();
    if(image==null){
      return icon;
    }
    else{
      return _buildImageOrIcon(
          Constant.baseUrlAvatarConversation+"/"+image,
          icon,
          true
      );
    }

  }

  static Widget _buildImageOrIcon(String imageUrl, Icon icon, bool clicable) {

    if(imageUrl.split('/').last=="0"){
      return icon;
    }
    return CachedNetworkImage(
      key: Key(imageUrl),
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          CircularProgressIndicator(value: downloadProgress.progress),
      errorWidget: (context, url, error) => icon,
    );
  }


}

class SizeFont {
  static double h1 = 26;
  static double h2 = 24;
  static double h3 = 20;
  static double p1 = 16;
  static double p2 = 12;
}

class SizeMarginPading {
  static double h1 = 16;
  static double h2 = 12;
  static double h3 = 8;
  static double p1 = 4;
  static double p2 = 2;
}

class SizeBorder {
  static double radius = 10;
}

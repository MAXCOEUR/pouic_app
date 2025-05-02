import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:pouic/Model/ConversationModel.dart';
import 'package:pouic/Model/UserModel.dart';
import 'package:pouic/vue/home/UserDetailView.dart';
import 'package:pouic/vue/widget/PhotoView.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;

class Constant {
  static const String schemeApi = "http";
  static const String ipApi = "46.227.18.31";
  static const int portApi = 45713;
  static const String ServeurApi = "$schemeApi://$ipApi:$portApi";
  static const String baseUrlAvatarUser = ServeurApi + "/uploads/AvatarUser";
  static const String baseUrlAvatarConversation =
      ServeurApi + "/uploads/ImageConversation";
  static const String baseUrlFilesMessages = ServeurApi + "/uploads/messages";
  static const String baseUrlPouireal = ServeurApi + "/uploads/pouireal";

  static List<String> popularEmojis = [
    "❤️", "👍", "👎", "😀", "😂", "😊", "😍", "😢", "🤔", "😭",
    "😘", "🤣", "😩", "😁", "🙏", "🤷‍♂️", "🤷‍♀️", "🙌", "😔", "😏",
    "😆", "😬", "😎", "😅", "🤗", "🤐", "😇", "🙄", "😌", "😖",
    "😋", "😕", "😞", "😮", "😑", "😐", "😟", "🤨", "😦", "😴",
    "😷", "😵", "😨", "😤", "😓", "😣", "😱", "😪", "🤢", "🤕",
    "😥", "😰", "🤒", "🤮", "🤑", "🤓", "😼", "🙀", "😿", "😾",
    "🤖", "🙈", "🙉", "🙊", "💩", "🦄", "🐶", "🐱", "🐭", "🐹",
    "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐽",
    "🐸", "🐔", "🐣", "🐍", "🐢", "🐳", "🐋", "🦈", "🦑", "🐙",
    "🐚", "🦀", "🦐", "🐟", "🐠", "🐡", "🐬", "🐳", "🦐", "🌴",
    "🌵", "🌾", "🌻", "🌺", "🌹", "🌷", "🌼", "🌸", "💐", "🍁",
    "🍂", "🍃", "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🍎"
  ];


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
  static Widget buildAvatarUser(User u,double size, bool clicable,BuildContext context){
    Icon icon = Icon(Icons.account_circle,size: size,);
    String? avatar=u.getNameImage();
    if(avatar==null){
      return icon;
    }
    else{
      return _buildImageOrIcon(
          Constant.baseUrlAvatarUser + "/" + avatar ,
          icon,
          clicable,
          context
      );
    }

  }
  static Widget buildImageConversation(Conversation c,double size, bool clicable,BuildContext context){
    Icon icon = Icon(Icons.comment,size: size,);
    String? image=c.getNameImage();
    if(image==null){
      return icon;
    }
    else{
      return _buildImageOrIcon(
          Constant.baseUrlAvatarConversation+"/"+image,
          icon,
          clicable,
          context
      );
    }

  }

  static Widget _buildImageOrIcon(String imageUrl, Icon icon, bool clicable,BuildContext context) {

    if(imageUrl.split('/').last=="0"){
      return icon;
    }
    if (clicable) {
      return InkWell(
        child: CachedNetworkImage(
          key: Key(imageUrl),
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(value: downloadProgress.progress),
          errorWidget: (context, url, error) => icon,
        ),
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PhotoViewCustom(
                    imageUrl,
                  ),
            ),
          );
        },
      );
    } else{
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
  static Future<Uint8List> compressImage(Uint8List imageBytes,int quality) async {
    return await FlutterImageCompress.compressWithList(
      imageBytes,
      minHeight: 500,
      minWidth: 500,
      quality: quality,
    );
  }

  static String formatNumber(int number) {
    if (number >= 10000000) {
      return (number ~/ 1000000).toString() + 'm';
    } else if (number >= 10000) {
      return (number ~/ 1000).toString() + 'k';
    } else {
      return number.toString();
    }
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

import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/vue/home/UserDetailView.dart';
import 'package:discution_app/vue/widget/PhotoView.dart';
import 'package:flutter/material.dart';
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

  static Future<bool> _checkImageExists(String url) async {
    final response = await http.head(Uri.parse(url));
    return response.statusCode == 200;
  }

  static Widget buildImageOrIcon(String imageUrl, Icon icon, bool clicable) {

    if(imageUrl.split('/').last=="0"){
      return icon;
    }
    return FutureBuilder<String?>(
      future: _findAvailableImage(imageUrl),
      builder: (context, snapshot) {
        return clicable
            ?InkWell(
          onTap: () {
            if(snapshot.data!=null){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PhotoViewCustom(snapshot.data!)),
              );
            }
          },
          child: (snapshot.data!=null)?CachedNetworkImage(
            key: Key(snapshot.data!),
            imageUrl: snapshot.data!,
            fit: BoxFit.cover,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ):icon,
        ): (snapshot.data!=null)?CachedNetworkImage(
          key: Key(snapshot.data!),
          imageUrl: snapshot.data!,
          fit: BoxFit.cover,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(value: downloadProgress.progress),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ):icon;
      },
    );
  }

  static Future<String?> _findAvailableImage(String baseUrl) async {
    final List<String> imageExtensions = ['.png', '.jpg', '.jpeg', '.gif'];

    for (final extension in imageExtensions) {
      final imageUrl = '$baseUrl$extension';
      final imageExists = await _checkImageExists(imageUrl);
      if (imageExists) {
        return imageUrl;
      }
    }

    return null; // No available image with supported extensions
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

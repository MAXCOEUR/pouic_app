import 'dart:io';

import 'package:dio/dio.dart';
import 'package:discution_app/outil/Api.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class FileGestion{
  static Future<void> _launch(String url) async {
    if (!await launch(url)) {
      throw Exception('Could not launch $url');
    }
  }
  static Future<void> downloadFile(String url,String name, BuildContext context) async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      print('La permission d\'accès au stockage n\'a pas été accordée.');
      return;
    }

    Directory? downloadsDir;
    if(Platform.isAndroid){
      downloadsDir=Directory("/storage/emulated/0/Download/");
    }else{
      downloadsDir = await getDownloadsDirectory();
    }


    try {
      String savePath = '${downloadsDir!.path}/$name';
      final response = await Api.instance.dio.download(url, savePath);

      if (response.statusCode == 200) {
        Constant.showAlertDialog(context, "Téléchargement réussi", "Téléchargement réussi. Chemin du fichier : ${savePath}");
        print('Téléchargement réussi. Chemin du fichier : ${savePath}');
      } else {
        print('Échec du téléchargement. Code de statut : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors du téléchargement : $e');
    }
  }
  static Future<void> Open(String url,String name) async {
    _launch(url);
  }

}
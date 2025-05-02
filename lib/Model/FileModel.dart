import 'dart:convert';

import 'package:pouic/Model/UserModel.dart';

class FileModel{
  String linkFile;
  String name;

  FileModel(this.linkFile, this.name);


  Map<String, dynamic> toJson() {
    return {
      'linkFile': linkFile,
      'name': name,
    };
  }
  String toJsonString() {
    return jsonEncode(toJson());
  }
}
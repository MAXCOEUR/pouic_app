import 'dart:convert';
import 'dart:io';

import 'package:discution_app/Model/FileModel.dart';
import 'package:discution_app/Model/MessageParentModel.dart';
import 'package:discution_app/Model/UserModel.dart';

class MessageModel{
  int id;
  User user;
  String message;
  DateTime date;
  int id_conversation;
  bool isread;
  List<FileModel> files;
  MessageParentModel? parent;

  MessageModel(this.id, this.user, this.message, this.date, this.id_conversation,this.isread,this.files,this.parent);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'message': message,
      'date':date,
      'id_conversation':id_conversation,
      'files':files.toString()
    };
  }
  String toJsonString() {
    return jsonEncode(toJson());
  }
  void addfile(FileModel file){
    files.add(file);
  }
}
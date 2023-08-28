import 'dart:convert';

import 'package:discution_app/Model/UserModel.dart';

class MessageModel{
  int id;
  User user;
  String? file;
  String message;
  DateTime date;
  int id_conversation;
  bool isread;

  MessageModel(this.id, this.user, this.file, this.message, this.date, this.id_conversation,this.isread);

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
      'file': file,
      'message': message,
      'date':date,
      'id_conversation':id_conversation
    };
  }
  String toJsonString() {
    return jsonEncode(toJson());
  }
}
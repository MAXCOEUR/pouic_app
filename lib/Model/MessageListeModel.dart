import 'package:discution_app/Model/MessageModel.dart';
import 'dart:convert';

class MessageListe{
  List<Message> messages = [];

  void addUser(Message message){
    messages.add(message);
  }
  void addUsers(List<Message> message){
    messages.addAll(message);
  }
  void removeUser(Message message){
    messages.remove(message);
  }
  String toJsonString() {
    List<Map<String, dynamic>> messageJson = messages.map((message) => message.toJson()).toList();
    return jsonEncode(messageJson);
  }
}
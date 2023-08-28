import 'package:discution_app/Model/MessageModel.dart';
import 'dart:convert';

class MessageListe{
  List<MessageModel> messages = [];

  void newMessage(MessageModel message){
    messages.insert(0,message);
  }
  void addOldMessages(List<MessageModel> message){
    messages.addAll(message);
  }
  void remove(MessageModel message){
    messages.remove(message);
  }
  String toJsonString() {
    List<Map<String, dynamic>> messageJson = messages.map((message) => message.toJson()).toList();
    return jsonEncode(messageJson);
  }
}
import 'package:discution_app/Model/MessageModel.dart';
import 'dart:convert';

class MessageListe{
  List<Message> messages = [];

  void newMessage(Message message){
    messages.insert(0,message);
  }
  void addOldMessages(List<Message> message){
    messages.addAll(message);
  }
  void remove(Message message){
    messages.remove(message);
  }
  String toJsonString() {
    List<Map<String, dynamic>> messageJson = messages.map((message) => message.toJson()).toList();
    return jsonEncode(messageJson);
  }
}
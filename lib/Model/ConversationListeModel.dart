import 'package:discution_app/Model/ConversationModel.dart';
import 'dart:convert';

class ConversationListe{
  List<Conversation> conversations = [];

  void addUser(Conversation conversation){
    conversations.add(conversation);
  }
  void addUsers(List<Conversation> conversation){
    conversations.addAll(conversation);
  }
  void removeUser(Conversation conversation){
    conversations.remove(conversation);
  }
  String toJsonString() {
    List<Map<String, dynamic>> conversationJson = conversations.map((conversation) => conversation.toJson()).toList();
    return jsonEncode(conversationJson);
  }
}
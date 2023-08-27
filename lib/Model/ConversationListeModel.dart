import 'package:discution_app/Model/ConversationModel.dart';
import 'dart:convert';

class ConversationListe{
  List<Conversation> conversations = [];

  void addConv(Conversation conversation){
    conversations.add(conversation);
  }
  void addConvs(List<Conversation> conversation){
    conversations.addAll(conversation);
  }
  void removeConv(Conversation conversation){
    conversations.remove(conversation);
  }
  void reset(){
    conversations.clear();
  }
  String toJsonString() {
    List<Map<String, dynamic>> conversationJson = conversations.map((conversation) => conversation.toJson()).toList();
    return jsonEncode(conversationJson);
  }
}
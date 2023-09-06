import 'package:discution_app/Model/ConversationModel.dart';
import 'dart:convert';

class ConversationListe{
  List<Conversation> conversations = [];

  void addConv(Conversation conversation){
    conversations.add(conversation);
  }
  void addTopConv(Conversation conversation){
    conversations.insert(0,conversation);
  }
  void addConvs(List<Conversation> conversation){
    conversations.addAll(conversation);
  }
  void removeConv(Conversation conversation){
    conversations.remove(conversation);
  }
  void removeConvId(int idConv){
    late Conversation tmpConv;
    for(Conversation conv in conversations){
      if(conv.id==idConv){
        tmpConv=conv;
      }
    }
    removeConv(tmpConv);
  }
  void reset(){
    conversations.clear();
  }
  String toJsonString() {
    List<Map<String, dynamic>> conversationJson = conversations.map((conversation) => conversation.toJson()).toList();
    return jsonEncode(conversationJson);
  }
}
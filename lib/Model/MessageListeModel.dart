import 'package:pouic/Model/FileModel.dart';
import 'package:pouic/Model/MessageModel.dart';
import 'dart:convert';

import 'package:pouic/Model/ReactionModel.dart';

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
  void removeId(int id){
    MessageModel? message;
    for(MessageModel m in messages){
      if(m.id==id){
        message=m;
        break;
      }
    }
    if(message!=null){
      remove(message);
    }
  }
  void editMessage(int id,String edit){
    for(MessageModel m in messages){
      if(m.id==id){
        m.message=edit;
        break;
      }
    }
  }
  String toJsonString() {
    List<Map<String, dynamic>> messageJson = messages.map((message) => message.toJson()).toList();
    return jsonEncode(messageJson);
  }
  void addFile(int id_message,FileModel file){
    for(MessageModel m in messages){
      if(m.id==id_message){
        m.addfile(file);
      }
    }
  }
  void addReaction(int id_message,Reaction reaction){
    for(MessageModel m in messages){
      if(m.id==id_message){
        m.addReaction(reaction);
      }
    }
  }
  void deleteReaction(int id_message,String uniquePseudo){
    for(MessageModel m in messages){
      if(m.id==id_message){
        m.deleteReaction(uniquePseudo);
      }
    }
  }
  static MessageModel? isExiste(int idMessage,List<MessageModel> messagesTmp){
    for(MessageModel m in messagesTmp){
      if(m.id==idMessage){
        return m;
      }
    }
    return null;
  }
}
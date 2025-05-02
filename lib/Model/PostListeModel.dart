import 'package:pouic/Model/FileModel.dart';
import 'package:pouic/Model/MessageModel.dart';
import 'package:pouic/Model/PostModel.dart';
import 'dart:convert';

import 'package:pouic/Model/ReactionModel.dart';

class PostListe{
  List<PostModel> posts = [];

  void removeAll(){
    posts.clear();
  }

  void newMessage(PostModel message){
    posts.insert(0,message);
  }

  void addOldMessages(List<PostModel> messages){
    for (PostModel p in messages){
      if(!isParent(p)){
        posts.add(p);
      }
    }
    //posts.addAll(messages);
  }

  bool isParent(PostModel pm){
    for (PostModel p in posts){
      if(p.isParent(pm)){
       return true;
      }
    }
    return false;
  }

  void remove(PostModel message){
    posts.remove(message);
  }
  void removeId(int id){
    PostModel? post;
    for(PostModel p in posts){
      if(p.id==id){
        post=p;
        break;
      }
    }
    if(post!=null){
      remove(post);
    }
  }
  void editMessage(int id,String edit){
    for(PostModel m in posts){
      if(m.id==id){
        m.message=edit;
        break;
      }
    }
  }
  void addFile(int id_message,FileModel file){
    for(PostModel m in posts){
      if(m.id==id_message){
        m.addfile(file);
      }
    }
  }
  void addReaction(int id_message,Reaction reaction){
    for(PostModel m in posts){
      if(m.id==id_message){
        m.addReaction(reaction);
      }
    }
  }
  void deleteReaction(int id_message,String uniquePseudo){
    for(PostModel m in posts){
      if(m.id==id_message){
        m.deleteReaction(uniquePseudo);
      }
    }
  }
  static PostModel? isExiste(int idMessage,List<PostModel> messagesTmp){
    for(PostModel m in messagesTmp){
      if(m.id==idMessage){
        return m;
      }
    }
    return null;
  }
}
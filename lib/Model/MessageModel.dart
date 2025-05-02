import 'dart:convert';
import 'dart:io';

import 'package:pouic/Model/FileModel.dart';
import 'package:pouic/Model/MessageParentModel.dart';
import 'package:pouic/Model/ReactionModel.dart';
import 'package:pouic/Model/UserModel.dart';

class MessageModel{
  int id;
  User user;
  String message;
  DateTime date;
  int id_conversation;
  bool isread;
  List<FileModel> files;
  MessageParentModel? parent;
  List<Reaction> reactions=[];

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
      'user': user.toJson(),
      'message': message,
      'date':date,
      'id_conversation':id_conversation,
      'files':files.toString(),
      'reactions':reactions.toString()
    };
  }
  String toJsonString() {
    return jsonEncode(toJson());
  }
  void addfile(FileModel file){
    files.add(file);
  }
  void addReaction(Reaction reaction){
    for(Reaction r in reactions){
      if(r.user==reaction.user){
        r.reaction=reaction.reaction;
        return;
      }
    }
    reactions.add(reaction);
  }
  void deleteReaction(String uniquePseudo){
    Reaction? tmp;
    for(Reaction r in reactions){
      if(r.user.uniquePseudo==uniquePseudo){
        tmp=r;
      }
    }
    if(tmp!=null){
      reactions.remove(tmp);
    }
  }
  void removeReaction(Reaction reaction){
    reactions.remove(reaction);
  }
}
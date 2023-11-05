import 'dart:convert';
import 'dart:io';

import 'package:Pouic/Model/FileModel.dart';
import 'package:Pouic/Model/MessageParentModel.dart';
import 'package:Pouic/Model/ReactionModel.dart';
import 'package:Pouic/Model/UserModel.dart';

class PostModel{
  int id;
  User user;
  String message;
  DateTime date;
  List<FileModel> files;
  int nbr_reaction;
  int nbr_reponse;
  bool amIlike;
  PostModel? parent;
  List<Reaction> reactions=[];

  PostModel(this.id, this.user, this.message, this.date,this.files,this.nbr_reaction,this.nbr_reponse,this.amIlike,this.parent);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  void addfile(FileModel file){
    files.add(file);
  }
  bool addReaction(Reaction reaction){
    for(Reaction r in reactions){
      if(r.user==reaction.user){
        r.reaction=reaction.reaction;
        return false;
      }
    }
    reactions.add(reaction);
    return true;
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
  bool isParent(PostModel pm){
    if(this.parent!=null){
      if(this.parent==pm){
        return true;
      }
      else{
        return parent!.isParent(pm);
      }
    }
    else{
      return false;
    }
  }
}
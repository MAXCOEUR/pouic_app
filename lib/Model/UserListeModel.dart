import 'package:discution_app/Model/UserModel.dart';
import 'dart:convert';

class UserListe{
  List<User> users = [];

  void addUser(User user){
    users.add(user);
  }
  void addUsers(List<User> user){
    users.addAll(user);
  }
  void reset(){
    users.clear();
  }
  void removeUser(User user){
    users.remove(user);
  }
  void removeUserPseudo(String s){
    List<int> tmp =[];
    for(int i=0;i<users.length;i++){
      if(users[i].uniquePseudo==s){
        tmp.add(i);
      }
    }
    for(int i=0;i<tmp.length;i++){
      users.removeAt(tmp[i]);
    }

  }
  String toJsonString() {
    List<Map<String, dynamic>> usersJson = users.map((user) => user.toJson()).toList();
    return jsonEncode(usersJson);
  }
}
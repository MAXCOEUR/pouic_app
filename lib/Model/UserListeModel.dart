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
  void removeUser(User user){
    users.remove(user);
  }
  String toJsonString() {
    List<Map<String, dynamic>> usersJson = users.map((user) => user.toJson()).toList();
    return jsonEncode(usersJson);
  }
}
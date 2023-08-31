import 'dart:convert';

import 'package:discution_app/Model/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginModelProvider {
  LoginModelProvider(){
    getTokenFromCache().then((value) => _loginModel=value);
  }
  LoginModel? _loginModel;

  LoginModel? get loginModel => _loginModel;

  void setLoginModel(LoginModel? loginModel) {
    _loginModel = loginModel;
  }

  static LoginModelProvider? _instance;

  static LoginModelProvider get instance {
    _instance ??= LoginModelProvider();
    return _instance!;
  }

  static Future<String?> getTokenFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }
}
class LoginModel{
  User user;
  String token;

  LoginModel(this.user,this.token);

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'token': token,
    };
  }
  String toJsonString() {
    return jsonEncode(toJson());
  }
}
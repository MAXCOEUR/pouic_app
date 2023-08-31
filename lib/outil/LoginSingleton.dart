import 'dart:convert';

import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginModelProvider {
  LoginModelProvider(Function callBack){
    getLoginModelFromCache().then(
            (value) {
              _loginModel=value;
              callBack();
            }
    );
  }
  LoginModel? _loginModel;

  LoginModel? get loginModel => _loginModel;

  void setLoginModel(LoginModel? loginModel) {
    if(loginModel==null){
      _removeTokenInCache();
    }
    else{
      _storeTokenInCache(loginModel.token);
    }
    _loginModel = loginModel;
  }

  static LoginModelProvider? _instance;

  static LoginModelProvider getInstance(Function callBack) {
    _instance ??= LoginModelProvider(callBack);
    return _instance!;
  }

  static Future<LoginModel?> getLoginModelFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    if(token==null){
      return null;
    }
    String AuthorizationToken='Bearer '+token;
    try{
      final response = await Api.instance.postData("user/login/token", null, null, {'Authorization': AuthorizationToken});
      if(response.statusCode==200){
        Map<String, dynamic> jsonData = response.data;
        Map<String, dynamic> userMap = jsonData["user"];

        String token = jsonData["token"];

        User u = User(
            userMap["email"], userMap["uniquePseudo"], userMap["pseudo"]);
        LoginModel lm = LoginModel(u, token);
        LoginModelProvider._storeTokenInCache(token);
        return lm;
        //callBack(lm);
      }else{
        throw Exception();
      }
    }catch (error){
      throw error;
    }


  }
  static void _storeTokenInCache(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('authToken', token);
  }
  static void _removeTokenInCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('authToken');
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
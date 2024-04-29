import 'dart:convert';
import 'dart:io';

import 'package:Pouic/Model/UserModel.dart';
import 'package:Pouic/fireBase/fireBase_api.dart';
import 'package:Pouic/outil/Api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginModelProvider {
  LoginModelProvider._privateConstructor(Function callBack){
  }
  LoginModel? _loginModel;

  LoginModel? get loginModel => _loginModel;

  void setLoginModel(LoginModel? loginModel) {
    _loginModel = loginModel;
  }

  static LoginModelProvider? _instance;

  static LoginModelProvider getInstance(Function callBack) {
    _instance ??= LoginModelProvider._privateConstructor(callBack);
    return _instance!;
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
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pouic/Model/UserModel.dart';
import 'package:pouic/fireBase/fireBase_api.dart';
import 'package:pouic/outil/LoginSingleton.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../outil/Api.dart';

class Login {


  Future<void> ask(String userOrEmail, String mdp,Function callBack,Function callBackError) async {
    try{
      final response = await Api.instance.postData("user/login", {'emailOrPseudo': userOrEmail, 'passWord': mdp}, null, null);
      if(response.statusCode==200){
        print("connection reussie");
        Map<String, dynamic> jsonData = response.data;
        Map<String, dynamic> userMap = jsonData["user"];

        String token = jsonData["token"];

        User u = User(email: userMap["email"], uniquePseudo:userMap["uniquePseudo"], pseudo:userMap["pseudo"],bio:userMap["bio"],extension:userMap["extension"]);
        LoginModel lm = LoginModel(u, token);

        if(!kIsWeb && !Platform.isWindows){
          String AuthorizationToken='Bearer '+lm.token;
          WidgetsFlutterBinding.ensureInitialized();
          await Firebase.initializeApp();
          String? tokenNotification = await FireBaseApi().initNotification();
          final reposeToken = await Api.instance.putData("user/tokenNotification", {'token': tokenNotification}, null, {'Authorization': AuthorizationToken});
          if(reposeToken.statusCode==201){
            print("tokenNotification reussie");
          }else{
            throw Exception();
          }
        }
        callBack(lm);
      }else{
        throw Exception();
      }
    }catch (error){
      callBackError(error);
    }
  }
  Future<void> askToken(String Token,Function callBack,Function callBackError) async {
    try{
      String AuthorizationToken='Bearer '+Token;
      final response = await Api.instance.postData("user/login/token", {}, null, {'Authorization': AuthorizationToken});
      if(response.statusCode==200){
        print("connection reussie");
        Map<String, dynamic> jsonData = response.data;
        Map<String, dynamic> userMap = jsonData["user"];

        String token = jsonData["token"];

        User u = User(email: userMap["email"], uniquePseudo:userMap["uniquePseudo"], pseudo:userMap["pseudo"],bio:userMap["bio"],extension:userMap["extension"]);
        LoginModel lm = LoginModel(u, token);

        if(!kIsWeb && !Platform.isWindows){
          String AuthorizationToken='Bearer '+lm.token;
          WidgetsFlutterBinding.ensureInitialized();
          await Firebase.initializeApp();
          String? tokenNotification = await FireBaseApi().initNotification();
          final reposeToken = await Api.instance.putData("user/tokenNotification", {'token': tokenNotification}, null, {'Authorization': AuthorizationToken});
          if(reposeToken.statusCode==201){
            print("tokenNotification reussie");
          }else{
            throw Exception();
          }
        }
        callBack(lm);
      }else{
        throw Exception();
      }
    }catch (error){
      callBackError(error);
    }
  }
}
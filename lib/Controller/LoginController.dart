import 'dart:convert';
import 'dart:typed_data';

import 'package:Pouic/Model/UserModel.dart';
import 'package:Pouic/outil/LoginSingleton.dart';

import '../outil/Api.dart';

class Login {


  Future<void> ask(String userOrEmail, String mdp,Function callBack,Function callBackError) async {
    try{
      final response = await Api.instance.postData("user/login", {'emailOrPseudo': userOrEmail, 'passWord': mdp}, null, null);
      if(response.statusCode==200){
        Map<String, dynamic> jsonData = response.data;
        Map<String, dynamic> userMap = jsonData["user"];

        String token = jsonData["token"];

        User u = User(email: userMap["email"], uniquePseudo:userMap["uniquePseudo"], pseudo:userMap["pseudo"],bio:userMap["bio"],extension:userMap["extension"]);
        LoginModel lm = LoginModel(u, token);
        callBack(lm);
      }else{
        throw Exception();
      }
    }catch (error){
      callBackError(error);
    }
  }
}
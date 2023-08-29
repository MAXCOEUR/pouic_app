import 'dart:convert';
import 'dart:typed_data';

import 'package:discution_app/Model/UserModel.dart';

import '../outil/Api.dart';

class Login {


  void ask(String userOrEmail, String mdp,Function callBack,Function callBackError) {
      Api.postData(
          "user/login", {'emailOrPseudo': userOrEmail, 'passWord': mdp}, null, null)
          .then(
            (response) {
          Map<String, dynamic> jsonData = response.data;
          Map<String, dynamic> userMap = jsonData["user"];

          String token = jsonData["token"];

          User u = User(
              userMap["email"], userMap["uniquePseudo"], userMap["pseudo"]);
          LoginModel lm = LoginModel(u, token);
          callBack(lm);
        },
        onError: (error) {
          callBackError(error);
        },
      );
  }
}
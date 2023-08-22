import 'dart:convert';

import 'package:discution_app/Model/UserModel.dart';

import '../outil/Api.dart';

class Login {


  void ask(String userOrEmail, String mdp,Function callBack) {
      Api.postData(
          "user/login", {'emailOrPseudo': userOrEmail, 'passWord': mdp}, null, null)
          .then(
            (response) {
          Map<String, dynamic> jsonData = jsonDecode(response.data);
          dynamic userMap = jsonData["user"];
          String token = jsonData["token"];
          User u = User(
              userMap["email"], userMap["uniquePseudo"], userMap["pseudo"],
              userMap["Avatar"]);

          LoginModel lm = LoginModel(u, token);
          callBack(lm);
        },
        onError: (error) {
          callBack(null);
        },
      );
  }
}
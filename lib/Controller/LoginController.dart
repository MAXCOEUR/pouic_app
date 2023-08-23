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
          Map<String, dynamic> jsonData = jsonDecode(response.data);
          Map<String, dynamic> userMap = jsonData["user"];

          String token = jsonData["token"];
          Uint8List? avatarData;
          if (userMap['Avatar'] != null) {
            List<dynamic> avatarBytes = userMap['Avatar']['data'];
            avatarData = Uint8List.fromList(avatarBytes.cast<int>());
          }
          User u = User(
              userMap["email"], userMap["uniquePseudo"], userMap["pseudo"],
              avatarData);
          LoginModel lm = LoginModel(u, token);
          callBack(lm);
        },
        onError: (error) {
          callBackError(error);
        },
      );
  }
}
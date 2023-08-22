import 'dart:typed_data';

import 'dart:convert';
import 'package:discution_app/Model/UserListeModel.dart';
import 'package:discution_app/outil/Constant.dart';

import '../Model/UserModel.dart';
import '../outil/Api.dart';

class UserCreate {
  void create(User user,String passWord,Function callBack) {
    Api.postData(
        "user", {'email': user.email, 'uniquePseudo': user.uniquePseudo,'pseudo':user.pseudo,'Avatar':user.Avatar,'passWord':passWord}, null, null)
        .then(
          (response) {

        Map<String, dynamic> jsonData = jsonDecode(response.data);

        Uint8List? avatarData;
        if (jsonData['Avatar'] != null) {
          List<dynamic> avatarBytes = jsonData['Avatar']['data'];
          avatarData = Uint8List.fromList(avatarBytes.cast<int>());
        }
        User u = User(
            jsonData["email"], jsonData["uniquePseudo"], jsonData["pseudo"],
            avatarData);

        callBack(u);
      },
      onError: (error) {
        print("create user :"+error.toString());
        callBack(null);
      },
    );
  }
}
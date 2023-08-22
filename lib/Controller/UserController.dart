import 'dart:typed_data';

import 'dart:convert';
import 'package:discution_app/Model/UserListeModel.dart';
import 'package:discution_app/outil/Constant.dart';

import '../Model/UserModel.dart';
import '../outil/Api.dart';


class UserController {
  UserListe users;
  UserController(this.users);
  LoginModel loginModel = Constant.loginModel!;

  void addUser_inListe(int page,String search,Function callBack){
    String AuthorizationToken='Bearer '+loginModel.token;
    Api.getData(
        "user", {'search': search, 'page': page}, {'Authorization': AuthorizationToken})
        .then(
            (response) {

          List<dynamic> jsonData = jsonDecode(response.data);
          
          for(Map<String, dynamic> user in jsonData){
            Uint8List? avatarData;
            if (user['Avatar'] != null) {
              List<dynamic> avatarBytes = user['Avatar']['data'];
              avatarData = Uint8List.fromList(avatarBytes.cast<int>());
            }
            users.addUser(User(user["email"], user["uniquePseudo"], user["pseudo"], avatarData));
          }

          callBack();
        },
        onError: (error) {
      print("create user :"+error.toString());
      callBack(null);
    }
    );
  }
  void removeAllUser_inListe(){
    users.reset();
  }


}
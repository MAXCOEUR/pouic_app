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

  void addUser_inListe(int page,String search,Function callBack,Function callBackError){
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
            users.addUser(User(user["email"], user["uniquePseudo"], user["pseudo"], avatarData,(user["sont_amis"])==0?false:true));
          }

          callBack();
        },
        onError: (error) {
      callBackError(error);
    }
    );
  }
  void addAmis_inListe(int page,String search,Function callBack,Function callBackError){
    String AuthorizationToken='Bearer '+loginModel.token;
    Api.getData(
        "amis", {'search': search, 'page': page}, {'Authorization': AuthorizationToken})
        .then(
            (response) {

          List<dynamic> jsonData = jsonDecode(response.data);

          for(Map<String, dynamic> user in jsonData){
            Uint8List? avatarData;
            if (user['Avatar'] != null) {
              List<dynamic> avatarBytes = user['Avatar']['data'];
              avatarData = Uint8List.fromList(avatarBytes.cast<int>());
            }
            users.addUser(User(user["email"], user["uniquePseudo"], user["pseudo"], avatarData,true));
          }

          callBack();
        },
        onError: (error) {
          callBackError(error);
        }
    );
  }
  void addDemande_inListe(int page,String search,Function callBack,Function callBackError){
    String AuthorizationToken='Bearer '+loginModel.token;
    Api.getData(
        "amis/demande", {'search': search, 'page': page}, {'Authorization': AuthorizationToken})
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
          callBackError(error);
        }
    );
  }
  void addSendDemande_inListe(int page,String search,Function callBack,Function callBackError){
    String AuthorizationToken='Bearer '+loginModel.token;
    Api.getData(
        "amis/demande/send", {'search': search, 'page': page}, {'Authorization': AuthorizationToken})
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
          callBackError(error);
        }
    );
  }
  void removeAllUser_inListe(){
    users.reset();
  }


}
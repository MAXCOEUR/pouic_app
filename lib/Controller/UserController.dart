import 'dart:typed_data';

import 'dart:convert';
import 'package:pouic/Model/ConversationModel.dart';
import 'package:pouic/Model/UserListeModel.dart';
import 'package:pouic/outil/Constant.dart';
import 'package:pouic/outil/LoginSingleton.dart';

import '../Model/UserModel.dart';
import '../outil/Api.dart';


class UserController {
  UserListe users;
  UserController(this.users);
  LoginModel loginModel = LoginModelProvider.getInstance((){}).loginModel!;

  void addUser_inListe(int page,String search,Function callBack,Function callBackError){
    String AuthorizationToken='Bearer '+loginModel.token;
    Api.instance.getData(
        "user", {'search': search, 'page': page}, {'Authorization': AuthorizationToken})
        .then(
            (response) {

          List<dynamic> jsonData = response.data;
          
          for(Map<String, dynamic> user in jsonData){
            users.addUser(User(email:user['email'], uniquePseudo:user['uniquePseudo'], pseudo:user['pseudo'],bio:user["bio"], extension:user["extension"],sont_amis: (user["sont_amis"])==0?false:true));
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
    Api.instance.getData(
        "amis", {'search': search, 'page': page}, {'Authorization': AuthorizationToken})
        .then(
            (response) {

          List<dynamic> jsonData = response.data;

          for(Map<String, dynamic> user in jsonData){
            users.addUser(User(email:user['email'], uniquePseudo:user['uniquePseudo'], pseudo:user['pseudo'],bio:user["bio"], extension:user["extension"],sont_amis: true));
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
    Api.instance.getData(
        "amis/demande", {'search': search, 'page': page}, {'Authorization': AuthorizationToken})
        .then(
            (response) {

          List<dynamic> jsonData = response.data;

          for(Map<String, dynamic> user in jsonData){
            users.addUser(User(email:user['email'], uniquePseudo:user['uniquePseudo'], pseudo:user['pseudo'],bio:user["bio"], extension:user["extension"],sont_amis: false));
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
    Api.instance.getData(
        "amis/demande/send", {'search': search, 'page': page}, {'Authorization': AuthorizationToken})
        .then(
            (response) {

          List<dynamic> jsonData = response.data;

          for(Map<String, dynamic> user in jsonData){
            users.addUser(User(email:user['email'], uniquePseudo:user['uniquePseudo'], pseudo:user['pseudo'],bio:user["bio"], extension:user["extension"],sont_amis: false));
          }

          callBack();
        },
        onError: (error) {
          callBackError(error);
        }
    );
  }
  void addUserConv_inListe(Conversation conversation,int page,String search,Function callBack,Function callBackError){
    String AuthorizationToken='Bearer '+loginModel.token;
    Api.instance.getData(
        "conv/user", {'id_conversation':conversation.id,'search': search, 'page': page}, {'Authorization': AuthorizationToken})
        .then(
            (response) {

          List<dynamic> jsonData = response.data;

          for(Map<String, dynamic> user in jsonData){
            users.addUser(User(email:user['email'], uniquePseudo:user['uniquePseudo'], pseudo:user['pseudo'],bio:user["bio"], extension:user["extension"],sont_amis: (user["sont_amis"])==0?false:true));
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

  void deleteUser(User u){
    users.removeUser(u);
  }
  void deleteUserPseaudo(String s){
    users.removeUserPseudo(s);
  }


}
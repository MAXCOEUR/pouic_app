import 'dart:typed_data';

import 'dart:convert';
import 'package:discution_app/Model/ConversationModel.dart';
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

          List<dynamic> jsonData = response.data;
          
          for(Map<String, dynamic> user in jsonData){
            users.addUser(User(user["email"], user["uniquePseudo"], user["pseudo"],(user["sont_amis"])==0?false:true));
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

          List<dynamic> jsonData = response.data;

          for(Map<String, dynamic> user in jsonData){
            users.addUser(User(user["email"], user["uniquePseudo"], user["pseudo"],true));
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

          List<dynamic> jsonData = response.data;

          for(Map<String, dynamic> user in jsonData){
            users.addUser(User(user["email"], user["uniquePseudo"], user["pseudo"]));
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

          List<dynamic> jsonData = response.data;

          for(Map<String, dynamic> user in jsonData){
            users.addUser(User(user["email"], user["uniquePseudo"], user["pseudo"]));
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
    Api.getData(
        "conv/user", {'id_conversation':conversation.id,'search': search, 'page': page}, {'Authorization': AuthorizationToken})
        .then(
            (response) {

          List<dynamic> jsonData = response.data;

          for(Map<String, dynamic> user in jsonData){
            users.addUser(User(user["email"], user["uniquePseudo"], user["pseudo"],(user["sont_amis"])==0?false:true));
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
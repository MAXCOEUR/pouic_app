import 'dart:typed_data';

import 'dart:convert';
import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/UserListeModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:flutter/cupertino.dart';

import '../Model/UserModel.dart';
import '../outil/Api.dart';

class ConversationC {
  LoginModel loginModel = Constant.loginModel!;

  void create(Conversation conversation,Function callBack,Function callBackError) {
    String AuthorizationToken='Bearer '+loginModel.token;
    Api.postData(
        "conv", {'name': conversation.name, 'image': conversation.image}, null, {'Authorization': AuthorizationToken})
        .then(
          (response) {
            Map<String, dynamic> user = jsonDecode(response.data);

            Uint8List? avatarData;
            if (user['image'] != null) {
              List<dynamic> avatarBytes = user['image']['data'];
              avatarData = Uint8List.fromList(avatarBytes.cast<int>());
            }
            Conversation conv = Conversation(user["id"], user["name"], user["uniquePseudo_admin"], avatarData,0);
            callBack(conv);


      },
      onError: (error) {
        callBackError(error);
      },
    );
  }

  void deleteConv(Conversation conversation,Function callBack,Function callBackError) {
    LoginModel loginModel =Constant.loginModel!;
    String AuthorizationToken='Bearer ${loginModel.token}';
    Api.deleteData(
        "conv", null, {'id_conversation': conversation.id}, {'Authorization': AuthorizationToken})
        .then(
          (response) {

        callBack();
      },
      onError: (error) {
        callBackError(error);
      },
    );
  }

  void putConv(Conversation conversation,Function callBack,Function callBackError) {
    LoginModel loginModel =Constant.loginModel!;
    String AuthorizationToken='Bearer ${loginModel.token}';
    Api.putData(
        "conv", {'name': conversation.name,'uniquePseudo_admin': conversation.uniquePseudo_admin,'image':conversation.image}, {'id_conversation':conversation.id}, {'Authorization': AuthorizationToken})
        .then(
          (response) {

        callBack();
      },
      onError: (error) {
        callBackError(error);
      },
    );
  }
  void getUserShort(Conversation conversation,Function callBack,Function callBackError) {
    LoginModel loginModel =Constant.loginModel!;
    String AuthorizationToken='Bearer ${loginModel.token}';
    Api.getData(
        "conv/user/short", {'id_conversation': conversation.id}, {'Authorization': AuthorizationToken})
        .then(
          (response) {

            List<dynamic> jsonData = jsonDecode(response.data);

        callBack(jsonData);
      },
      onError: (error) {
        callBackError(error);
      },
    );
  }
  void deleteUser(User user,Conversation conversation,Function callBack,Function callBackError) {
    LoginModel loginModel =Constant.loginModel!;
    String AuthorizationToken='Bearer ${loginModel.token}';
    Api.deleteData(
        "conv/user", null, {'uniquePseudo': user.uniquePseudo,'id_conversation':conversation.id}, {'Authorization': AuthorizationToken})
        .then(
          (response) {

        callBack(user);
      },
      onError: (error) {
        callBackError(error);
      },
    );
  }
  void addUser(User user,Conversation conversation,Function callBack,Function callBackError) {
    LoginModel loginModel =Constant.loginModel!;
    String AuthorizationToken='Bearer ${loginModel.token}';
    Api.postData(
        "conv/user", {'uniquePseudo': user.uniquePseudo,'id_conversation':conversation.id}, null, {'Authorization': AuthorizationToken})
        .then(
          (response) {

        callBack(user,conversation);
      },
      onError: (error) {
        callBackError(error);
      },
    );
  }
}
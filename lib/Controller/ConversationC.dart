import 'dart:io';
import 'dart:typed_data';

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:Pouic/Model/ConversationModel.dart';
import 'package:Pouic/Model/FileCustom.dart';
import 'package:Pouic/Model/UserListeModel.dart';
import 'package:Pouic/outil/Constant.dart';
import 'package:Pouic/outil/LoginSingleton.dart';
import 'package:Pouic/vue/CreateConversationVue.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:flutter/cupertino.dart';

import '../Model/UserModel.dart';
import '../outil/Api.dart';

class ConversationC {
  LoginModel loginModel = LoginModelProvider.getInstance((){}).loginModel!;

  Future<void> create(Conversation conversation,FileCustom? imageFile,Function callBack,Function callBackError) async {
    String AuthorizationToken='Bearer '+loginModel.token;
    Conversation u;
    try {
      final responseCreate = await Api.instance.postData(
        'conv',
        {'name': conversation.name,'extension':conversation.extension},
        null,
        {'Authorization': AuthorizationToken},
      );
      if(responseCreate.statusCode==201){
        Map<String, dynamic> jsonData = responseCreate.data;
        u = Conversation(jsonData["id"], jsonData["name"], jsonData["uniquePseudo_admin"],jsonData["extension"],0);
      }else{
        throw Exception();
      }

      if(imageFile==null){
        callBack(u);
        return ;
      }

      final response = await Api.instance.postDataMultipart(
        'conv/upload',
        {'avatar': MultipartFile.fromBytes(imageFile.fileBytes!.toList(),filename:imageFile!.fileName),'uniquePseudo':u.id},
        null,
        null,
      );

      if (response.statusCode == 200) {
        callBack(u);
      } else {
        throw Exception();
      }
    } catch (error) {
      print('Une erreur s\'est produite : $error');
      callBackError(error);
    }
  }

  void deleteConv(Conversation conversation,Function callBack,Function callBackError) {
    String AuthorizationToken='Bearer ${loginModel.token}';
    Api.instance.deleteData(
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

  Future<void> putConv(Conversation conversation,FileCustom? imageFile,Function callBack,Function callBackError) async {
    String AuthorizationToken='Bearer ${loginModel.token}';
    try {
      final responseCreate = await Api.instance.putData(
        'conv',
        {'name': conversation.name,'uniquePseudo_admin': conversation.uniquePseudo_admin,'extension':conversation.extension},
        {'id_conversation':conversation.id},
        {'Authorization': AuthorizationToken},
      );
      if(responseCreate.statusCode==201){

      }else{
        throw Exception();
      }

      if(imageFile==null){
        callBack();
        return ;
      }

      final response = await Api.instance.postDataMultipart(
        'conv/upload',
        {'avatar': MultipartFile.fromBytes(imageFile.fileBytes!.toList(),filename:imageFile.fileName),'uniquePseudo':conversation.id},
        null,
        null,
      );

      if (response.statusCode == 200) {
        DefaultCacheManager().emptyCache();
        callBack();
      } else {
        throw Exception();
      }
    } catch (error) {
      print('Une erreur s\'est produite : $error');
      callBackError(error);
    }
  }
  void getUserShort(Conversation conversation,Function callBack,Function callBackError) {
    String AuthorizationToken='Bearer ${loginModel.token}';
    Api.instance.getData(
        "conv/user/short", {'id_conversation': conversation.id}, {'Authorization': AuthorizationToken})
        .then(
          (response) {

            List<dynamic> jsonData = response.data;

        callBack(jsonData);
      },
      onError: (error) {
        callBackError(error);
      },
    );
  }
  void deleteUser(User user,Conversation conversation,Function callBack,Function callBackError) {
    String AuthorizationToken='Bearer ${loginModel.token}';
    Api.instance.deleteData(
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
  void deleteUserMe(User user,Conversation conversation,Function callBack,Function callBackError) {
    String AuthorizationToken='Bearer ${loginModel.token}';
    Api.instance.deleteData(
        "conv/user/me", null, {'id_conversation':conversation.id}, {'Authorization': AuthorizationToken})
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
    String AuthorizationToken='Bearer ${loginModel.token}';
    Api.instance.postData(
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
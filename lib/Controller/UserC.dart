import 'dart:io';
import 'dart:typed_data';

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:Pouic/Model/FileCustom.dart';
import 'package:Pouic/Model/UserListeModel.dart';
import 'package:Pouic/outil/Constant.dart';
import 'package:Pouic/outil/LoginSingleton.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../Model/UserModel.dart';
import '../outil/Api.dart';

class UserC {
  LoginModel? loginModel=LoginModelProvider.getInstance((){}).loginModel;
  Future<void> create(User user,FileCustom? imageFile,String passWord,Function callBack,Function callBackError) async {
    User u;
    try {
      final responseCreate = await Api.instance.postData(
        'user',
        {'email': user.email, 'uniquePseudo': user.uniquePseudo,'pseudo':user.pseudo,'passWord':passWord,'extension':user.extension,'bio':user.bio},
        null,
        null,
      );
      if(responseCreate.statusCode==201){
        Map<String, dynamic> jsonData = responseCreate.data;
        u = User(email:jsonData['email'], uniquePseudo:jsonData['uniquePseudo'], pseudo:jsonData['pseudo'],bio:jsonData["bio"], extension:jsonData["extension"]);
      }else{
        throw Exception();
      }

      if(imageFile==null){
        callBack(u);
        return ;
      }

      final response = await Api.instance.postDataMultipart(
        'user/upload',
        {'avatar': MultipartFile.fromBytes(imageFile.fileBytes!.toList(),filename:imageFile.fileName),'uniquePseudo':u.uniquePseudo},
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
  Future<void> modify(User user,FileCustom? imageFile,Function callBack,Function callBackError) async {
    User u;
    String AuthorizationToken='Bearer ${loginModel!.token}';
    try {
      final responseCreate = await Api.instance.putData(
        'user',
        {'email': user.email, 'uniquePseudo': user.uniquePseudo,'pseudo':user.pseudo,'extension':user.extension,'bio':user.bio},
        null,
        {'Authorization': AuthorizationToken},
      );
      if(responseCreate.statusCode==201){
        Map<String, dynamic> jsonData = responseCreate.data;
        u = User(email:jsonData['email'], uniquePseudo:jsonData['uniquePseudo'], pseudo:jsonData['pseudo'],bio:jsonData["bio"], extension:jsonData["extension"]);
      }else{
        throw Exception();
      }

      if(imageFile==null){
        callBack(u);
        return ;
      }

      final response = await Api.instance.postDataMultipart(
        'user/upload',
        {'avatar': MultipartFile.fromBytes(imageFile.fileBytes!.toList(),filename:imageFile.fileName),'uniquePseudo':user.uniquePseudo},
        null,
        null,
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        DefaultCacheManager().emptyCache();
        callBack(u);
      } else {
        throw Exception();
      }
    } catch (error) {
      print('Une erreur s\'est produite : $error');
      callBackError(error);
    }
  }
  Future<void> modifyMdp(String oldMdp,String newMdp,Function callBack,Function callBackError) async {
    String AuthorizationToken='Bearer ${loginModel!.token}';
    try {
      final responseCreate = await Api.instance.putData(
        'user/mdp',
        {'oldMdp': oldMdp, 'newMdp': newMdp},
        null,
        {'Authorization': AuthorizationToken},
      );
      callBack();
    } catch (error) {
      print('Une erreur s\'est produite : $error');
      callBackError(error);
    }
  }

  void deleteAmis(User user,Function callBack,Function callBackError) {
    String AuthorizationToken='Bearer ${loginModel!.token}';
    Api.instance.deleteData(
        "amis", null, {'uniquePseudo': user.uniquePseudo}, {'Authorization': AuthorizationToken})
        .then( 
          (response) {

        callBack(user);
      },
      onError: (error) {
        callBackError(error);
      },
    );
  }
  void deleteDemandeAmis(User user,Function callBack,Function callBackError) {
    String AuthorizationToken='Bearer ${loginModel!.token}';
    Api.instance.deleteData(
        "amis/demande", null, {'uniquePseudo': user.uniquePseudo}, {'Authorization': AuthorizationToken})
        .then(
          (response) {

        callBack(user);
      },
      onError: (error) {
        callBackError(error);
      },
    );
  }
  void delete(Function callBack,Function callBackError) {
    String AuthorizationToken='Bearer ${loginModel!.token}';
    Api.instance.deleteData(
        "user", null, null, {'Authorization': AuthorizationToken})
        .then(
          (response) {

        callBack();
      },
      onError: (error) {
        callBackError(error);
      },
    );
  }
  void refuseDemandeAmis(User user,Function callBack,Function callBackError) {
    String AuthorizationToken='Bearer ${loginModel!.token}';
    Api.instance.deleteData(
        "amis/refuse", null, {'uniquePseudo': user.uniquePseudo}, {'Authorization': AuthorizationToken})
        .then(
          (response) {

        callBack(user);
      },
      onError: (error) {
        callBackError(error);
      },
    );
  }

  void addAmis(User user,Function callBack,Function callBackError) {
    String AuthorizationToken='Bearer ${loginModel!.token}';
    Api.instance.postData(
        "amis", {'uniquePseudo': user.uniquePseudo}, null, {'Authorization': AuthorizationToken})
        .then(
          (response) {

        callBack(user);
      },
      onError: (error) {
        callBackError(error);
      },
    );
  }
  void isFriend(User user,Function callBack,Function callBackError) {
    String AuthorizationToken='Bearer ${loginModel!.token}';
    Api.instance.getData(
        "amis/isAmis", {'uniquePseudo_send': user.uniquePseudo}, {'Authorization': AuthorizationToken})
        .then(
          (response) {
            Map<String, dynamic> jsonData = response.data;
        callBack((jsonData["reponse"]==1?true:false));
      },
      onError: (error) {
        callBackError(error);
      },
    );
  }
}
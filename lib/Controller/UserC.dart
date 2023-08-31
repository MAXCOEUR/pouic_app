import 'dart:io';
import 'dart:typed_data';

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:discution_app/Model/UserListeModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/outil/LoginSingleton.dart';

import '../Model/UserModel.dart';
import '../outil/Api.dart';

class UserC {
  LoginModel? loginModel=LoginModelProvider.getInstance((){}).loginModel;
  Future<void> create(User user,File imageFile,String passWord,Function callBack,Function callBackError) async {
    User u;
    try {
      final responseCreate = await Api.instance.postData(
        'user',
        {'email': user.email, 'uniquePseudo': user.uniquePseudo,'pseudo':user.pseudo,'passWord':passWord},
        null,
        null,
      );
      if(responseCreate.statusCode==201){
        Map<String, dynamic> jsonData = responseCreate.data;
        u = User(jsonData["email"], jsonData["uniquePseudo"], jsonData["pseudo"]);
      }else{
        throw Exception();
      }

      if(!imageFile.existsSync()){
        callBack(u);
        return ;
      }

      final response = await Api.instance.postDataMultipart(
        'user/upload',
        {'avatar': await MultipartFile.fromFile(imageFile.path),'uniquePseudo':u.uniquePseudo},
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
  Future<void> modify(User user,File imageFile,String passWord,Function callBack,Function callBackError) async {
    User u;
    String AuthorizationToken='Bearer ${loginModel!.token}';
    try {
      final responseCreate = await Api.instance.putData(
        'user',
        {'email': user.email, 'uniquePseudo': user.uniquePseudo,'pseudo':user.pseudo,'passWord':passWord},
        null,
        {'Authorization': AuthorizationToken},
      );
      if(responseCreate.statusCode==201){
        Map<String, dynamic> jsonData = responseCreate.data;
        u = User(
            jsonData["email"], jsonData["uniquePseudo"], jsonData["pseudo"]);
      }else{
        throw Exception();
      }

      if(!imageFile.existsSync()){
        callBack(u);
        return ;
      }

      final response = await Api.instance.postDataMultipart(
        'user/upload',
        {'avatar': await MultipartFile.fromFile(imageFile.path),'uniquePseudo':user.uniquePseudo},
        null,
        null,
      );

      print(response.statusCode);
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
}
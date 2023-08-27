import 'dart:typed_data';

import 'dart:convert';
import 'package:discution_app/Model/UserListeModel.dart';
import 'package:discution_app/outil/Constant.dart';

import '../Model/UserModel.dart';
import '../outil/Api.dart';

class UserC {
  void create(User user,String passWord,Function callBack,Function callBackError) {
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
        callBackError(error);
      },
    );
  }
  void modify(User user,String passWord,Function callBack,Function callBackError) {
    LoginModel loginModel =Constant.loginModel!;
    String AuthorizationToken='Bearer ${loginModel.token}';
    Api.putData(
        "user", {'email': user.email, 'uniquePseudo': user.uniquePseudo,'pseudo':user.pseudo,'Avatar':user.Avatar,'passWord':passWord}, null, {'Authorization': AuthorizationToken})
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
        callBackError(error);
      },
    );
  }

  void deleteAmis(User user,Function callBack,Function callBackError) {
    LoginModel loginModel =Constant.loginModel!;
    String AuthorizationToken='Bearer ${loginModel.token}';
    Api.deleteData(
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
    LoginModel loginModel =Constant.loginModel!;
    String AuthorizationToken='Bearer ${loginModel.token}';
    Api.deleteData(
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
    LoginModel loginModel =Constant.loginModel!;
    String AuthorizationToken='Bearer ${loginModel.token}';
    Api.deleteData(
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
    LoginModel loginModel =Constant.loginModel!;
    String AuthorizationToken='Bearer ${loginModel.token}';
    Api.postData(
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
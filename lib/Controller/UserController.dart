import 'package:dio/dio.dart';
import 'dart:convert';
import '../Model/UserModel.dart';
import '../outil/Api.dart';

class UserController {
  final Dio _dio = Dio();

  void create(User user,String passWord,Function callBack) {
    Api.postData(
        "user", {'email': user.email, 'uniquePseudo': user.uniquePseudo,'pseudo':user.pseudo,'Avatar':user.Avatar,'passWord':passWord}, null, null)
        .then(
          (response) {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        User u = User(
            jsonData["email"], jsonData["uniquePseudo"], jsonData["pseudo"],
            jsonData["Avatar"]);

        callBack(u);
      },
      onError: (error) {
            print("create user :"+error.toString());
        callBack(null);
      },
    );
  }
}
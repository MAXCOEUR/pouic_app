import 'package:dio/dio.dart';

class Login {
  final Dio _dio = Dio();

  Future<Response?> ask(String userOrEmail, String mdp) async {
    try {
      final response = await _dio.post(
        'http://192.168.0.172:3000/api/user/login',
        data: {'emailOrPseudo': userOrEmail, 'passWord': mdp},
      );

      return response;
    } catch (e) {
      print(e);
    }
    return null;
  }
}
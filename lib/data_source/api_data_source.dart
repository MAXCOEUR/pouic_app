import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../outil/Constant.dart';
import '../outil/LoginSingleton.dart';

class ApiDataSource {
  final String scheme;
  final String host ;
  final int port ;
  final String pathSegments ;

  final LoginModel? lm = LoginModelProvider.getInstance(() {}).loginModel;
  Dio dio = Dio();

  ApiDataSource() :
        scheme = Constant.schemeApi,
        host = Constant.ipApi,
        port = Constant.portApi,
        pathSegments = "api";

  Future<Map<String, dynamic>> getapi(List<String> endPoint,
      {Map<String, dynamic>? queryParameters}) async {
    queryParameters ??= {};

    List<String> path = [pathSegments];
    path.addAll(endPoint);

    final Uri httpUrl = Uri(
      scheme: scheme,
      host: host,
      port: port,
      pathSegments: path,
      queryParameters: queryParameters,
    );

    final http.Response response = await http.get(
      httpUrl,
      headers: {
        'Authorization': 'Bearer ${lm?.token}',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Échec de la requête HTTP : ${response.statusCode}');
    }
  }
  Future<Map<String, dynamic>> deleteapi(List<String> endPoint,
      {Map<String, dynamic>? queryParameters}) async {
    queryParameters ??= {};

    List<String> path = [pathSegments];
    path.addAll(endPoint);

    final Uri httpUrl = Uri(
      scheme: scheme,
      host: host,
      port: port,
      pathSegments: path,
      queryParameters: queryParameters,
    );

    final http.Response response = await http.delete(
      httpUrl,
      headers: {
        'Authorization': 'Bearer ${lm?.token}',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Échec de la requête HTTP : ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> postapi(List<String> endPoint,
      {Map<String, dynamic>? queryParameters,Map<String, dynamic>? bodyParameters}) async {

    List<String> path = [pathSegments];
    path.addAll(endPoint);

    final Uri httpUrl = Uri(
      scheme: scheme,
      host: host,
      port: port,
      pathSegments: path,
      queryParameters: queryParameters,
    );

    final http.Response response = await http.post(
      httpUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${lm?.token}',
      },
      body: jsonEncode(bodyParameters)
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Échec de la requête HTTP : ${response.statusCode}');
    }
  }
  Future<Map<String, dynamic>> postapiDataMultipart(
      List<String> endPoint,
      dynamic data, // Changez le type de data à dynamic
      {Map<String, dynamic>? queryParameters,}
      ) async {
    final options = Options(
      headers: {'Authorization': 'Bearer ${lm?.token}'},
      contentType:
      'multipart/form-data',
    );

    List<String> path = [pathSegments];
    path.addAll(endPoint);

    final Uri httpUrl = Uri(
      scheme: scheme,
      host: host,
      port: port,
      pathSegments: path,
      queryParameters: queryParameters,
    );

    try {
      final response = await dio.post(
        httpUrl.toString(),
        data: FormData.fromMap(data),
        queryParameters: queryParameters,
        options: options,
      );

      return response.data;
    } catch (error) {
      // Renvoyer l'erreur en cas d'échec
      rethrow;
    }
  }
}
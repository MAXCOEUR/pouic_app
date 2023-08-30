import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:discution_app/outil/Constant.dart';

class Api {
  late Dio dio;
  String baseUrl = Constant.ServeurApi + "/api/";

  Api._privateConstructor() {
    dio = Dio();
  }
  static final Api _instance = Api._privateConstructor();
  static Api get instance => _instance;

  Future<Response> postData(
    String apiUrl,
    Map<String, dynamic>? data,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? headers,
  ) async {
    final options = Options(
      headers: headers,
      contentType: 'application/json',
    );

    final String url = baseUrl + apiUrl;

    try {
      final response = await dio.post(
        url,
        data: data,
        queryParameters: parameters,
        options: options,
      );
      return response;
    } catch (error) {
      throw error;
    }
  }

  Future<Response> postDataMultipart(
    String apiUrl,
    dynamic data, // Changez le type de data à dynamic
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? headers,
  ) async {
    final options = Options(
      headers: headers,
      contentType:
          'multipart/form-data', // Utilisez 'multipart/form-data' pour les requêtes multipart
    );

    final String url = baseUrl + apiUrl;

    try {
      final response = await dio.post(
        url,
        data: FormData.fromMap(data),
        // Utilisez FormData pour les requêtes multipart
        queryParameters: parameters,
        options: options,
      );
      print(response);
      return response;
    } catch (error) {
      throw error;
    }
  }

  Future<Response> getData(
    String apiUrl,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? headers,
  ) async {
    final options = Options(
      headers: headers,
      contentType: 'application/json',
    );

    final String url = baseUrl + apiUrl;

    try {
      final response = await dio.get(
        url,
        queryParameters: parameters,
        options: options,
      );
      return response;
    } catch (error) {
      throw Exception('Erreur lors de la requête : $error');
    }
  }

  Future<Response> putData(
    String apiUrl,
    Map<String, dynamic>? data,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? headers,
  ) async {
    final options = Options(
      headers: headers,
      contentType: 'application/json',
    );

    final String url = baseUrl + apiUrl;

    try {
      final response = await dio.put(
        url,
        data: data,
        queryParameters: parameters,
        options: options,
      );
      return response;
    } catch (error) {
      throw Exception('Erreur lors de la requête : $error');
    }
  }

  Future<Response> deleteData(
    String apiUrl,
    Map<String, dynamic>? data,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? headers,
  ) async {
    final options = Options(
      headers: headers,
      contentType: 'application/json',
    );

    final String url = baseUrl + apiUrl;

    try {
      final response = await dio.delete(
        url,
        data: data,
        queryParameters: parameters,
        options: options,
      );
      return response;
    } catch (error) {
      throw Exception('Erreur lors de la requête : $error');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:discution_app/outil/Constant.dart';

class Api {
  static final Dio _dio = Dio();
  static const String baseUrl =Constant.ServeurApi+"/api/";

  static Future<Response> postData(
      String apiUrl,
      Map<String, dynamic>? data,
      Map<String, dynamic>? parameters,
      Map<String, dynamic>? headers,
      ) async {
    final options = Options(
      headers: headers,
      contentType: 'application/json',
    );

    final String url = baseUrl+apiUrl;

    try {
      final response = await _dio.post(
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
  static Future<Response> postDataMultipart(
      String apiUrl,
      dynamic data, // Changez le type de data à dynamic
      Map<String, dynamic>? parameters,
      Map<String, dynamic>? headers,
      ) async {
    final options = Options(
      headers: headers,
      contentType: 'multipart/form-data', // Utilisez 'multipart/form-data' pour les requêtes multipart
    );

    final String url = baseUrl + apiUrl;

    try {
      final response = await _dio.post(
        url,
        data: FormData.fromMap(data), // Utilisez FormData pour les requêtes multipart
        queryParameters: parameters,
        options: options,
      );
      print(response);
      return response;
    } catch (error) {
      throw error;
    }
  }

  static Future<Response> getData(
      String apiUrl,
      Map<String, dynamic>? parameters,
      Map<String, dynamic>? headers,
      ) async {
    final options = Options(
      headers: headers,
      contentType: 'application/json',
    );

    final String url = baseUrl+apiUrl;

    try {
      final response = await _dio.get(
        url,
        queryParameters: parameters,
        options: options,
      );
      return response;
    } catch (error) {
      throw Exception('Erreur lors de la requête : $error');
    }
  }
  static Future<Response> putData(
      String apiUrl,
      Map<String, dynamic>? data,
      Map<String, dynamic>? parameters,
      Map<String, dynamic>? headers,
      ) async {
    final options = Options(
      headers: headers,
      contentType: 'application/json',
    );

    final String url = baseUrl+apiUrl;

    try {
      final response = await _dio.put(
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
  static Future<Response> deleteData(
      String apiUrl,
      Map<String, dynamic>? data,
      Map<String, dynamic>? parameters,
      Map<String, dynamic>? headers,
      ) async {
    final options = Options(
      headers: headers,
      contentType: 'application/json',
    );

    final String url = baseUrl+apiUrl;

    try {
      final response = await _dio.delete(
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

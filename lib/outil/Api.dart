import 'package:dio/dio.dart';

class Api {
  static final Dio _dio = Dio();
  static final String baseUrl ="http://46.227.18.31:3000/api/";

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

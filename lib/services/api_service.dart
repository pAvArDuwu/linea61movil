import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum ApiBackend { laravel, dart }

class ApiService {
  // En un emulador Android, 10.0.2.2 apunta al PC anfitrión.
  static const String laravelBaseUrl = 'http://10.0.2.2/api';
  static const String laravelHost = 'linea57_control.test';
  static const String dartBaseUrl = 'http://10.0.2.2:8000/api';
  final _storage = const FlutterSecureStorage();

  String _baseUrl(ApiBackend backend) {
    return backend == ApiBackend.dart ? dartBaseUrl : laravelBaseUrl;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Map<String, String>> _getHeaders(ApiBackend backend) async {
    String? token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (backend == ApiBackend.laravel) 'Host': laravelHost,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data, {
    ApiBackend backend = ApiBackend.laravel,
  }) async {
    final url = Uri.parse('${_baseUrl(backend)}$endpoint');
    final headers = await _getHeaders(backend);
    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> get(
    String endpoint, {
    ApiBackend backend = ApiBackend.laravel,
  }) async {
    final url = Uri.parse('${_baseUrl(backend)}$endpoint');
    final headers = await _getHeaders(backend);
    return await http.get(url, headers: headers);
  }

  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> data, {
    ApiBackend backend = ApiBackend.laravel,
  }) async {
    final url = Uri.parse('${_baseUrl(backend)}$endpoint');
    final headers = await _getHeaders(backend);
    return await http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> delete(
    String endpoint, {
    ApiBackend backend = ApiBackend.laravel,
  }) async {
    final url = Uri.parse('${_baseUrl(backend)}$endpoint');
    final headers = await _getHeaders(backend);
    return await http.delete(url, headers: headers);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}

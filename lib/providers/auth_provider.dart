import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? _error;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;

  bool get isAdmin {
    final roles = _user?['roles'];
    if (roles is List) {
      return roles.any((role) => role is Map && role['name'] == 'admin');
    }
    return _user?['role'] == 'admin';
  }

  Future<bool> login(String email, String password) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/login', {
        'email': email,
        'password': password,
        'device_name': 'mobile_app',
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['access_token'] != null) {
        // El API devuelve {"access_token": "...", "token_type": "Bearer"}
        await _apiService.saveToken(data['access_token']);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        // Cargar datos del usuario
        await _fetchUser();
        return true;
      } else {
        _error = data['error'] ?? data['message'] ?? 'Error al iniciar sesión';
        _isAuthenticated = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _fetchUser() async {
    try {
      // El API usa /me para obtener el usuario actual
      final response = await _apiService.get('/me');
      if (response.statusCode == 200) {
        _user = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (_) {
      // Silenciar error, el usuario ya está autenticado
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/logout', {});
    } catch (e) {
      // Ignorar error al cerrar sesión
    }
    await _apiService.deleteToken();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    String? token = await _apiService.getToken();
    if (token != null) {
      try {
        // Usar /me en vez de /user (coincide con el endpoint del backend)
        final response = await _apiService.get('/me');
        if (response.statusCode == 200) {
          _user = jsonDecode(response.body);
          _isAuthenticated = true;
        } else {
          await _apiService.deleteToken();
          _isAuthenticated = false;
        }
      } catch (e) {
        _isAuthenticated = false;
      }
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
  }
}

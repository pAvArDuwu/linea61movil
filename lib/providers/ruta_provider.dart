import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/ruta.dart';
import '../services/api_service.dart';

class RutaProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<Ruta> _rutas = [];
  Ruta? _selected;
  bool _isLoading = false;
  String? _error;

  List<Ruta> get rutas => _rutas;
  Ruta? get selected => _selected;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/rutas');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _rutas = data.map((e) => Ruta.fromJson(e)).toList();
      } else {
        _error = 'Error al cargar rutas';
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Ruta?> fetchById(int id) async {
    try {
      final response = await _api.get('/rutas/$id');
      if (response.statusCode == 200) {
        _selected = Ruta.fromJson(jsonDecode(response.body));
        notifyListeners();
        return _selected;
      }
    } catch (e) {
      _error = 'Error: $e';
    }
    return null;
  }

  Future<bool> create(Ruta ruta) async {
    try {
      final response = await _api.post('/rutas', ruta.toJson());
      if (response.statusCode == 201) {
        await fetchAll();
        return true;
      }
      _error = 'Error al crear ruta';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }

  Future<bool> update(int id, Ruta ruta) async {
    try {
      final response = await _api.put('/rutas/$id', ruta.toJson());
      if (response.statusCode == 200) {
        await fetchAll();
        return true;
      }
      _error = 'Error al actualizar ruta';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }

  Future<bool> delete(int id) async {
    try {
      final response = await _api.delete('/rutas/$id');
      if (response.statusCode == 200) {
        await fetchAll();
        return true;
      }
      _error = 'Error al eliminar ruta';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }
}

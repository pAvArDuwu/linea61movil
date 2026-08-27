import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/parada.dart';
import '../services/api_service.dart';

class ParadaProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<Parada> _paradas = [];
  Parada? _selected;
  bool _isLoading = false;
  String? _error;

  List<Parada> get paradas => _paradas;
  Parada? get selected => _selected;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/paradas');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _paradas = data.map((e) => Parada.fromJson(e)).toList();
      } else {
        _error = 'Error al cargar paradas';
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Parada?> fetchById(int id) async {
    try {
      final response = await _api.get('/paradas/$id');
      if (response.statusCode == 200) {
        _selected = Parada.fromJson(jsonDecode(response.body));
        notifyListeners();
        return _selected;
      }
    } catch (e) {
      _error = 'Error: $e';
    }
    return null;
  }

  Future<bool> create(Parada parada) async {
    try {
      final response = await _api.post('/paradas', parada.toJson());
      if (response.statusCode == 201) {
        await fetchAll();
        return true;
      }
      _error = 'Error al crear parada';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }

  Future<bool> update(int id, Parada parada) async {
    try {
      final response = await _api.put('/paradas/$id', parada.toJson());
      if (response.statusCode == 200) {
        await fetchAll();
        return true;
      }
      _error = 'Error al actualizar parada';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }

  Future<bool> delete(int id) async {
    try {
      final response = await _api.delete('/paradas/$id');
      if (response.statusCode == 200) {
        await fetchAll();
        return true;
      }
      _error = 'Error al eliminar parada';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }
}

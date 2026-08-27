import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/micro.dart';
import '../services/api_service.dart';

class MicroProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<Micro> _micros = [];
  Micro? _selected;
  bool _isLoading = false;
  String? _error;

  List<Micro> get micros => _micros;
  Micro? get selected => _selected;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/micros');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _micros = data.map((e) => Micro.fromJson(e)).toList();
      } else {
        _error = 'Error al cargar micros';
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Micro?> fetchById(int id) async {
    try {
      final response = await _api.get('/micros/$id');
      if (response.statusCode == 200) {
        _selected = Micro.fromJson(jsonDecode(response.body));
        notifyListeners();
        return _selected;
      }
    } catch (e) {
      _error = 'Error: $e';
    }
    return null;
  }

  Future<bool> create(Micro micro) async {
    try {
      final response = await _api.post('/micros', micro.toJson());
      if (response.statusCode == 201) {
        await fetchAll();
        return true;
      }
      _error = 'Error al crear micro';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }

  Future<bool> update(int id, Micro micro) async {
    try {
      final response = await _api.put('/micros/$id', micro.toJson());
      if (response.statusCode == 200) {
        await fetchAll();
        return true;
      }
      _error = 'Error al actualizar micro';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }

  Future<bool> delete(int id) async {
    try {
      final response = await _api.delete('/micros/$id');
      if (response.statusCode == 200) {
        await fetchAll();
        return true;
      }
      _error = 'Error al eliminar micro';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }
}

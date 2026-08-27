import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/interno.dart';
import '../services/api_service.dart';

class InternoProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<Interno> _internos = [];
  Interno? _selected;
  bool _isLoading = false;
  String? _error;

  List<Interno> get internos => _internos;
  Interno? get selected => _selected;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/internos');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _internos = data.map((e) => Interno.fromJson(e)).toList();
      } else {
        _error = 'Error al cargar internos';
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Interno?> fetchById(int id) async {
    try {
      final response = await _api.get('/internos/$id');
      if (response.statusCode == 200) {
        _selected = Interno.fromJson(jsonDecode(response.body));
        notifyListeners();
        return _selected;
      }
    } catch (e) {
      _error = 'Error: $e';
    }
    return null;
  }

  Future<bool> create(Interno interno) async {
    try {
      final response = await _api.post('/internos', interno.toJson());
      if (response.statusCode == 201) {
        await fetchAll();
        return true;
      }
      _error = 'Error al crear interno';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }

  Future<bool> update(int id, Interno interno) async {
    try {
      final response = await _api.put('/internos/$id', interno.toJson());
      if (response.statusCode == 200) {
        await fetchAll();
        return true;
      }
      _error = 'Error al actualizar interno';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }

  Future<bool> delete(int id) async {
    try {
      final response = await _api.delete('/internos/$id');
      if (response.statusCode == 200) {
        await fetchAll();
        return true;
      }
      _error = 'Error al eliminar interno';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }
}

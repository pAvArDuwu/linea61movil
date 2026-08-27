import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/conductor.dart';
import '../services/api_service.dart';

class ConductorProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<Conductor> _conductores = [];
  Conductor? _selected;
  bool _isLoading = false;
  String? _error;

  List<Conductor> get conductores => _conductores;
  Conductor? get selected => _selected;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/conductores');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _conductores = data.map((e) => Conductor.fromJson(e)).toList();
      } else {
        _error = 'Error al cargar conductores';
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Conductor?> fetchById(int id) async {
    try {
      final response = await _api.get('/conductores/$id');
      if (response.statusCode == 200) {
        _selected = Conductor.fromJson(jsonDecode(response.body));
        notifyListeners();
        return _selected;
      }
    } catch (e) {
      _error = 'Error: $e';
    }
    return null;
  }

  Future<bool> create(Conductor conductor) async {
    try {
      final response = await _api.post('/conductores', conductor.toJson());
      if (response.statusCode == 201) {
        await fetchAll();
        return true;
      }
      _error = 'Error al crear conductor';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }

  Future<bool> update(int id, Conductor conductor) async {
    try {
      final response = await _api.put('/conductores/$id', conductor.toJson());
      if (response.statusCode == 200) {
        await fetchAll();
        return true;
      }
      _error = 'Error al actualizar conductor';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }

  Future<bool> delete(int id) async {
    try {
      final response = await _api.delete('/conductores/$id');
      if (response.statusCode == 200) {
        await fetchAll();
        return true;
      }
      _error = 'Error al eliminar conductor';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }
}

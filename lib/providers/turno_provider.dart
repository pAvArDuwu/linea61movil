import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/turno.dart';
import '../services/api_service.dart';

class TurnoProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<Turno> _turnos = [];
  Turno? _selected;
  bool _isLoading = false;
  String? _error;

  List<Turno> get turnos => _turnos;
  Turno? get selected => _selected;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/turnos');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _turnos = data.map((e) => Turno.fromJson(e)).toList();
      } else {
        _error = 'Error al cargar turnos';
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Turno?> fetchById(int id) async {
    try {
      final response = await _api.get('/turnos/$id');
      if (response.statusCode == 200) {
        _selected = Turno.fromJson(jsonDecode(response.body));
        notifyListeners();
        return _selected;
      }
    } catch (e) {
      _error = 'Error: $e';
    }
    return null;
  }

  Future<bool> create(Turno turno) async {
    try {
      final response = await _api.post('/turnos', turno.toJson());
      if (response.statusCode == 201) {
        await fetchAll();
        return true;
      }
      _error = 'Error al crear turno';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }

  Future<bool> update(int id, Turno turno) async {
    try {
      final response = await _api.put('/turnos/$id', turno.toJson());
      if (response.statusCode == 200) {
        await fetchAll();
        return true;
      }
      _error = 'Error al actualizar turno';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }

  Future<bool> delete(int id) async {
    try {
      final response = await _api.delete('/turnos/$id');
      if (response.statusCode == 200) {
        await fetchAll();
        return true;
      }
      _error = 'Error al eliminar turno';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }
}

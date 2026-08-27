import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/propietario.dart';
import '../services/api_service.dart';

class PropietarioProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<Propietario> _propietarios = [];
  Propietario? _selected;
  bool _isLoading = false;
  String? _error;

  List<Propietario> get propietarios => _propietarios;
  Propietario? get selected => _selected;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/propietarios');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _propietarios = data.map((e) => Propietario.fromJson(e)).toList();
      } else {
        _error = 'Error al cargar propietarios';
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Propietario?> fetchById(int id) async {
    try {
      final response = await _api.get('/propietarios/$id');
      if (response.statusCode == 200) {
        _selected = Propietario.fromJson(jsonDecode(response.body));
        notifyListeners();
        return _selected;
      }
    } catch (e) {
      _error = 'Error: $e';
    }
    return null;
  }

  Future<bool> create(Propietario propietario) async {
    try {
      final response = await _api.post('/propietarios', propietario.toJson());
      if (response.statusCode == 201) {
        await fetchAll();
        return true;
      }
      _error = 'Error al crear propietario';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }

  Future<bool> update(int id, Propietario propietario) async {
    try {
      final response = await _api.put('/propietarios/$id', propietario.toJson());
      if (response.statusCode == 200) {
        await fetchAll();
        return true;
      }
      _error = 'Error al actualizar propietario';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }

  Future<bool> delete(int id) async {
    try {
      final response = await _api.delete('/propietarios/$id');
      if (response.statusCode == 200) {
        await fetchAll();
        return true;
      }
      _error = 'Error al eliminar propietario';
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }
}

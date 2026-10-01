import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/asignacion_turno.dart';
import '../services/api_service.dart';

class AsignacionTurnoProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<AsignacionTurno> _asignaciones = [];
  AsignacionTurno? _asignacionActual;
  List<dynamic> _paradasCumplidas = [];
  bool _isLoading = false;
  String? _error;

  List<AsignacionTurno> get asignaciones => _asignaciones;
  AsignacionTurno? get asignacionActual => _asignacionActual;
  List<dynamic> get paradasCumplidas => _paradasCumplidas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setError(String message) {
    _error = message;
    notifyListeners();
  }

  Future<bool> create({
    required int turnoId,
    required int rutaId,
    required int microId,
    required int conductorId,
    required String fecha,
    String? observaciones,
  }) async {
    try {
      final response = await _api.post('/asignaciones', {
        'turno_id': turnoId,
        'ruta_id': rutaId,
        'micro_id': microId,
        'conductor_id': conductorId,
        'fecha': fecha,
        if (observaciones != null && observaciones.trim().isNotEmpty)
          'observaciones': observaciones.trim(),
      }, backend: ApiBackend.dart);
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchAll();
        return true;
      }
      _error = _messageFromResponse(response.body, 'No se pudo crear la asignación');
    } catch (e) {
      _error = 'Error de conexión: $e';
    }
    notifyListeners();
    return false;
  }

  String _messageFromResponse(String body, String fallback) {
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ?? data['error']?.toString() ?? fallback;
      }
    } catch (_) {
      // Mantener un mensaje legible si el backend no devuelve JSON.
    }
    return fallback;
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/asignaciones', backend: ApiBackend.dart);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = decoded is Map && decoded.containsKey('data') 
            ? decoded['data'] 
            : (decoded is List ? decoded : []);
        _asignaciones = data.map((e) => AsignacionTurno.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        _error = 'Error al cargar asignaciones (${response.statusCode})';
      }
    } catch (e) {
      _error = 'Error: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMisAsignaciones({required int conductorId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/asignaciones/conductor/$conductorId', backend: ApiBackend.dart);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = decoded is List ? decoded : [];
        _asignaciones = data.map((e) => AsignacionTurno.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        await fetchAll();
        return;
      }
    } catch (e) {
      _error = 'Error: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<AsignacionTurno?> fetchMiAsignacionActual({required int conductorId}) async {
    try {
      final response = await _api.get('/asignaciones/conductor/$conductorId/actual', backend: ApiBackend.dart);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        _asignacionActual = AsignacionTurno.fromJson(decoded as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        _asignacionActual = null;
      }
    } catch (e) {
      // Silenciar
    }
    notifyListeners();
    return _asignacionActual;
  }

  Future<bool> iniciarTurno(int asignacionId) async {
    try {
      final response = await _api.post('/asignaciones/$asignacionId/iniciar', {}, backend: ApiBackend.dart);
      if (response.statusCode == 200) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'No se pudo iniciar el turno';
      }
    } catch (e) {
      _error = 'Error: $e';
    }
    notifyListeners();
    return false;
  }

  Future<bool> finalizarTurno(int asignacionId) async {
    try {
      final response = await _api.post('/asignaciones/$asignacionId/finalizar', {}, backend: ApiBackend.dart);
      if (response.statusCode == 200) return true;
      _error = _messageFromResponse(response.body, 'No se pudo finalizar el turno');
    } catch (e) {
      _error = 'Error de conexión: $e';
    }
    notifyListeners();
    return false;
  }

  /// Envía un punto GPS al backend para seguimiento y control de paradas (SDD Sección 9 y 11)
  Future<Map<String, dynamic>?> enviarUbicacionGps({
    required int asignacionId,
    required double latitud,
    required double longitud,
    double velocidad = 0.0,
  }) async {
    try {
      final response = await _api.post('/mis/asignaciones/$asignacionId/ubicaciones', {
        'fecha_hora_gps': DateTime.now().toUtc().toIso8601String(),
        'latitud': latitud,
        'longitud': longitud,
        'velocidad': velocidad,
      }, backend: ApiBackend.dart);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Si el backend culminó automáticamente el turno por GPS:
        if (data['data'] != null && data['data']['asignacion_estado'] == 'completado') {
          _asignacionActual = null;
        }
        return data;
      }
    } catch (e) {
      // Silenciar en envíos periódicos de GPS
    }
    return null;
  }

  /// Sincroniza un lote de ubicaciones almacenadas offline (SDD Sección 17)
  Future<bool> sincronizarUbicacionesOffline({
    required int asignacionId,
    required List<Map<String, dynamic>> ubicacionesOffline,
  }) async {
    if (ubicacionesOffline.isEmpty) return true;

    try {
      final puntos = ubicacionesOffline
          .map((ubicacion) => {
                ...ubicacion,
                'asignacion_turno_id': asignacionId,
              })
          .toList();
      final response = await _api.post('/mis/ubicaciones/sincronizar', {
        'puntos': puntos,
      }, backend: ApiBackend.dart);

      if (response.statusCode == 200) {
        _asignacionActual = null;
        return true;
      }
    } catch (e) {
      _error = 'Error al sincronizar puntos offline: $e';
    }
    return false;
  }
}
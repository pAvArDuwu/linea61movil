import 'conductor.dart';
import 'micro.dart';
import 'ruta.dart';
import 'turno.dart';

class AsignacionTurno {
  final int? id;
  final int? turnoId;
  final int? rutaId;
  final int? microId;
  final int? conductorId;
  final String? fecha;
  final String? horaSalida;
  final String? horaLlegada;
  final String? estado;
  final String? observaciones;
  final Turno? turno;
  final Conductor? conductor;
  final Micro? micro;
  final Ruta? ruta;

  AsignacionTurno({
    this.id,
    this.turnoId,
    this.rutaId,
    this.microId,
    this.conductorId,
    this.fecha,
    this.horaSalida,
    this.horaLlegada,
    this.estado,
    this.observaciones,
    this.turno,
    this.conductor,
    this.micro,
    this.ruta,
  });

  factory AsignacionTurno.fromJson(Map<String, dynamic> json) {
    return AsignacionTurno(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      turnoId: json['turno_id'] != null ? int.tryParse(json['turno_id'].toString()) : null,
      rutaId: json['ruta_id'] != null ? int.tryParse(json['ruta_id'].toString()) : null,
      microId: json['micro_id'] != null ? int.tryParse(json['micro_id'].toString()) : null,
      conductorId: json['conductor_id'] != null ? int.tryParse(json['conductor_id'].toString()) : null,
      fecha: json['fecha']?.toString(),
      horaSalida: json['hora_salida']?.toString(),
      horaLlegada: json['hora_llegada']?.toString(),
      estado: json['estado']?.toString() ?? 'pendiente',
      observaciones: json['observaciones']?.toString(),
      turno: json['turno'] is Map<String, dynamic> ? Turno.fromJson(json['turno']) : null,
      conductor: json['conductor'] is Map<String, dynamic> ? Conductor.fromJson(json['conductor']) : null,
      micro: json['micro'] is Map<String, dynamic> ? Micro.fromJson(json['micro']) : null,
      ruta: json['ruta'] is Map<String, dynamic> ? Ruta.fromJson(json['ruta']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'turno_id': turnoId,
      'ruta_id': rutaId,
      'micro_id': microId,
      'conductor_id': conductorId,
      'fecha': fecha,
      'hora_salida': horaSalida,
      'hora_llegada': horaLlegada,
      'estado': estado ?? 'pendiente',
      'observaciones': observaciones,
    };
  }
}
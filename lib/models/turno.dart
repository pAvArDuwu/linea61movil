class Turno {
  final int? id;
  final String? nombre;
  final String? tipo;
  final String? horaInicio;
  final String? horaFin;
  final String? descripcion;
  final String? estado;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Turno({
    this.id,
    this.nombre,
    this.tipo,
    this.horaInicio,
    this.horaFin,
    this.descripcion,
    this.estado,
    this.createdAt,
    this.updatedAt,
  });

  String get displayNombre {
    if (nombre != null && nombre!.isNotEmpty) {
      return nombre![0].toUpperCase() + nombre!.substring(1);
    }
    if (tipo != null && tipo!.isNotEmpty) {
      return tipo![0].toUpperCase() + tipo!.substring(1);
    }
    return 'Turno';
  }

  factory Turno.fromJson(Map<String, dynamic> json) {
    return Turno(
      id: json['id'],
      nombre: json['nombre'] ?? json['tipo'],
      tipo: json['tipo'] ?? json['nombre'],
      horaInicio: json['hora_inicio'],
      horaFin: json['hora_fin'],
      descripcion: json['descripcion'],
      estado: json['estado'] ?? 'activo',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre ?? tipo,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'descripcion': descripcion,
      'estado': estado ?? 'activo',
    };
  }
}
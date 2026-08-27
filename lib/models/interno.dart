class Interno {
  final int? id;
  final String numeroInterno;
  final String? fechaIngreso;
  final String? observaciones;
  final String estado;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Interno({
    this.id,
    required this.numeroInterno,
    this.fechaIngreso,
    this.observaciones,
    this.estado = 'activo',
    this.createdAt,
    this.updatedAt,
  });

  factory Interno.fromJson(Map<String, dynamic> json) {
    return Interno(
      id: json['id'],
      numeroInterno: json['numero_interno']?.toString() ?? '',
      fechaIngreso: json['fecha_ingreso'],
      observaciones: json['observaciones'],
      estado: json['estado'] ?? 'activo',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero_interno': numeroInterno,
      'fecha_ingreso': fechaIngreso,
      'observaciones': observaciones,
      'estado': estado,
    };
  }
}

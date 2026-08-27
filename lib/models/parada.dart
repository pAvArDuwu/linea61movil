class Parada {
  final int? id;
  final String nombre;
  final String? referencia;
  final double? latitud;
  final double? longitud;
  final String estado;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Parada({
    this.id,
    required this.nombre,
    this.referencia,
    this.latitud,
    this.longitud,
    this.estado = 'activo',
    this.createdAt,
    this.updatedAt,
  });

  factory Parada.fromJson(Map<String, dynamic> json) {
    return Parada(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      referencia: json['referencia'],
      latitud: json['latitud'] != null ? double.tryParse(json['latitud'].toString()) : null,
      longitud: json['longitud'] != null ? double.tryParse(json['longitud'].toString()) : null,
      estado: json['estado'] ?? 'activo',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'referencia': referencia,
      'latitud': latitud,
      'longitud': longitud,
      'estado': estado,
    };
  }
}

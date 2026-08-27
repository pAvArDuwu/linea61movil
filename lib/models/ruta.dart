class Ruta {
  final int? id;
  final String nombre;
  final String? descripcion;
  final String? sentido;
  final String estado;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Ruta({
    this.id,
    required this.nombre,
    this.descripcion,
    this.sentido,
    this.estado = 'activo',
    this.createdAt,
    this.updatedAt,
  });

  factory Ruta.fromJson(Map<String, dynamic> json) {
    return Ruta(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      sentido: json['sentido']?.toString(),
      estado: json['estado']?.toString() ?? 'activo',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'sentido': sentido,
      'estado': estado,
    };
  }
}
class Propietario {
  final int? id;
  final String nombre;
  final String apellido;
  final String? telefono;
  final String? correo;
  final String? ci;
  final String estado;
  final String? fechaRegistro;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Propietario({
    this.id,
    required this.nombre,
    required this.apellido,
    this.telefono,
    this.correo,
    this.ci,
    this.estado = 'activo',
    this.fechaRegistro,
    this.createdAt,
    this.updatedAt,
  });

  factory Propietario.fromJson(Map<String, dynamic> json) {
    return Propietario(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      telefono: json['telefono'],
      correo: json['correo'],
      ci: json['ci'],
      estado: json['estado'] ?? 'activo',
      fechaRegistro: json['fecha_registro'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'correo': correo,
      'ci': ci,
      'estado': estado,
      'fecha_registro': fechaRegistro,
    };
  }

  String get nombreCompleto => '$nombre $apellido';
  String get iniciales => '${nombre.isNotEmpty ? nombre[0] : ''}${apellido.isNotEmpty ? apellido[0] : ''}'.toUpperCase();
}

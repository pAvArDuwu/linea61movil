class Micro {
  final int? id;
  final int? propietarioId;
  final int? internoId;
  final String placa;
  final String? chasis;
  final dynamic anioFabricacion;
  final String modelo;
  final String marca;
  final int capacidadPasajeros;
  final String estado;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Micro({
    this.id,
    this.propietarioId,
    this.internoId,
    required this.placa,
    this.chasis,
    this.anioFabricacion,
    required this.modelo,
    required this.marca,
    required this.capacidadPasajeros,
    this.estado = 'activo',
    this.createdAt,
    this.updatedAt,
  });

  factory Micro.fromJson(Map<String, dynamic> json) {
    return Micro(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      propietarioId: json['propietario_id'] != null ? int.tryParse(json['propietario_id'].toString()) : null,
      internoId: json['interno_id'] != null ? int.tryParse(json['interno_id'].toString()) : null,
      placa: json['placa']?.toString() ?? '',
      chasis: json['chasis']?.toString(),
      anioFabricacion: json['anio_fabricacion'],
      modelo: json['modelo']?.toString() ?? '',
      marca: json['marca']?.toString() ?? '',
      capacidadPasajeros: json['capacidad_pasajeros'] != null ? (int.tryParse(json['capacidad_pasajeros'].toString()) ?? 0) : 0,
      estado: json['estado']?.toString() ?? 'activo',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'propietario_id': propietarioId,
      'interno_id': internoId,
      'placa': placa,
      'chasis': chasis,
      'anio_fabricacion': anioFabricacion,
      'modelo': modelo,
      'marca': marca,
      'capacidad_pasajeros': capacidadPasajeros,
      'estado': estado,
    };
  }

  String get vehiculoCompleto => '$marca $modelo';
}
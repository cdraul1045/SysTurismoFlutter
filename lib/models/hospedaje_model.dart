class Hospedaje {
  final int? idHospedaje;
  final String nombre;
  final String? descripcion;
  final double? precioPorNoche;
  final int? idDestino;
  final String? imagenPath;
  final String? whatsappContacto;
  final String? direccion;

  Hospedaje({
    this.idHospedaje,
    required this.nombre,
    this.descripcion,
    this.precioPorNoche,
    this.idDestino,
    this.imagenPath,
    this.whatsappContacto,
    this.direccion,
  });

  factory Hospedaje.fromJson(Map<String, dynamic> json) {
    return Hospedaje(
      idHospedaje: json['idHospedaje'] as int?,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      precioPorNoche: (json['precioPorNoche'] as num?)?.toDouble(),
      idDestino: json['idDestino'] as int?,
      imagenPath: json['imagenPath'] as String?,
      whatsappContacto: json['whatsappContacto'] as String?,
      direccion: json['direccion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idHospedaje': idHospedaje,
      'nombre': nombre,
      'descripcion': descripcion,
      'precioPorNoche': precioPorNoche,
      'idDestino': idDestino,
      'imagenPath': imagenPath,
      'whatsappContacto': whatsappContacto,
      'direccion': direccion,
    };
  }

  Hospedaje copyWith({
    int? idHospedaje,
    String? nombre,
    String? descripcion,
    double? precioPorNoche,
    int? idDestino,
    String? imagenPath,
    String? whatsappContacto,
    String? direccion,
  }) {
    return Hospedaje(
      idHospedaje: idHospedaje ?? this.idHospedaje,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precioPorNoche: precioPorNoche ?? this.precioPorNoche,
      idDestino: idDestino ?? this.idDestino,
      imagenPath: imagenPath ?? this.imagenPath,
      whatsappContacto: whatsappContacto ?? this.whatsappContacto,
      direccion: direccion ?? this.direccion,
    );
  }
} 
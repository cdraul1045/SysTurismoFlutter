class Actividad {
  final int? idActividad;
  final String? nombre;
  final String? descripcion;
  final double? precio;
  final int? idDestino;
  final String? nivelRiesgo;
  final String? whatsappContacto;
  final String? imagenPath;

  Actividad({
    this.idActividad,
    this.nombre,
    this.descripcion,
    this.precio,
    this.idDestino,
    this.nivelRiesgo,
    this.whatsappContacto,
    this.imagenPath,
  });

  factory Actividad.fromJson(Map<String, dynamic> json) {
    return Actividad(
      idActividad: json['idActividad'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: json['precio']?.toDouble(),
      idDestino: json['idDestino'],
      nivelRiesgo: json['nivelRiesgo'],
      whatsappContacto: json['whatsappContacto'],
      imagenPath: json['imagenPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idActividad': idActividad,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'idDestino': idDestino,
      'nivelRiesgo': nivelRiesgo,
      'whatsappContacto': whatsappContacto,
      'imagenPath': imagenPath,
    };
  }

  Actividad copyWith({
    int? idActividad,
    String? nombre,
    String? descripcion,
    double? precio,
    int? idDestino,
    String? nivelRiesgo,
    String? whatsappContacto,
    String? imagenPath,
  }) {
    return Actividad(
      idActividad: idActividad ?? this.idActividad,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      idDestino: idDestino ?? this.idDestino,
      nivelRiesgo: nivelRiesgo ?? this.nivelRiesgo,
      whatsappContacto: whatsappContacto ?? this.whatsappContacto,
      imagenPath: imagenPath ?? this.imagenPath,
    );
  }
} 
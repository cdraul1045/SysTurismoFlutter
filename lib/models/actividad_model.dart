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
      idActividad: json['id_actividad'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: json['precio']?.toDouble(),
      idDestino: json['id_destino'],
      nivelRiesgo: json['nivel_riesgo'],
      whatsappContacto: json['whatsapp_contacto'],
      imagenPath: json['imagen_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_actividad': idActividad,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'id_destino': idDestino,
      'nivel_riesgo': nivelRiesgo,
      'whatsapp_contacto': whatsappContacto,
      'imagen_path': imagenPath,
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
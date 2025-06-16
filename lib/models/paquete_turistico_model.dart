class PaqueteTuristico {
  final int? idPaqueteTuristico;
  final int? idDestino;
  final String nombre;
  final String? descripcion;
  final int duracionDias;
  final double precioTotal;
  final String? whatsappContacto;
  final String? imagenPath;

  PaqueteTuristico({
    this.idPaqueteTuristico,
    this.idDestino,
    required this.nombre,
    this.descripcion,
    required this.duracionDias,
    required this.precioTotal,
    this.whatsappContacto,
    this.imagenPath,
  });

  factory PaqueteTuristico.fromJson(Map<String, dynamic> json) {
    return PaqueteTuristico(
      idPaqueteTuristico: json['idPaqueteTuristico'],
      idDestino: json['idDestino'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      duracionDias: json['duracionDias'],
      precioTotal: json['precioTotal']?.toDouble() ?? 0.0,
      whatsappContacto: json['whatsappContacto'],
      imagenPath: json['imagenPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPaqueteTuristico': idPaqueteTuristico,
      'idDestino': idDestino,
      'nombre': nombre,
      'descripcion': descripcion,
      'duracionDias': duracionDias,
      'precioTotal': precioTotal,
      'whatsappContacto': whatsappContacto,
      'imagenPath': imagenPath,
    };
  }

  PaqueteTuristico copyWith({
    int? idPaqueteTuristico,
    int? idDestino,
    String? nombre,
    String? descripcion,
    int? duracionDias,
    double? precioTotal,
    String? whatsappContacto,
    String? imagenPath,
  }) {
    return PaqueteTuristico(
      idPaqueteTuristico: idPaqueteTuristico ?? this.idPaqueteTuristico,
      idDestino: idDestino ?? this.idDestino,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      duracionDias: duracionDias ?? this.duracionDias,
      precioTotal: precioTotal ?? this.precioTotal,
      whatsappContacto: whatsappContacto ?? this.whatsappContacto,
      imagenPath: imagenPath ?? this.imagenPath,
    );
  }
} 
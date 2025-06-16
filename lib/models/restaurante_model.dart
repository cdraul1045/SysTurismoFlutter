class Restaurante {
  final int? idRestaurante;
  final int? idDestino;
  final String nombre;
  final String? descripcion;
  final String? direccion;
  final String? whatsappContacto;
  final String? imagenPath;

  Restaurante({
    this.idRestaurante,
    this.idDestino,
    required this.nombre,
    this.descripcion,
    this.direccion,
    this.whatsappContacto,
    this.imagenPath,
  });

  factory Restaurante.fromJson(Map<String, dynamic> json) {
    return Restaurante(
      idRestaurante: json['idRestaurante'],
      idDestino: json['idDestino'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      direccion: json['direccion'],
      whatsappContacto: json['whatsappContacto'],
      imagenPath: json['imagenPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idRestaurante': idRestaurante,
      'idDestino': idDestino,
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'whatsappContacto': whatsappContacto,
      'imagenPath': imagenPath,
    };
  }

  Restaurante copyWith({
    int? idRestaurante,
    int? idDestino,
    String? nombre,
    String? descripcion,
    String? direccion,
    String? whatsappContacto,
    String? imagenPath,
  }) {
    return Restaurante(
      idRestaurante: idRestaurante ?? this.idRestaurante,
      idDestino: idDestino ?? this.idDestino,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      direccion: direccion ?? this.direccion,
      whatsappContacto: whatsappContacto ?? this.whatsappContacto,
      imagenPath: imagenPath ?? this.imagenPath,
    );
  }
} 
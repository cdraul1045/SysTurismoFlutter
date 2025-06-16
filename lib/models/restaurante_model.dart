class Restaurante {
  final int? idRestaurante;
  final String nombre;
  final String? descripcion;
  final String? direccion;
  final String? whatsappContacto;
  final int? idDestino;
  final String? imagenPath;

  Restaurante({
    this.idRestaurante,
    required this.nombre,
    this.descripcion,
    this.direccion,
    this.whatsappContacto,
    this.idDestino,
    this.imagenPath,
  });

  factory Restaurante.fromJson(Map<String, dynamic> json) {
    return Restaurante(
      idRestaurante: json['id_restaurante'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      direccion: json['direccion'],
      whatsappContacto: json['whatsapp_contacto'],
      idDestino: json['id_destino'],
      imagenPath: json['imagen_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_restaurante': idRestaurante,
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'whatsapp_contacto': whatsappContacto,
      'id_destino': idDestino,
      'imagen_path': imagenPath,
    };
  }

  Restaurante copyWith({
    int? idRestaurante,
    String? nombre,
    String? descripcion,
    String? direccion,
    String? whatsappContacto,
    int? idDestino,
    String? imagenPath,
  }) {
    return Restaurante(
      idRestaurante: idRestaurante ?? this.idRestaurante,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      direccion: direccion ?? this.direccion,
      whatsappContacto: whatsappContacto ?? this.whatsappContacto,
      idDestino: idDestino ?? this.idDestino,
      imagenPath: imagenPath ?? this.imagenPath,
    );
  }
} 
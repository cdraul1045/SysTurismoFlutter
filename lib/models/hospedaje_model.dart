class Hospedaje {
  final int? idHospedaje;
  final String? nombre;
  final int? idDestino;
  final String? descripcion;
  final double? precioPorNoche;
  final String? whatsappContacto;
  final String? direccion;

  Hospedaje({
    this.idHospedaje,
    this.nombre,
    this.idDestino,
    this.descripcion,
    this.precioPorNoche,
    this.whatsappContacto,
    this.direccion,
  });

  factory Hospedaje.fromJson(Map<String, dynamic> json) {
    return Hospedaje(
      idHospedaje: json['idHospedaje'],
      nombre: json['nombre'],
      idDestino: json['idDestino'],
      descripcion: json['descripcion'],
      precioPorNoche: json['precioPorNoche']?.toDouble(),
      whatsappContacto: json['whatsappContacto'],
      direccion: json['direccion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idHospedaje': idHospedaje,
      'nombre': nombre,
      'idDestino': idDestino,
      'descripcion': descripcion,
      'precioPorNoche': precioPorNoche,
      'whatsappContacto': whatsappContacto,
      'direccion': direccion,
    };
  }

  Hospedaje copyWith({
    int? idHospedaje,
    String? nombre,
    int? idDestino,
    String? descripcion,
    double? precioPorNoche,
    String? whatsappContacto,
    String? direccion,
  }) {
    return Hospedaje(
      idHospedaje: idHospedaje ?? this.idHospedaje,
      nombre: nombre ?? this.nombre,
      idDestino: idDestino ?? this.idDestino,
      descripcion: descripcion ?? this.descripcion,
      precioPorNoche: precioPorNoche ?? this.precioPorNoche,
      whatsappContacto: whatsappContacto ?? this.whatsappContacto,
      direccion: direccion ?? this.direccion,
    );
  }
} 
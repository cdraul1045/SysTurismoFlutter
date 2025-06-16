import 'dart:convert';

class Destino {
  final int? idDestino;
  final String? nombre;
  final String? descripcion;
  final String? ubicacion;
  final String? imagenPath;

  Destino({
    this.idDestino,
    this.nombre,
    this.descripcion,
    this.ubicacion,
    this.imagenPath,
  });

  factory Destino.fromJson(Map<String, dynamic> json) {
    return Destino(
      idDestino: json['idDestino'] as int?,
      nombre: json['nombre'] as String?,
      descripcion: json['descripcion'] as String?,
      ubicacion: json['ubicacion'] as String?,
      imagenPath: json['imagenPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idDestino': idDestino,
      'nombre': nombre,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'imagenPath': imagenPath,
    };
  }

  // Constructor para crear un destino por defecto
  factory Destino.defaultDestino() {
    return Destino(
      idDestino: 0,
      nombre: 'Sin destino',
      descripcion: 'Sin descripción',
      ubicacion: 'Sin ubicación',
    );
  }

  @override
  String toString() {
    return 'Destino(idDestino: $idDestino, nombre: $nombre, ubicacion: $ubicacion)';
  }
} 
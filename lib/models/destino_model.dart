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
    print('Procesando JSON del destino: $json');
    
    int? parseId(dynamic value) {
      if (value == null) return null;
      print('Tipo de valor para ID: ${value.runtimeType}');
      
      if (value is int) {
        print('ID es int: $value');
        return value;
      }
      
      if (value is String) {
        try {
          final id = int.parse(value);
          print('ID parseado de String: $id');
          return id;
        } catch (e) {
          print('Error al parsear ID de String: $e');
          return null;
        }
      }
      
      if (value is double) {
        final id = value.toInt();
        print('ID convertido de double: $id');
        return id;
      }
      
      print('Tipo de ID no reconocido: ${value.runtimeType}');
      return null;
    }

    final id = parseId(json['idDestino']);
    print('ID final parseado: $id');

    return Destino(
      idDestino: id,
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      ubicacion: json['ubicacion'],
      imagenPath: json['imagenPath'],
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

  @override
  String toString() {
    return 'Destino(idDestino: $idDestino, nombre: $nombre, ubicacion: $ubicacion)';
  }
} 
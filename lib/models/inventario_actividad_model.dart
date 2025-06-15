class InventarioActividad {
  final int idInventarioActividad;
  final int? idActividad;
  final String? nombreActividad;
  final DateTime? fechaSesion;
  final String? horaInicio;
  final String? horaFin;
  final int? capacidadPersonas;
  final int? personasRegistradas;
  final int? cantidadDisponible;
  final double? precioPorPersona;
  final String? descripcion;

  InventarioActividad({
    required this.idInventarioActividad,
    this.idActividad,
    this.nombreActividad,
    this.fechaSesion,
    this.horaInicio,
    this.horaFin,
    this.capacidadPersonas,
    this.personasRegistradas,
    this.cantidadDisponible,
    this.precioPorPersona,
    this.descripcion,
  });

  factory InventarioActividad.fromJson(Map<String, dynamic> json) {
    return InventarioActividad(
      idInventarioActividad: json['idInventarioActividad'] as int,
      idActividad: json['idActividad'] as int?,
      nombreActividad: json['nombreActividad'] as String?,
      fechaSesion: json['fechaSesion'] != null ? DateTime.parse(json['fechaSesion'] as String) : null,
      horaInicio: json['horaInicio'] as String?,
      horaFin: json['horaFin'] as String?,
      capacidadPersonas: json['capacidadPersonas'] as int?,
      personasRegistradas: json['personasRegistradas'] as int?,
      cantidadDisponible: json['cantidadDisponible'] as int?,
      precioPorPersona: (json['precioPorPersona'] as num?)?.toDouble(),
      descripcion: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idInventarioActividad': idInventarioActividad,
      'idActividad': idActividad,
      'nombreActividad': nombreActividad,
      'fechaSesion': fechaSesion?.toIso8601String().split('T')[0],
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'capacidadPersonas': capacidadPersonas,
      'personasRegistradas': personasRegistradas ?? 0,
      'cantidadDisponible': cantidadDisponible,
      'precioPorPersona': precioPorPersona,
      'descripcion': descripcion,
    };
  }

  InventarioActividad copyWith({
    int? idInventarioActividad,
    int? idActividad,
    String? nombreActividad,
    DateTime? fechaSesion,
    String? horaInicio,
    String? horaFin,
    int? capacidadPersonas,
    int? personasRegistradas,
    int? cantidadDisponible,
    double? precioPorPersona,
    String? descripcion,
  }) {
    return InventarioActividad(
      idInventarioActividad: idInventarioActividad ?? this.idInventarioActividad,
      idActividad: idActividad ?? this.idActividad,
      nombreActividad: nombreActividad ?? this.nombreActividad,
      fechaSesion: fechaSesion ?? this.fechaSesion,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      capacidadPersonas: capacidadPersonas ?? this.capacidadPersonas,
      personasRegistradas: personasRegistradas ?? this.personasRegistradas,
      cantidadDisponible: cantidadDisponible ?? this.cantidadDisponible,
      precioPorPersona: precioPorPersona ?? this.precioPorPersona,
      descripcion: descripcion ?? this.descripcion,
    );
  }
} 
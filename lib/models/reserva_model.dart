class Reserva {
  final int? idReserva;
  final int? idCliente;
  final String? tipoReserva;
  final String? estadoReserva;
  final double? totalPago;
  final String? observaciones;
  final DateTime? fechaFin;
  final DateTime? fechaInicio;
  final int? numeroPersonas;
  final int? idPaquete;
  final DateTime? fechaReserva;
  final String? nombreCliente; // Campo simulado para mostrar el nombre del cliente

  Reserva({
    this.idReserva,
    this.idCliente,
    this.tipoReserva,
    this.estadoReserva,
    this.totalPago,
    this.observaciones,
    this.fechaFin,
    this.fechaInicio,
    this.numeroPersonas,
    this.idPaquete,
    this.fechaReserva,
    this.nombreCliente,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      idReserva: json['id_reserva'],
      idCliente: json['id_cliente'],
      tipoReserva: json['tipo_reserva'],
      estadoReserva: json['estado_reserva'],
      totalPago: json['total_pago']?.toDouble(),
      observaciones: json['observaciones'],
      fechaFin: json['fecha_fin'] != null ? DateTime.parse(json['fecha_fin']) : null,
      fechaInicio: json['fecha_inicio'] != null ? DateTime.parse(json['fecha_inicio']) : null,
      numeroPersonas: json['numero_personas'],
      idPaquete: json['id_paquete'],
      fechaReserva: json['fecha_reserva'] != null ? DateTime.parse(json['fecha_reserva']) : null,
      nombreCliente: json['nombre_cliente'], // Campo simulado
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_reserva': idReserva,
      'id_cliente': idCliente,
      'tipo_reserva': tipoReserva,
      'estado_reserva': estadoReserva,
      'total_pago': totalPago,
      'observaciones': observaciones,
      'fecha_fin': fechaFin?.toIso8601String(),
      'fecha_inicio': fechaInicio?.toIso8601String(),
      'numero_personas': numeroPersonas,
      'id_paquete': idPaquete,
      'fecha_reserva': fechaReserva?.toIso8601String(),
      'nombre_cliente': nombreCliente, // Campo simulado
    };
  }

  Reserva copyWith({
    int? idReserva,
    int? idCliente,
    String? tipoReserva,
    String? estadoReserva,
    double? totalPago,
    String? observaciones,
    DateTime? fechaFin,
    DateTime? fechaInicio,
    int? numeroPersonas,
    int? idPaquete,
    DateTime? fechaReserva,
    String? nombreCliente,
  }) {
    return Reserva(
      idReserva: idReserva ?? this.idReserva,
      idCliente: idCliente ?? this.idCliente,
      tipoReserva: tipoReserva ?? this.tipoReserva,
      estadoReserva: estadoReserva ?? this.estadoReserva,
      totalPago: totalPago ?? this.totalPago,
      observaciones: observaciones ?? this.observaciones,
      fechaFin: fechaFin ?? this.fechaFin,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      numeroPersonas: numeroPersonas ?? this.numeroPersonas,
      idPaquete: idPaquete ?? this.idPaquete,
      fechaReserva: fechaReserva ?? this.fechaReserva,
      nombreCliente: nombreCliente ?? this.nombreCliente,
    );
  }
} 
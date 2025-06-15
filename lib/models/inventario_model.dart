class Inventario {
  final int? idInventario;
  final String? nombreItem;
  final int? cantidadDisponible;
  final int? idDestino;

  Inventario({
    this.idInventario,
    this.nombreItem,
    this.cantidadDisponible,
    this.idDestino,
  });

  factory Inventario.fromJson(Map<String, dynamic> json) {
    return Inventario(
      idInventario: json['idInventario'],
      nombreItem: json['nombreItem'],
      cantidadDisponible: json['cantidadDisponible'],
      idDestino: json['idDestino'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idInventario': idInventario,
      'nombreItem': nombreItem,
      'cantidadDisponible': cantidadDisponible,
      'idDestino': idDestino,
    };
  }

  Inventario copyWith({
    int? idInventario,
    String? nombreItem,
    int? cantidadDisponible,
    int? idDestino,
  }) {
    return Inventario(
      idInventario: idInventario ?? this.idInventario,
      nombreItem: nombreItem ?? this.nombreItem,
      cantidadDisponible: cantidadDisponible ?? this.cantidadDisponible,
      idDestino: idDestino ?? this.idDestino,
    );
  }
} 
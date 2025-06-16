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
      idInventario: json['id_inventario'],
      nombreItem: json['nombre_item'],
      cantidadDisponible: json['cantidad_disponible'],
      idDestino: json['id_destino'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_inventario': idInventario,
      'nombre_item': nombreItem,
      'cantidad_disponible': cantidadDisponible,
      'id_destino': idDestino,
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
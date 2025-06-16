import 'package:flutter/material.dart';
import '../screens/inventario_screen.dart';
import '../screens/hospedaje_screen.dart';

class AppRoutes {
  static const String inventario = '/inventario';
  static const String hospedajes = '/hospedajes';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      inventario: (context) => const InventarioScreen(),
      hospedajes: (context) => const HospedajeScreen(),
    };
  }
} 
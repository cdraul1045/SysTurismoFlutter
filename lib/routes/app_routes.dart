import 'package:flutter/material.dart';
import '../screens/inventario_screen.dart';

class AppRoutes {
  static const String inventario = '/inventario';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      inventario: (context) => const InventarioScreen(),
    };
  }
} 
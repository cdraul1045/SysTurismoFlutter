import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/admin_screen.dart';
import '../screens/destinos_screen.dart';
import '../screens/hospedaje_screen.dart';
import '../screens/actividad_screen.dart';
import '../screens/restaurante_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String admin = '/admin';
  static const String destinos = '/destinos';
  static const String hospedajes = '/hospedajes';
  static const String actividades = '/actividades';
  static const String restaurantes = '/restaurantes';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      admin: (context) => const AdminScreen(),
      destinos: (context) => const DestinosScreen(),
      hospedajes: (context) => const HospedajeScreen(),
      actividades: (context) => const ActividadScreen(),
      restaurantes: (context) => const RestauranteScreen(),
    };
  }
} 
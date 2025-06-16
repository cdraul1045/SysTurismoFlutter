import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/admin_screen.dart';
import '../screens/home_screen.dart';
import '../screens/cliente_profile_screen.dart';
import '../screens/clientes_screen.dart';
import '../screens/destinos_screen.dart';
import '../screens/hospedaje_screen.dart';
import '../screens/actividad_screen.dart';
import '../screens/restaurante_screen.dart';
import '../screens/paquete_turistico_screen.dart';
import '../screens/reservas_screen.dart';
import '../screens/inventario_screen.dart';
import '../screens/inventario_actividad_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String admin = '/admin';
  static const String home = '/home';
  static const String clienteProfile = '/cliente-profile';
  static const String clientes = '/clientes';
  static const String destinos = '/destinos';
  static const String hospedajes = '/hospedajes';
  static const String actividades = '/actividades';
  static const String restaurantes = '/restaurantes';
  static const String paquetes = '/paquetes';
  static const String reservas = '/reservas';
  static const String inventario = '/inventario';
  static const String inventarioActividad = '/inventario-actividad';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      admin: (context) => const AdminScreen(),
      home: (context) => const HomeScreen(),
      clienteProfile: (context) => ClienteProfileScreen(
        correo: ModalRoute.of(context)!.settings.arguments as String,
      ),
      clientes: (context) => const ClientesScreen(),
      destinos: (context) => const DestinosScreen(),
      hospedajes: (context) => const HospedajeScreen(),
      actividades: (context) => const ActividadScreen(),
      restaurantes: (context) => const RestauranteScreen(),
      paquetes: (context) => const PaqueteTuristicoScreen(),
      reservas: (context) => const ReservasScreen(),
      inventario: (context) => const InventarioScreen(),
      inventarioActividad: (context) => const InventarioActividadScreen(),
    };
  }
} 
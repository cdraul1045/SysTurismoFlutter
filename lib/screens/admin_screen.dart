import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_routes.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  void _cerrarSesion(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  Widget _buildMenuOption(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SysTurismo-Administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildMenuOption(
            context,
            'Gestión de Destinos',
            Icons.place,
            AppRoutes.destinos,
          ),
          _buildMenuOption(
            context,
            'Gestión de Hospedajes',
            Icons.hotel,
            AppRoutes.hospedajes,
          ),
          _buildMenuOption(
            context,
            'Gestión de Restaurantes',
            Icons.restaurant,
            AppRoutes.restaurantes,
          ),
          _buildMenuOption(
            context,
            'Gestión de Actividades',
            Icons.directions_run,
            AppRoutes.actividades,
          ),
          _buildMenuOption(
            context,
            'Gestión de Paquetes Turísticos',
            Icons.card_travel,
            AppRoutes.paquetes,
          ),
          _buildMenuOption(
            context,
            'Gestión de Clientes',
            Icons.people,
            AppRoutes.clientes,
          ),
          _buildMenuOption(
            context,
            'Inventario',
            Icons.inventory,
            AppRoutes.inventario,
          ),
          _buildMenuOption(
            context,
            'Inventario Actividades',
            Icons.event_note,
            AppRoutes.inventarioActividad,
          ),
          _buildMenuOption(
            context,
            'Reservas',
            Icons.calendar_today,
            AppRoutes.reservas,
          ),
        ],
      ),
    );
  }
} 
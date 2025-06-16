import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_routes.dart';
import 'hospedaje_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  Future<void> _cerrarSesion(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildMenuOption(BuildContext context, String title, IconData icon, String route) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SysTurismo - Administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildMenuOption(context, 'Gestión de Destinos', Icons.place, AppRoutes.destinos),
          _buildMenuOption(context, 'Gestión de Hospedajes', Icons.hotel, AppRoutes.hospedajes),
          _buildMenuOption(context, 'Gestión de Actividades', Icons.directions_run, AppRoutes.actividades),
        ],
      ),
    );
  }
} 
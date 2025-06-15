import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SysTurismo - Administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildMenuCard(
            context,
            'Hospedajes',
            Icons.hotel,
            () => Navigator.pushNamed(context, '/hospedajes'),
          ),
          _buildMenuCard(
            context,
            'Restaurantes',
            Icons.restaurant,
            () => Navigator.pushNamed(context, '/restaurantes'),
          ),
          _buildMenuCard(
            context,
            'Actividades',
            Icons.directions_bike,
            () => Navigator.pushNamed(context, '/actividades'),
          ),
          _buildMenuCard(
            context,
            'Reservas',
            Icons.calendar_today,
            () => Navigator.pushNamed(context, '/reservas'),
          ),
          _buildMenuCard(
            context,
            'Clientes',
            Icons.people,
            () => Navigator.pushNamed(context, '/clientes'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
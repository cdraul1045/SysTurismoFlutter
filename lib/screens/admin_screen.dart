import 'package:flutter/material.dart';
import 'hospedaje_screen.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administración'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.hotel),
            title: const Text('Gestión de Hospedaje'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HospedajeScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
} 
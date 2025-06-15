import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inventario_model.dart';

class InventarioService {
  final String baseUrl = 'http://192.168.0.105:8081/api/inventario';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Token obtenido: $token'); // Para depuración
    
    if (token == null) {
      throw Exception('No hay token de autenticación. Por favor, inicie sesión.');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Inventario>> listarInventario() async {
    try {
      final headers = await _getHeaders();
      print('Headers enviados: $headers'); // Para depuración

      final response = await http.get(
        Uri.parse('$baseUrl/listar'),
        headers: headers,
      );

      print('Código de respuesta: ${response.statusCode}'); // Para depuración
      print('Respuesta del servidor: ${response.body}'); // Para depuración

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => Inventario.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        // Intentar refrescar el token o redirigir al login
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('Sesión expirada. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al cargar el inventario: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('No hay token')) {
        throw Exception('Por favor, inicie sesión para acceder al inventario.');
      }
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Inventario> guardarInventario(Inventario inventario) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/guardar'),
        headers: headers,
        body: json.encode(inventario.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Inventario.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('Sesión expirada. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al guardar el inventario: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('No hay token')) {
        throw Exception('Por favor, inicie sesión para guardar el inventario.');
      }
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Inventario> editarInventario(Inventario inventario) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/editar'),
        headers: headers,
        body: json.encode(inventario.toJson()),
      );

      if (response.statusCode == 200) {
        return Inventario.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('Sesión expirada. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al editar el inventario: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('No hay token')) {
        throw Exception('Por favor, inicie sesión para editar el inventario.');
      }
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> eliminarInventario(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/eliminar/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('token');
          throw Exception('Sesión expirada. Por favor, inicie sesión nuevamente.');
        } else {
          throw Exception('Error al eliminar el inventario: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      if (e.toString().contains('No hay token')) {
        throw Exception('Por favor, inicie sesión para eliminar el inventario.');
      }
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Inventario> buscarInventario(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/buscar/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Inventario.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('Sesión expirada. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al buscar el inventario: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('No hay token')) {
        throw Exception('Por favor, inicie sesión para buscar el inventario.');
      }
      throw Exception('Error de conexión: $e');
    }
  }
} 
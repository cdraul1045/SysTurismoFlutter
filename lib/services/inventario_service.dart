import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inventario_model.dart';

class InventarioService {
  final String baseUrl = 'http://10.0.2.2:8081/api/inventario';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Inventario>> listarInventario() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Inventario.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar el inventario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Inventario> guardarInventario(Inventario inventario) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(inventario.toJson()),
      );

      if (response.statusCode == 201) {
        return Inventario.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al guardar el inventario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Inventario> actualizarInventario(Inventario inventario) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/${inventario.idInventario}'),
        headers: headers,
        body: json.encode(inventario.toJson()),
      );

      if (response.statusCode == 200) {
        return Inventario.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al actualizar el inventario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> eliminarInventario(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar el inventario: ${response.statusCode}');
      }
    } catch (e) {
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
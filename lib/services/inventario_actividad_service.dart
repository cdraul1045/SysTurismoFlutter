import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inventario_actividad_model.dart';

class InventarioActividadService {
  final String baseUrl = 'http://192.168.0.105:8081/api/inventarioactividad';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<InventarioActividad>> listarInventarioActividad() async {
    try {
      final headers = await _getHeaders();
      print('Headers enviados: $headers');

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      print('Código de respuesta: ${response.statusCode}');
      print('Respuesta del servidor: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => InventarioActividad.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al cargar el inventario de actividades: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<InventarioActividad> obtenerInventarioActividad(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return InventarioActividad.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al obtener el inventario de actividad: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<InventarioActividad> guardarInventarioActividad(InventarioActividad inventarioActividad) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode(inventarioActividad.toJson());
      print('Enviando datos: $body');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: body,
      );

      print('Código de respuesta: ${response.statusCode}');
      print('Respuesta del servidor: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return InventarioActividad.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al guardar el inventario de actividad: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<InventarioActividad> editarInventarioActividad(InventarioActividad inventarioActividad) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode(inventarioActividad.toJson());
      print('Enviando datos: $body');

      final response = await http.put(
        Uri.parse('$baseUrl/${inventarioActividad.idInventarioActividad}'),
        headers: headers,
        body: body,
      );

      print('Código de respuesta: ${response.statusCode}');
      print('Respuesta del servidor: ${response.body}');

      if (response.statusCode == 200) {
        return InventarioActividad.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al actualizar el inventario de actividad: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> eliminarInventarioActividad(int id) async {
    try {
      final headers = await _getHeaders();
      print('Eliminando actividad con ID: $id');

      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      print('Código de respuesta: ${response.statusCode}');
      print('Respuesta del servidor: ${response.body}');

      if (response.statusCode == 204 || response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
      } else if (response.statusCode == 500) {
        final responseBody = json.decode(response.body);
        if (responseBody['message']?.toString().contains('foreign key constraint fails') ?? false) {
          throw Exception('No se puede eliminar esta actividad porque tiene reservas asociadas. Por favor, elimine primero las reservas.');
        }
        throw Exception('Error al eliminar el inventario de actividad: ${response.statusCode} - ${response.body}');
      } else {
        throw Exception('Error al eliminar el inventario de actividad: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
} 
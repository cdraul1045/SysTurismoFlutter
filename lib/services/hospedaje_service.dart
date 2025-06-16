import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hospedaje_model.dart';

class HospedajeService {
  final String baseUrl = 'http://192.168.0.105:8081/api/hospedaje';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Token obtenido: $token'); // Debug

    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Hospedaje>> listarHospedajes() async {
    try {
      final headers = await _getHeaders();
      print('Headers enviados: $headers'); // Debug

      final response = await http.get(
        Uri.parse('$baseUrl/listar'),
        headers: headers,
      );

      print('Código de estado: ${response.statusCode}'); // Debug
      print('Respuesta del servidor: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Hospedaje.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('Sesión expirada. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al obtener la lista de hospedajes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en listarHospedajes: $e'); // Debug
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Hospedaje> guardarHospedaje(Hospedaje hospedaje) async {
    try {
      final headers = await _getHeaders();
      print('Headers enviados: $headers'); // Debug
      print('Datos a enviar: ${hospedaje.toJson()}'); // Debug

      final response = await http.post(
        Uri.parse('$baseUrl/guardar'),
        headers: headers,
        body: json.encode(hospedaje.toJson()),
      );

      print('Código de estado: ${response.statusCode}'); // Debug
      print('Respuesta del servidor: ${response.body}'); // Debug

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Hospedaje.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('Sesión expirada. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al guardar el hospedaje: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en guardarHospedaje: $e'); // Debug
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Hospedaje> editarHospedaje(Hospedaje hospedaje) async {
    try {
      final headers = await _getHeaders();
      print('Headers enviados: $headers'); // Debug
      print('Datos a enviar: ${hospedaje.toJson()}'); // Debug

      final response = await http.put(
        Uri.parse('$baseUrl/editar'),
        headers: headers,
        body: json.encode(hospedaje.toJson()),
      );

      print('Código de estado: ${response.statusCode}'); // Debug
      print('Respuesta del servidor: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        return Hospedaje.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('Sesión expirada. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al editar el hospedaje: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en editarHospedaje: $e'); // Debug
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> eliminarHospedaje(int idHospedaje) async {
    try {
      final headers = await _getHeaders();
      print('Headers enviados: $headers'); // Debug

      final response = await http.delete(
        Uri.parse('$baseUrl/eliminar/$idHospedaje'),
        headers: headers,
      );

      print('Código de estado: ${response.statusCode}'); // Debug
      print('Respuesta del servidor: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('Sesión expirada. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al eliminar el hospedaje: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en eliminarHospedaje: $e'); // Debug
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Hospedaje> buscarHospedaje(int id) async {
    try {
      final headers = await _getHeaders();
      print('Headers enviados: $headers'); // Debug

      final response = await http.get(
        Uri.parse('$baseUrl/buscar/$id'),
        headers: headers,
      );

      print('Código de estado: ${response.statusCode}'); // Debug
      print('Respuesta del servidor: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        return Hospedaje.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('Sesión expirada. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al buscar el hospedaje: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en buscarHospedaje: $e'); // Debug
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Hospedaje> actualizarHospedaje(Hospedaje hospedaje) async {
    try {
      final headers = await _getHeaders();
      print('Headers enviados: $headers'); // Debug
      print('Datos a enviar: ${hospedaje.toJson()}'); // Debug

      final response = await http.put(
        Uri.parse('$baseUrl/editar'),
        headers: headers,
        body: json.encode(hospedaje.toJson()),
      );

      print('Código de estado: ${response.statusCode}'); // Debug
      print('Respuesta del servidor: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Hospedaje.fromJson(data);
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('Sesión expirada. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al actualizar el hospedaje: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en actualizarHospedaje: $e'); // Debug
      throw Exception('Error de conexión: $e');
    }
  }
} 
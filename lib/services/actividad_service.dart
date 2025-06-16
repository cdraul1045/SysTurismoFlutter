import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/actividad_model.dart';

class ActividadService {
  final String baseUrl = 'http://192.168.0.105:8081/api/actividad';

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

  Future<List<Actividad>> listarActividades() async {
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
        return data.map((json) => Actividad.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('Sesión expirada. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al obtener la lista de actividades: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en listarActividades: $e'); // Debug
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Actividad> guardarActividad(Actividad actividad) async {
    try {
      final headers = await _getHeaders();
      print('Headers enviados: $headers'); // Debug
      print('Datos a enviar: ${actividad.toJson()}'); // Debug

      final response = await http.post(
        Uri.parse('$baseUrl/guardar'),
        headers: headers,
        body: json.encode(actividad.toJson()),
      );

      print('Código de estado: ${response.statusCode}'); // Debug
      print('Respuesta del servidor: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Actividad.fromJson(data);
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('Sesión expirada. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al guardar la actividad: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en guardarActividad: $e'); // Debug
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Actividad> actualizarActividad(Actividad actividad) async {
    try {
      final headers = await _getHeaders();
      print('Headers enviados: $headers'); // Debug
      print('Datos a enviar: ${actividad.toJson()}'); // Debug

      final response = await http.put(
        Uri.parse('$baseUrl/editar'),
        headers: headers,
        body: json.encode(actividad.toJson()),
      );

      print('Código de estado: ${response.statusCode}'); // Debug
      print('Respuesta del servidor: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Actividad.fromJson(data);
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('Sesión expirada. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al actualizar la actividad: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en actualizarActividad: $e'); // Debug
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> eliminarActividad(int idActividad) async {
    try {
      final headers = await _getHeaders();
      print('Headers enviados: $headers'); // Debug

      final response = await http.delete(
        Uri.parse('$baseUrl/eliminar/$idActividad'),
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
        throw Exception('Error al eliminar la actividad: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en eliminarActividad: $e'); // Debug
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Actividad> guardarActividadConImagen(Actividad actividad, File imagen) async {
    try {
      final headers = await _getHeaders();
      print('Headers enviados: $headers'); // Debug

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/guardar-con-imagen'),
      );

      request.fields['idDestino'] = actividad.idDestino.toString();
      request.fields['nombre'] = actividad.nombre ?? '';
      request.fields['descripcion'] = actividad.descripcion ?? '';
      request.fields['nivelRiesgo'] = actividad.nivelRiesgo ?? '';
      request.fields['whatsappContacto'] = actividad.whatsappContacto ?? '';
      request.fields['precio'] = actividad.precio?.toString() ?? '0';

      request.files.add(
        await http.MultipartFile.fromPath('imagen', imagen.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('Respuesta del servidor: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Actividad.fromJson(data);
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('Sesión expirada. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al guardar la actividad con imagen: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en guardarActividadConImagen: $e'); // Debug
      throw Exception('Error de conexión: $e');
    }
  }
} 
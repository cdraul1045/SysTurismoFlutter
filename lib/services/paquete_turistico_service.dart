import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/paquete_turistico_model.dart';

class PaqueteTuristicoService {
  final String baseUrl = 'http://192.168.0.105:8081/api/paquete';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<PaqueteTuristico>> listarPaquetes() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/listar'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PaqueteTuristico.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar los paquetes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<PaqueteTuristico> guardarPaquete(PaqueteTuristico paquete) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/guardar'),
        headers: headers,
        body: json.encode(paquete.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaqueteTuristico.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al guardar el paquete: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<PaqueteTuristico> actualizarPaquete(PaqueteTuristico paquete) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/editar'),
        headers: headers,
        body: json.encode(paquete.toJson()),
      );

      if (response.statusCode == 200) {
        return PaqueteTuristico.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al actualizar el paquete: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<void> eliminarPaquete(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/eliminar/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar el paquete: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<PaqueteTuristico> guardarPaqueteConImagen({
    required String nombre,
    required String descripcion,
    required int duracionDias,
    required String whatsappContacto,
    required double precio,
    required int idDestino,
    required File imagen,
  }) async {
    try {
      final headers = await _getHeaders();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/guardar-con-imagen'),
      );

      request.headers.addAll(headers);
      request.fields['nombre'] = nombre;
      request.fields['descripcion'] = descripcion;
      request.fields['duracionDias'] = duracionDias.toString();
      request.fields['whatsappContacto'] = whatsappContacto;
      request.fields['precio'] = precio.toString();
      request.fields['idDestino'] = idDestino.toString();
      request.files.add(await http.MultipartFile.fromPath('imagen', imagen.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaqueteTuristico.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al guardar el paquete con imagen: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }
} 
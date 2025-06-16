import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/restaurante_model.dart';

class RestauranteService {
  final String baseUrl = 'http://192.168.0.105:8081/api/restaurante';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Restaurante>> listarRestaurantes() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/listar'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Restaurante.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar los restaurantes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<Restaurante> guardarRestaurante(Restaurante restaurante) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/guardar'),
        headers: headers,
        body: json.encode(restaurante.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Restaurante.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al guardar el restaurante: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<Restaurante> actualizarRestaurante(Restaurante restaurante) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/editar'),
        headers: headers,
        body: json.encode(restaurante.toJson()),
      );

      if (response.statusCode == 200) {
        return Restaurante.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al actualizar el restaurante: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<void> eliminarRestaurante(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/eliminar/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar el restaurante: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<Restaurante> guardarRestauranteConImagen({
    required String nombre,
    required String descripcion,
    required String direccion,
    required String whatsappContacto,
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
      request.fields['direccion'] = direccion;
      request.fields['whatsapp_contacto'] = whatsappContacto;
      request.fields['id_destino'] = idDestino.toString();
      request.files.add(await http.MultipartFile.fromPath('imagen', imagen.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Restaurante.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al guardar el restaurante con imagen: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }
} 
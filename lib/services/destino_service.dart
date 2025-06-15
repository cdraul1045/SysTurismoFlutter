import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/destino_model.dart';
import 'http_service.dart';

class DestinoService {
  final String baseUrl = 'http://192.168.0.105:8081/api/destino';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('No hay token de autenticación. Por favor, inicie sesión.');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Destino>> listarDestinos() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/listar'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => Destino.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('Sesión expirada. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al cargar los destinos: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Destino> obtenerDestino(int id) async {
    try {
      print('Obteniendo destino con ID: $id');
      final response = await HttpService.get('/api/destino/buscar/$id');
      print('Respuesta de obtener destino: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final destino = Destino.fromJson(data);
        print('Destino obtenido: ${destino.toString()}');
        return destino;
      } else {
        throw Exception('Error al obtener el destino: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerDestino: $e');
      throw Exception('Error de conexion: $e');
    }
  }

  Future<Destino> guardarDestino(Destino destino) async {
    try {
      print('Guardando destino: ${destino.toString()}');
      final response = await HttpService.post(
        '/api/destino/guardar',
        destino.toJson(),
      );
      print('Respuesta de guardar destino: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final destinoGuardado = Destino.fromJson(data);
        print('Destino guardado: ${destinoGuardado.toString()}');
        return destinoGuardado;
      } else {
        throw Exception('Error al guardar el destino: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en guardarDestino: $e');
      throw Exception('Error de conexion: $e');
    }
  }

  Future<Destino> actualizarDestino(Destino destino) async {
    try {
      if (destino.idDestino == null) {
        throw Exception('El ID del destino es requerido para actualizar');
      }
      
      print('Actualizando destino con ID: ${destino.idDestino}');
      print('Datos a actualizar: ${destino.toJson()}');
      
      final response = await HttpService.put(
        '/api/destino/editar',
        destino.toJson(),
      );
      print('Respuesta de actualizar destino: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final destinoActualizado = Destino.fromJson(data);
        print('Destino actualizado: ${destinoActualizado.toString()}');
        return destinoActualizado;
      } else {
        throw Exception('Error al actualizar el destino: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en actualizarDestino: $e');
      throw Exception('Error de conexion: $e');
    }
  }

  Future<void> eliminarDestino(int id) async {
    try {
      print('Eliminando destino con ID: $id');
      final response = await HttpService.delete('/api/destino/eliminar/$id');
      print('Respuesta de eliminar destino: ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('Error al eliminar el destino: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en eliminarDestino: $e');
      throw Exception('Error de conexion: $e');
    }
  }

  Future<Destino> guardarDestinoConImagen(Destino destino, File imagen) async {
    try {
      print('Guardando destino con imagen: ${destino.toString()}');
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/guardar-con-imagen'),
      );

      request.fields['nombre'] = destino.nombre ?? '';
      request.fields['descripcion'] = destino.descripcion ?? '';
      request.fields['ubicacion'] = destino.ubicacion ?? '';

      request.files.add(
        await http.MultipartFile.fromPath('imagen', imagen.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('Respuesta de guardar destino con imagen: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final destinoGuardado = Destino.fromJson(data);
        print('Destino con imagen guardado: ${destinoGuardado.toString()}');
        return destinoGuardado;
      } else {
        throw Exception('Error al guardar el destino con imagen: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en guardarDestinoConImagen: $e');
      throw Exception('Error de conexion: $e');
    }
  }

  Future<Destino> actualizarDestinoConImagen(Destino destino, File imagen) async {
    try {
      if (destino.idDestino == null) {
        throw Exception('El ID del destino es requerido para actualizar');
      }

      print('Actualizando destino con imagen. ID: ${destino.idDestino}');
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/guardar-con-imagen'),
      );

      request.fields['nombre'] = destino.nombre ?? '';
      request.fields['descripcion'] = destino.descripcion ?? '';
      request.fields['ubicacion'] = destino.ubicacion ?? '';

      request.files.add(
        await http.MultipartFile.fromPath('imagen', imagen.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('Respuesta de actualizar destino con imagen: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final destinoActualizado = Destino.fromJson(data);
        print('Destino con imagen actualizado: ${destinoActualizado.toString()}');
        return destinoActualizado;
      } else {
        throw Exception('Error al actualizar el destino con imagen: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en actualizarDestinoConImagen: $e');
      throw Exception('Error de conexion: $e');
    }
  }
} 
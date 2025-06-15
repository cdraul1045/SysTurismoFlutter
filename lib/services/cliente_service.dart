import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/cliente_model.dart';
import 'http_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClienteService {
  final String baseUrl = 'http://192.168.0.105:8081';

  Future<List<Cliente>> listarClientes() async {
    try {
      final response = await HttpService.get('/api/cliente/listar');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Cliente.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener los clientes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexion: $e');
    }
  }

  Future<Cliente> obtenerCliente(String correo) async {
    try {
      final response = await HttpService.get('/api/cliente/buscar/$correo');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Cliente.fromJson(data);
      } else {
        throw Exception('Error al obtener el cliente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexion: $e');
    }
  }

  Future<Cliente> guardarCliente(Cliente cliente) async {
    try {
      final response = await HttpService.post(
        '/api/cliente/guardar',
        cliente.toJson(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Cliente.fromJson(data);
      } else {
        throw Exception('Error al guardar el cliente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexion: $e');
    }
  }

  Future<Cliente> guardarClienteConImagen(Cliente cliente, File imagen) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/cliente/guardar-con-imagen'),
      );

      // Agregar campos del cliente
      request.fields['nombres'] = cliente.nombres ?? '';
      request.fields['apellidos'] = cliente.apellidos ?? '';
      request.fields['correo'] = cliente.correo ?? '';
      request.fields['password'] = cliente.password ?? '';
      request.fields['direccion'] = cliente.direccion ?? '';
      request.fields['whatsappContacto'] = cliente.whatsappContacto ?? '';
      request.fields['tipoDocumento'] = cliente.tipoDocumento ?? '';
      request.fields['numeroDocumento'] = cliente.numeroDocumento ?? '';

      // Agregar imagen
      request.files.add(
        await http.MultipartFile.fromPath('imagen', imagen.path),
      );

      // Agregar token de autorización
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Cliente.fromJson(data);
      } else {
        throw Exception('Error al guardar el cliente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexion: $e');
    }
  }

  Future<Cliente> actualizarCliente(Cliente cliente) async {
    try {
      final response = await HttpService.put(
        '/api/cliente/actualizar/${cliente.idCliente}',
        cliente.toJson(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Cliente.fromJson(data);
      } else {
        throw Exception('Error al actualizar el cliente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexion: $e');
    }
  }

  Future<Cliente> actualizarClienteConImagen(Cliente cliente, File imagen) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/api/cliente/actualizar-con-imagen/${cliente.idCliente}'),
      );

      // Agregar campos del cliente
      request.fields['nombres'] = cliente.nombres ?? '';
      request.fields['apellidos'] = cliente.apellidos ?? '';
      request.fields['correo'] = cliente.correo ?? '';
      request.fields['direccion'] = cliente.direccion ?? '';
      request.fields['whatsappContacto'] = cliente.whatsappContacto ?? '';
      request.fields['tipoDocumento'] = cliente.tipoDocumento ?? '';
      request.fields['numeroDocumento'] = cliente.numeroDocumento ?? '';

      // Agregar imagen
      request.files.add(
        await http.MultipartFile.fromPath('imagen', imagen.path),
      );

      // Agregar token de autorización
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Cliente.fromJson(data);
      } else {
        throw Exception('Error al actualizar el cliente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexion: $e');
    }
  }

  Future<void> eliminarCliente(int id) async {
    try {
      final response = await HttpService.delete('/api/cliente/eliminar/$id');
      
      if (response.statusCode != 200) {
        throw Exception('Error al eliminar el cliente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexion: $e');
    }
  }

  Future<Cliente> editarCliente(Cliente cliente) async {
    try {
      final response = await HttpService.put(
        '/api/cliente/editar',
        cliente.toJson(),
      );
      if (response.statusCode == 200) {
        return Cliente.fromJson(json.decode(response.body));
      }
      throw Exception('Error al editar el cliente');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Cliente> buscarCliente(int id) async {
    try {
      final response = await HttpService.get('/api/cliente/buscar/$id');
      if (response.statusCode == 200) {
        return Cliente.fromJson(json.decode(response.body));
      }
      throw Exception('Cliente no encontrado');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
} 
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/usuario_model.dart';
import 'http_service.dart';

class AuthService {
  // URL base para Spring Boot - típicamente usa /api como prefijo
  final String baseUrl = 'http://192.168.0.105:8081';

  // Método para probar la conexión al servidor Spring Boot
  Future<bool> testConnection() async {
    try {
      print('=== PROBANDO CONEXIÓN AL SERVIDOR SPRING BOOT ===');

      // Spring Boot suele tener un endpoint de health o actuator
      final List<String> testUrls = [
        '$baseUrl/actuator/health',  // Endpoint estándar de Spring Boot Actuator
        '$baseUrl/api/health',       // Endpoint personalizado común
        '$baseUrl/health',           // Endpoint simple
        '$baseUrl/',                 // Root endpoint
      ];

      for (String testUrl in testUrls) {
        try {
          print('Probando: $testUrl');

          final response = await http.get(
            Uri.parse(testUrl),
            headers: {
              'Accept': 'application/json',
            },
          ).timeout(const Duration(seconds: 5));

          print('Status Code: ${response.statusCode}');
          print('Respuesta: ${response.body}');

          if (response.statusCode == 200) {
            print('✅ Conexión exitosa con: $testUrl');
            return true;
          }
        } catch (e) {
          print('❌ Falló: $testUrl - $e');
          continue;
        }
      }

      // Si ningún endpoint específico funciona, probar conexión TCP básica
      print('Probando conexión TCP básica...');
      final socket = await Socket.connect('192.168.0.105', 8081)
          .timeout(const Duration(seconds: 5));
      await socket.close();
      print('✅ Conexión TCP exitosa - Servidor Spring Boot activo');
      return true;

    } catch (e) {
      print('❌ Error de conexión TCP: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> login(String correo, String password) async {
    try {
      print('=== INICIO DEL PROCESO DE LOGIN - SPRING BOOT ===');

      // Validaciones previas
      if (correo.trim().isEmpty) {
        throw Exception('El correo no puede estar vacío');
      }

      if (password.isEmpty) {
        throw Exception('La contraseña no puede estar vacía');
      }

      final correoNormalizado = correo.trim().toLowerCase();
      print('Correo normalizado: "$correoNormalizado"');

      final requestBody = {
        'correo': correoNormalizado,
        'contraseña': password,
      };

      print('Cuerpo de la petición: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey('token')) {
          return responseData;
        } else {
          throw Exception('El servidor no devolvió un token válido');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Credenciales incorrectas');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }

    } catch (e) {
      print('Error en login: $e');
      rethrow;
    }
  }

  Future<String> registrar(Usuario usuario) async {
    try {
      print('=== INICIANDO REGISTRO SPRING BOOT ===');

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/registrar'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(usuario.toJson()),
      ).timeout(const Duration(seconds: 30));

      print('Status Code registro: ${response.statusCode}');
      print('Respuesta registro: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? errorData['error'] ?? 'Error en el registro');
      }

    } catch (e) {
      print('Error en registro: $e');
      if (e.toString().contains('SocketException')) {
        throw Exception('No se pudo conectar con el servidor Spring Boot para el registro');
      }
      rethrow;
    }
  }
}
class Usuario {
  final int? idUsuario;
  final String correo;
  final String password;
  final String? rol;
  final String? token;

  Usuario({
    this.idUsuario,
    required this.correo,
    required this.password,
    this.rol,
    this.token,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['idUsuario'],
      correo: json['correo'],
      password: json['password'],
      rol: json['rol'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'correo': correo,
      'password': password,
      'rol': rol,
      'token': token,
    };
  }
} 
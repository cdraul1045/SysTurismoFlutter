class Cliente {
  final int? idCliente;
  final String? nombres;
  final String? apellidos;
  final String? correo;
  final String? password;
  final String? direccion;
  final String? whatsappContacto;
  final String? tipoDocumento;
  final String? numeroDocumento;
  final String? imagenPerfil;

  Cliente({
    this.idCliente,
    this.nombres,
    this.apellidos,
    this.correo,
    this.password,
    this.direccion,
    this.whatsappContacto,
    this.tipoDocumento,
    this.numeroDocumento,
    this.imagenPerfil,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: json['idCliente'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      correo: json['correo'],
      password: json['password'],
      direccion: json['direccion'],
      whatsappContacto: json['whatsappContacto'],
      tipoDocumento: json['tipoDocumento'],
      numeroDocumento: json['numeroDocumento'],
      imagenPerfil: json['imagenPerfil'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCliente': idCliente,
      'nombres': nombres,
      'apellidos': apellidos,
      'correo': correo,
      'password': password,
      'direccion': direccion,
      'whatsappContacto': whatsappContacto,
      'tipoDocumento': tipoDocumento,
      'numeroDocumento': numeroDocumento,
      'imagenPerfil': imagenPerfil,
    };
  }
} 
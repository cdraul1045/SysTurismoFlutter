class Cliente {
  final int? idCliente;
  final String? nombres;
  final String? apellidos;
  final String? numeroDocumento;
  final String? imagenPerfil;
  final String? whatsappContacto;
  final String? correo;
  final String? direccion;
  final String? tipoDocumento;
  final String? password;

  Cliente({
    this.idCliente,
    this.nombres,
    this.apellidos,
    this.numeroDocumento,
    this.imagenPerfil,
    this.whatsappContacto,
    this.correo,
    this.direccion,
    this.tipoDocumento,
    this.password,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: json['id_cliente'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      numeroDocumento: json['num_documento'],
      imagenPerfil: json['imagen_perfil'],
      whatsappContacto: json['whatsapp_contacto'],
      correo: json['correo'],
      direccion: json['direccion'],
      tipoDocumento: json['tipo_documento'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_cliente': idCliente,
      'nombres': nombres,
      'apellidos': apellidos,
      'num_documento': numeroDocumento,
      'imagen_perfil': imagenPerfil,
      'whatsapp_contacto': whatsappContacto,
      'correo': correo,
      'direccion': direccion,
      'tipo_documento': tipoDocumento,
      'password': password,
    };
  }

  Cliente copyWith({
    int? idCliente,
    String? nombres,
    String? apellidos,
    String? numeroDocumento,
    String? imagenPerfil,
    String? whatsappContacto,
    String? correo,
    String? direccion,
    String? tipoDocumento,
    String? password,
  }) {
    return Cliente(
      idCliente: idCliente ?? this.idCliente,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      imagenPerfil: imagenPerfil ?? this.imagenPerfil,
      whatsappContacto: whatsappContacto ?? this.whatsappContacto,
      correo: correo ?? this.correo,
      direccion: direccion ?? this.direccion,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      password: password ?? this.password,
    );
  }

  @override
  String toString() {
    return 'Cliente(idCliente: $idCliente, nombres: $nombres, apellidos: $apellidos)';
  }
} 
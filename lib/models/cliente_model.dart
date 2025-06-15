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
    print('Procesando JSON en fromJson: $json'); // Debug

    int? parseId(dynamic value) {
      print('Intentando parsear ID: $value (tipo: ${value.runtimeType})'); // Debug
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print('Error al parsear ID como String: $e'); // Debug
          return null;
        }
      }
      if (value is double) {
        return value.toInt();
      }
      print('Tipo de ID no manejado: ${value.runtimeType}'); // Debug
      return null;
    }

    final id = parseId(json['id_cliente']);
    print('ID parseado: $id'); // Debug

    return Cliente(
      idCliente: id,
      nombres: json['nombres']?.toString(),
      apellidos: json['apellidos']?.toString(),
      correo: json['correo']?.toString(),
      password: json['password']?.toString(),
      direccion: json['direccion']?.toString(),
      whatsappContacto: json['whatsapp_contacto']?.toString(),
      tipoDocumento: json['tipo_documento']?.toString(),
      numeroDocumento: json['num_documento']?.toString(),
      imagenPerfil: json['imagen_perfil']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idCliente != null) 'id_cliente': idCliente,
      if (nombres != null) 'nombres': nombres,
      if (apellidos != null) 'apellidos': apellidos,
      if (correo != null) 'correo': correo,
      if (password != null) 'password': password,
      if (direccion != null) 'direccion': direccion,
      if (whatsappContacto != null) 'whatsapp_contacto': whatsappContacto,
      if (tipoDocumento != null) 'tipo_documento': tipoDocumento,
      if (numeroDocumento != null) 'num_documento': numeroDocumento,
      if (imagenPerfil != null) 'imagen_perfil': imagenPerfil,
    };
  }

  @override
  String toString() {
    return 'Cliente(idCliente: $idCliente, nombres: $nombres, apellidos: $apellidos)';
  }
} 
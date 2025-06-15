import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/cliente_model.dart';
import '../services/cliente_service.dart';

class ClienteProfileScreen extends StatefulWidget {
  final String correo;

  const ClienteProfileScreen({Key? key, required this.correo}) : super(key: key);

  @override
  State<ClienteProfileScreen> createState() => _ClienteProfileScreenState();
}

class _ClienteProfileScreenState extends State<ClienteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clienteService = ClienteService();
  final _imagePicker = ImagePicker();
  
  File? _imageFile;
  bool _isLoading = true;
  String? _errorMessage;
  Cliente? _cliente;

  // Controladores para los campos del formulario
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _direccionController = TextEditingController();
  final _whatsappController = TextEditingController();
  String _tipoDocumento = 'DNI';
  final _numeroDocumentoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarCliente();
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _direccionController.dispose();
    _whatsappController.dispose();
    _numeroDocumentoController.dispose();
    super.dispose();
  }

  Future<void> _cargarCliente() async {
    try {
      final cliente = await _clienteService.obtenerCliente(widget.correo);
      setState(() {
        _cliente = cliente;
        _nombresController.text = cliente.nombres ?? '';
        _apellidosController.text = cliente.apellidos ?? '';
        _direccionController.text = cliente.direccion ?? '';
        _whatsappController.text = cliente.whatsappContacto ?? '';
        _tipoDocumento = cliente.tipoDocumento ?? 'DNI';
        _numeroDocumentoController.text = cliente.numeroDocumento ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los datos del cliente: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al seleccionar la imagen: $e';
      });
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cliente = Cliente(
        idCliente: _cliente?.idCliente,
        nombres: _nombresController.text,
        apellidos: _apellidosController.text,
        correo: widget.correo,
        direccion: _direccionController.text,
        whatsappContacto: _whatsappController.text,
        tipoDocumento: _tipoDocumento,
        numeroDocumento: _numeroDocumentoController.text,
      );

      if (_imageFile != null) {
        await _clienteService.actualizarClienteConImagen(cliente, _imageFile!);
      } else {
        await _clienteService.actualizarCliente(cliente);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado exitosamente')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al actualizar el perfil: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil de Cliente'),
        ),
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Cliente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen de perfil
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : _cliente?.imagenPerfil != null
                              ? NetworkImage(
                                  'http://192.168.0.105:8081${_cliente!.imagenPerfil}')
                              : null as ImageProvider?,
                      child: (_imageFile == null &&
                              _cliente?.imagenPerfil == null)
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Campos del formulario
              TextFormField(
                controller: _nombresController,
                decoration: const InputDecoration(
                  labelText: 'Nombres',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese los nombres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _apellidosController,
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese los apellidos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _tipoDocumento,
                decoration: const InputDecoration(
                  labelText: 'Tipo de documento',
                  border: OutlineInputBorder(),
                ),
                items: ['DNI', 'CE', 'PASAPORTE']
                    .map((tipo) => DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _tipoDocumento = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _numeroDocumentoController,
                decoration: const InputDecoration(
                  labelText: 'Número de documento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el número de documento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _whatsappController,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _guardarCambios,
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
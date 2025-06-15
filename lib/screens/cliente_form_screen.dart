import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/cliente_model.dart';
import '../services/cliente_service.dart';

class ClienteFormScreen extends StatefulWidget {
  final Cliente? cliente;

  const ClienteFormScreen({Key? key, this.cliente}) : super(key: key);

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clienteService = ClienteService();
  final _imagePicker = ImagePicker();
  
  File? _imageFile;
  bool _isLoading = false;
  String? _errorMessage;

  // Controladores para los campos del formulario
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _direccionController = TextEditingController();
  final _whatsappController = TextEditingController();
  String _tipoDocumento = 'DNI';
  final _numeroDocumentoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.cliente != null) {
      _nombresController.text = widget.cliente!.nombres ?? '';
      _apellidosController.text = widget.cliente!.apellidos ?? '';
      _correoController.text = widget.cliente!.correo ?? '';
      _direccionController.text = widget.cliente!.direccion ?? '';
      _whatsappController.text = widget.cliente!.whatsappContacto ?? '';
      _tipoDocumento = widget.cliente!.tipoDocumento ?? 'DNI';
      _numeroDocumentoController.text = widget.cliente!.numeroDocumento ?? '';
    }
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _direccionController.dispose();
    _whatsappController.dispose();
    _numeroDocumentoController.dispose();
    super.dispose();
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

  Future<void> _guardarCliente() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cliente = Cliente(
        idCliente: widget.cliente?.idCliente,
        nombres: _nombresController.text,
        apellidos: _apellidosController.text,
        correo: _correoController.text,
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
        direccion: _direccionController.text,
        whatsappContacto: _whatsappController.text,
        tipoDocumento: _tipoDocumento,
        numeroDocumento: _numeroDocumentoController.text,
      );

      if (widget.cliente == null) {
        // Crear nuevo cliente
        if (_imageFile != null) {
          await _clienteService.guardarClienteConImagen(
            cliente,
            _imageFile!,
          );
        } else {
          await _clienteService.guardarCliente(cliente);
        }
      } else {
        // Actualizar cliente existente
        if (_imageFile != null) {
          await _clienteService.actualizarClienteConImagen(
            cliente,
            _imageFile!,
          );
        } else {
          await _clienteService.actualizarCliente(cliente);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.cliente == null
                  ? 'Cliente creado exitosamente'
                  : 'Cliente actualizado exitosamente',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al guardar el cliente: $e';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cliente == null ? 'Nuevo Cliente' : 'Editar Cliente'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                                : widget.cliente?.imagenPerfil != null
                                    ? NetworkImage(
                                        'http://192.168.0.105:8081${widget.cliente!.imagenPerfil}')
                                    : null as ImageProvider?,
                            child: (_imageFile == null &&
                                    widget.cliente?.imagenPerfil == null)
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

                    TextFormField(
                      controller: _correoController,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el correo electrónico';
                        }
                        if (!value.contains('@')) {
                          return 'Por favor ingrese un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    if (widget.cliente == null)
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese la contraseña';
                          }
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
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

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    ElevatedButton(
                      onPressed: _guardarCliente,
                      child: Text(
                        widget.cliente == null ? 'Crear Cliente' : 'Actualizar Cliente',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 
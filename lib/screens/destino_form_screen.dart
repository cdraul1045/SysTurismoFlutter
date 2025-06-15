import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/destino_model.dart';
import '../services/destino_service.dart';

class DestinoFormScreen extends StatefulWidget {
  final Destino? destino;

  const DestinoFormScreen({super.key, this.destino});

  @override
  State<DestinoFormScreen> createState() => _DestinoFormScreenState();
}

class _DestinoFormScreenState extends State<DestinoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinoService = DestinoService();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ubicacionController = TextEditingController();
  File? _imagenSeleccionada;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.destino != null) {
      _nombreController.text = widget.destino!.nombre ?? '';
      _descripcionController.text = widget.destino!.descripcion ?? '';
      _ubicacionController.text = widget.destino!.ubicacion ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);

      if (imagen != null) {
        setState(() {
          _imagenSeleccionada = File(imagen.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar la imagen: $e')),
        );
      }
    }
  }

  Future<void> _guardarDestino() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final destino = Destino(
        idDestino: widget.destino?.idDestino,
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
        ubicacion: _ubicacionController.text,
      );

      final resultado = _imagenSeleccionada != null
          ? widget.destino == null
              ? await _destinoService.guardarDestinoConImagen(destino, _imagenSeleccionada!)
              : await _destinoService.actualizarDestinoConImagen(destino, _imagenSeleccionada!)
          : widget.destino == null
              ? await _destinoService.guardarDestino(destino)
              : await _destinoService.actualizarDestino(destino);

      if (mounted) {
        Navigator.pop(context, resultado);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el destino: $e')),
        );
      }
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
        title: Text(widget.destino == null ? 'Nuevo Destino' : 'Editar Destino'),
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
                    GestureDetector(
                      onTap: _seleccionarImagen,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _imagenSeleccionada != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _imagenSeleccionada!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : widget.destino?.imagenPath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      'http://192.168.0.105:8081${widget.destino!.imagenPath}',
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Toca para seleccionar una imagen',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el nombre del destino';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese la descripción del destino';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ubicacionController,
                      decoration: const InputDecoration(
                        labelText: 'Ubicación',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese la ubicación del destino';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _guardarDestino,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.destino == null ? 'Guardar' : 'Actualizar',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 
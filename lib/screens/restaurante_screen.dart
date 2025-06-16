import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/restaurante_model.dart';
import '../models/destino_model.dart';
import '../services/restaurante_service.dart';
import '../services/destino_service.dart';

class RestauranteScreen extends StatefulWidget {
  const RestauranteScreen({super.key});

  @override
  State<RestauranteScreen> createState() => _RestauranteScreenState();
}

class _RestauranteScreenState extends State<RestauranteScreen> {
  final RestauranteService _restauranteService = RestauranteService();
  final DestinoService _destinoService = DestinoService();
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _direccionController = TextEditingController();
  final _whatsappController = TextEditingController();
  File? _imagenSeleccionada;
  Destino? _destinoSeleccionado;
  List<Restaurante> _restaurantes = [];
  List<Destino> _destinos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final restaurantes = await _restauranteService.listarRestaurantes();
      final destinos = await _destinoService.listarDestinos();

      setState(() {
        _restaurantes = restaurantes;
        _destinos = destinos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _obtenerNombreDestino(int? idDestino) {
    if (idDestino == null) return 'Sin destino';
    final destino = _destinos.firstWhere(
      (d) => d.idDestino == idDestino,
      orElse: () => Destino(idDestino: idDestino, nombre: 'Desconocido'),
    );
    return destino.nombre ?? 'Sin nombre';
  }

  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);

    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = File(imagen.path);
      });
    }
  }

  Future<void> _mostrarFormulario([Restaurante? restaurante]) async {
    if (restaurante != null) {
      _nombreController.text = restaurante.nombre;
      _descripcionController.text = restaurante.descripcion ?? '';
      _direccionController.text = restaurante.direccion ?? '';
      _whatsappController.text = restaurante.whatsappContacto ?? '';
      _destinoSeleccionado = _destinos.firstWhere(
        (d) => d.idDestino == restaurante.idDestino,
        orElse: () => _destinos.first,
      );
    } else {
      _nombreController.clear();
      _descripcionController.clear();
      _direccionController.clear();
      _whatsappController.clear();
      _destinoSeleccionado = null;
      _imagenSeleccionada = null;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(restaurante == null ? 'Nuevo Restaurante' : 'Editar Restaurante'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el nombre';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
                TextFormField(
                  controller: _direccionController,
                  decoration: const InputDecoration(labelText: 'Dirección'),
                ),
                TextFormField(
                  controller: _whatsappController,
                  decoration: const InputDecoration(labelText: 'WhatsApp'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Destino>(
                  value: _destinoSeleccionado,
                  decoration: const InputDecoration(labelText: 'Destino'),
                  items: _destinos.map((destino) {
                    return DropdownMenuItem(
                      value: destino,
                      child: Text(destino.nombre ?? 'Sin nombre'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _destinoSeleccionado = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor seleccione un destino';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (restaurante == null) ...[
                  ElevatedButton.icon(
                    onPressed: _seleccionarImagen,
                    icon: const Icon(Icons.image),
                    label: const Text('Seleccionar Imagen '),
                  ),
                  if (_imagenSeleccionada != null) ...[
                    const SizedBox(height: 8),
                    Image.file(
                      _imagenSeleccionada!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  if (restaurante == null) {
                    if (_imagenSeleccionada != null) {
                      await _restauranteService.guardarRestauranteConImagen(
                        nombre: _nombreController.text,
                        descripcion: _descripcionController.text,
                        direccion: _direccionController.text,
                        whatsappContacto: _whatsappController.text,
                        idDestino: _destinoSeleccionado!.idDestino!,
                        imagen: _imagenSeleccionada!,
                      );
                    } else {
                      await _restauranteService.guardarRestaurante(
                        Restaurante(
                          nombre: _nombreController.text,
                          descripcion: _descripcionController.text,
                          direccion: _direccionController.text,
                          whatsappContacto: _whatsappController.text,
                          idDestino: _destinoSeleccionado!.idDestino,
                        ),
                      );
                    }
                  } else {
                    await _restauranteService.actualizarRestaurante(
                      restaurante.copyWith(
                        nombre: _nombreController.text,
                        descripcion: _descripcionController.text,
                        direccion: _direccionController.text,
                        whatsappContacto: _whatsappController.text,
                        idDestino: _destinoSeleccionado?.idDestino,
                      ),
                    );
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    _cargarDatos();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(restaurante == null
                            ? 'Restaurante guardado exitosamente'
                            : 'Restaurante actualizado exitosamente'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: Text(restaurante == null ? 'Guardar' : 'Actualizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarRestaurante(Restaurante restaurante) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este restaurante?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      try {
        await _restauranteService.eliminarRestaurante(restaurante.idRestaurante!);
        if (mounted) {
          _cargarDatos();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restaurante eliminado exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          String mensajeError = 'Error al eliminar el restaurante';
          if (e.toString().contains('500')) {
            mensajeError = 'No se puede eliminar el restaurante porque tiene reservas asociadas';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mensajeError),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Restaurantes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  itemCount: _restaurantes.length,
                  itemBuilder: (context, index) {
                    final restaurante = _restaurantes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: restaurante.imagenPath != null
                            ? Image.network(
                                'http://192.168.0.105:8081${restaurante.imagenPath}',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error),
                              )
                            : const Icon(Icons.restaurant),
                        title: Text(restaurante.nombre),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Destino: ${_obtenerNombreDestino(restaurante.idDestino)}'),
                            if (restaurante.direccion != null)
                              Text('Dirección: ${restaurante.direccion}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _mostrarFormulario(restaurante),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _eliminarRestaurante(restaurante),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _direccionController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }
} 
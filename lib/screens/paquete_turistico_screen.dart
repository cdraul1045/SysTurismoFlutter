import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/paquete_turistico_model.dart';
import '../models/destino_model.dart';
import '../services/paquete_turistico_service.dart';
import '../services/destino_service.dart';

class PaqueteTuristicoScreen extends StatefulWidget {
  const PaqueteTuristicoScreen({super.key});

  @override
  State<PaqueteTuristicoScreen> createState() => _PaqueteTuristicoScreenState();
}

class _PaqueteTuristicoScreenState extends State<PaqueteTuristicoScreen> {
  final PaqueteTuristicoService _paqueteService = PaqueteTuristicoService();
  final DestinoService _destinoService = DestinoService();
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _duracionController = TextEditingController();
  final _precioController = TextEditingController();
  final _whatsappController = TextEditingController();
  File? _imagenSeleccionada;
  Destino? _destinoSeleccionado;
  List<PaqueteTuristico> _paquetes = [];
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

      final paquetes = await _paqueteService.listarPaquetes();
      final destinos = await _destinoService.listarDestinos();

      setState(() {
        _paquetes = paquetes;
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

  Future<void> _mostrarFormulario([PaqueteTuristico? paquete]) async {
    if (paquete != null) {
      _nombreController.text = paquete.nombre;
      _descripcionController.text = paquete.descripcion ?? '';
      _duracionController.text = paquete.duracionDias.toString();
      _precioController.text = paquete.precioTotal.toString();
      _whatsappController.text = paquete.whatsappContacto ?? '';
      _destinoSeleccionado = _destinos.firstWhere(
        (d) => d.idDestino == paquete.idDestino,
        orElse: () => _destinos.first,
      );
    } else {
      _nombreController.clear();
      _descripcionController.clear();
      _duracionController.clear();
      _precioController.clear();
      _whatsappController.clear();
      _destinoSeleccionado = null;
      _imagenSeleccionada = null;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(paquete == null ? 'Nuevo Paquete Turístico' : 'Editar Paquete Turístico'),
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
                  controller: _duracionController,
                  decoration: const InputDecoration(labelText: 'Duración (días)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la duración';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Por favor ingrese un número válido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _precioController,
                  decoration: const InputDecoration(labelText: 'Precio Total'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el precio';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Por favor ingrese un número válido';
                    }
                    return null;
                  },
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
                if (paquete == null) ...[
                  ElevatedButton.icon(
                    onPressed: _seleccionarImagen,
                    icon: const Icon(Icons.image),
                    label: const Text('Seleccionar Imagen'),
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
                  if (paquete == null) {
                    if (_imagenSeleccionada != null) {
                      await _paqueteService.guardarPaqueteConImagen(
                        nombre: _nombreController.text,
                        descripcion: _descripcionController.text,
                        duracionDias: int.parse(_duracionController.text),
                        whatsappContacto: _whatsappController.text,
                        precio: double.parse(_precioController.text),
                        idDestino: _destinoSeleccionado!.idDestino!,
                        imagen: _imagenSeleccionada!,
                      );
                    } else {
                      await _paqueteService.guardarPaquete(
                        PaqueteTuristico(
                          nombre: _nombreController.text,
                          descripcion: _descripcionController.text,
                          duracionDias: int.parse(_duracionController.text),
                          precioTotal: double.parse(_precioController.text),
                          whatsappContacto: _whatsappController.text,
                          idDestino: _destinoSeleccionado?.idDestino,
                        ),
                      );
                    }
                  } else {
                    await _paqueteService.actualizarPaquete(
                      paquete.copyWith(
                        nombre: _nombreController.text,
                        descripcion: _descripcionController.text,
                        duracionDias: int.parse(_duracionController.text),
                        precioTotal: double.parse(_precioController.text),
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
                        content: Text(paquete == null
                            ? 'Paquete guardado exitosamente'
                            : 'Paquete actualizado exitosamente'),
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
            child: Text(paquete == null ? 'Guardar' : 'Actualizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarPaquete(PaqueteTuristico paquete) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este paquete turístico?'),
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
        await _paqueteService.eliminarPaquete(paquete.idPaqueteTuristico!);
        if (mounted) {
          _cargarDatos();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paquete eliminado exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          String mensajeError = 'Error al eliminar el paquete';
          if (e.toString().contains('500')) {
            mensajeError = 'No se puede eliminar el paquete porque tiene reservas asociadas';
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
        title: const Text('Gestión de Paquetes Turísticos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  itemCount: _paquetes.length,
                  itemBuilder: (context, index) {
                    final paquete = _paquetes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: paquete.imagenPath != null
                            ? Image.network(
                                'http://192.168.0.105:8081${paquete.imagenPath}',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.card_travel),
                              )
                            : const Icon(Icons.card_travel),
                        title: Text(paquete.nombre),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Destino: ${_obtenerNombreDestino(paquete.idDestino)}'),
                            Text('Duración: ${paquete.duracionDias} días'),
                            Text('Precio: S/. ${paquete.precioTotal.toStringAsFixed(2)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _mostrarFormulario(paquete),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _eliminarPaquete(paquete),
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
    _duracionController.dispose();
    _precioController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }
} 
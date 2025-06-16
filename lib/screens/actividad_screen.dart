import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/actividad_model.dart';
import '../models/destino_model.dart';
import '../services/actividad_service.dart';
import '../services/destino_service.dart';

class ActividadScreen extends StatefulWidget {
  const ActividadScreen({super.key});

  @override
  State<ActividadScreen> createState() => _ActividadScreenState();
}

class _ActividadScreenState extends State<ActividadScreen> {
  final ActividadService _service = ActividadService();
  final DestinoService _destinoService = DestinoService();
  List<Actividad> _actividades = [];
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

      final actividades = await _service.listarActividades();
      final destinos = await _destinoService.listarDestinos();

      setState(() {
        _actividades = actividades;
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
      orElse: () => Destino.defaultDestino(),
    );
    return destino.nombre ?? 'Sin destino';
  }

  void _mostrarFormulario([Actividad? actividad]) {
    final nombreController = TextEditingController(text: actividad?.nombre);
    final descripcionController = TextEditingController(text: actividad?.descripcion);
    final precioController = TextEditingController(
      text: actividad?.precio?.toString() ?? '',
    );
    final nivelRiesgoController = TextEditingController(text: actividad?.nivelRiesgo);
    final whatsappController = TextEditingController(text: actividad?.whatsappContacto);
    Destino? selectedDestino;

    if (actividad?.idDestino != null) {
      selectedDestino = _destinos.firstWhere(
        (d) => d.idDestino == actividad?.idDestino,
        orElse: () => _destinos.first,
      );
    } else if (_destinos.isNotEmpty) {
      selectedDestino = _destinos.first;
    }

    File? imagenSeleccionada;

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(actividad == null ? 'Nueva Actividad' : 'Editar Actividad'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'El nombre es requerido' : null,
                ),
                const SizedBox(height: 16),
                if (_destinos.isNotEmpty)
                  DropdownButtonFormField<Destino>(
                    value: selectedDestino,
                    decoration: const InputDecoration(labelText: 'Destino'),
                    items: _destinos.map((destino) {
                      return DropdownMenuItem(
                        value: destino,
                        child: Text(destino.nombre ?? 'Sin nombre'),
                      );
                    }).toList(),
                    onChanged: (Destino? value) {
                      selectedDestino = value;
                    },
                    validator: (value) =>
                        value == null ? 'El destino es requerido' : null,
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: precioController,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'El precio es requerido';
                    }
                    if (double.tryParse(value!) == null) {
                      return 'Ingrese un precio válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nivelRiesgoController,
                  decoration: const InputDecoration(labelText: 'Nivel de Riesgo'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'El nivel de riesgo es requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: whatsappController,
                  decoration: const InputDecoration(labelText: 'WhatsApp de contacto'),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? imagen = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (imagen != null) {
                      imagenSeleccionada = File(imagen.path);
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Seleccionar Imagen'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  final nuevaActividad = Actividad(
                    idActividad: actividad?.idActividad,
                    nombre: nombreController.text,
                    idDestino: selectedDestino?.idDestino,
                    descripcion: descripcionController.text,
                    precio: double.tryParse(precioController.text),
                    nivelRiesgo: nivelRiesgoController.text,
                    whatsappContacto: whatsappController.text,
                  );

                  if (imagenSeleccionada != null) {
                    await _service.guardarActividadConImagen(
                      nuevaActividad,
                      imagenSeleccionada!,
                    );
                  } else if (actividad == null) {
                    await _service.guardarActividad(nuevaActividad);
                  } else {
                    await _service.actualizarActividad(nuevaActividad);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    _cargarDatos();
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
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _eliminarActividad(Actividad actividad) async {
    if (actividad.idActividad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID de la actividad no encontrado')),
      );
      return;
    }

    try {
      await _service.eliminarActividad(actividad.idActividad!);
      if (mounted) {
        setState(() {
          _actividades.removeWhere((a) => a.idActividad == actividad.idActividad);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Actividad eliminada exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar la actividad: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Actividades'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : ListView.builder(
                  itemCount: _actividades.length,
                  itemBuilder: (context, index) {
                    final actividad = _actividades[index];
                    return ListTile(
                      title: Text(actividad.nombre ?? 'Sin nombre'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Destino: ${_obtenerNombreDestino(actividad.idDestino)}'),
                          Text('Precio: \$${actividad.precio ?? 0}'),
                          Text('Nivel de Riesgo: ${actividad.nivelRiesgo ?? 'No especificado'}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _mostrarFormulario(actividad),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _eliminarActividad(actividad),
                          ),
                        ],
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
} 
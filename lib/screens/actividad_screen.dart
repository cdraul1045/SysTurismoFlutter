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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedDestino;
  String? _selectedNivelRiesgo;
  RangeValues _precioRange = const RangeValues(10, 300);
  
  // Lista de destinos disponibles
  final List<String> _destinosList = ["Capachica", "Chifrón", "Isla", "Llachón"];
  
  // Lista de niveles de riesgo
  final List<String> _nivelesRiesgo = ["Bajo", "Moderado", "Alto"];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    if (idDestino == null || idDestino < 1 || idDestino > _destinosList.length) {
      return 'Sin destino';
    }
    return _destinosList[idDestino - 1];
  }

  Color _obtenerColorRiesgo(String? nivelRiesgo) {
    switch (nivelRiesgo?.toLowerCase()) {
      case 'bajo':
        return Colors.green;
      case 'moderado':
        return Colors.orange;
      case 'alto':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<Actividad> get _filteredActividades {
    return _actividades.where((actividad) {
      final matchesSearch = actividad.nombre?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      final matchesDestino = _selectedDestino == null || 
          _obtenerNombreDestino(actividad.idDestino) == _selectedDestino;
      final matchesPrecio = actividad.precio != null &&
          actividad.precio! >= _precioRange.start &&
          actividad.precio! <= _precioRange.end;
      final matchesRiesgo = _selectedNivelRiesgo == null ||
          actividad.nivelRiesgo == _selectedNivelRiesgo;
      
      return matchesSearch && matchesDestino && matchesPrecio && matchesRiesgo;
    }).toList();
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
        title: const Text('Actividades'),
      ),
      body: Column(
        children: [
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar Actividades',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),

          // Filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Filtro de destino
                DropdownButton<String>(
                  value: _selectedDestino,
                  hint: const Text('Destino'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Todos los destinos'),
                    ),
                    ..._destinosList.map((destino) {
                      return DropdownMenuItem<String>(
                        value: destino,
                        child: Text(destino),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDestino = value;
                    });
                  },
                ),
                const SizedBox(width: 16),

                // Filtro de nivel de riesgo
                DropdownButton<String>(
                  value: _selectedNivelRiesgo,
                  hint: const Text('Nivel de Riesgo'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Todos los niveles'),
                    ),
                    ..._nivelesRiesgo.map((riesgo) {
                      return DropdownMenuItem<String>(
                        value: riesgo,
                        child: Text(riesgo),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedNivelRiesgo = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // Filtro de precio
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rango de Precio (S/.)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                RangeSlider(
                  values: _precioRange,
                  min: 10,
                  max: 300,
                  divisions: 29,
                  labels: RangeLabels(
                    'S/. ${_precioRange.start.round()}',
                    'S/. ${_precioRange.end.round()}',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _precioRange = values;
                    });
                  },
                ),
              ],
            ),
          ),

          // Lista de actividades
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredActividades.length,
                        itemBuilder: (context, index) {
                          final actividad = _filteredActividades[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          actividad.nombre ?? 'Sin nombre',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (actividad.nivelRiesgo != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _obtenerColorRiesgo(actividad.nivelRiesgo).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _obtenerColorRiesgo(actividad.nivelRiesgo),
                                            ),
                                          ),
                                          child: Text(
                                            actividad.nivelRiesgo!,
                                            style: TextStyle(
                                              color: _obtenerColorRiesgo(actividad.nivelRiesgo),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (actividad.descripcion != null) ...[
                                    Text(
                                      actividad.descripcion!,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'S/. ${actividad.precio?.toStringAsFixed(2) ?? "0.00"}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      Text(
                                        _obtenerNombreDestino(actividad.idDestino),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
} 
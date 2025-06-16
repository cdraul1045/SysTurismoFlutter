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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedDestino;
  String? _selectedDireccion;
  
  // Lista de destinos disponibles
  final List<String> _destinosList = ["Capachica", "Chifrón", "Isla", "Llachón"];
  
  // Lista de direcciones disponibles
  final List<String> _direcciones = [
    "Calle Principal",
    "Avenida Central",
    "Plaza Mayor",
    "Zona Turística"
  ];

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
    if (idDestino == null || idDestino < 1 || idDestino > _destinosList.length) {
      return 'Sin destino';
    }
    return _destinosList[idDestino - 1];
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

  List<Restaurante> get _filteredRestaurantes {
    return _restaurantes.where((restaurante) {
      final matchesSearch = restaurante.nombre.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDestino = _selectedDestino == null || 
          _obtenerNombreDestino(restaurante.idDestino) == _selectedDestino;
      final matchesDireccion = _selectedDireccion == null ||
          restaurante.direccion == _selectedDireccion;
      
      return matchesSearch && matchesDestino && matchesDireccion;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurantes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    // Campo de búsqueda
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar Restaurantes',
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

                          // Filtro de dirección
                          DropdownButton<String>(
                            value: _selectedDireccion,
                            hint: const Text('Dirección'),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Todas las direcciones'),
                              ),
                              ..._direcciones.map((direccion) {
                                return DropdownMenuItem<String>(
                                  value: direccion,
                                  child: Text(direccion),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedDireccion = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // Lista de restaurantes
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredRestaurantes.length,
                        itemBuilder: (context, index) {
                          final restaurante = _filteredRestaurantes[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    restaurante.nombre,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (restaurante.descripcion != null) ...[
                                    Text(
                                      restaurante.descripcion!,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  if (restaurante.direccion != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        restaurante.direccion!,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
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

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _direccionController.dispose();
    _whatsappController.dispose();
    _searchController.dispose();
    super.dispose();
  }
} 
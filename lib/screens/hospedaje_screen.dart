import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hospedaje_model.dart';
import '../models/destino_model.dart';
import '../services/hospedaje_service.dart';
import '../services/destino_service.dart';

class HospedajeScreen extends StatefulWidget {
  const HospedajeScreen({super.key});

  @override
  State<HospedajeScreen> createState() => _HospedajeScreenState();
}

class _HospedajeScreenState extends State<HospedajeScreen> {
  final HospedajeService _service = HospedajeService();
  final DestinoService _destinoService = DestinoService();
  List<Hospedaje> _hospedajes = [];
  List<Destino> _destinos = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedDestino;
  RangeValues _precioRange = const RangeValues(50, 500);
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

  // Lista de hospedajes de prueba
  final List<Hospedaje> _hospedajesList = [
    Hospedaje(
      idHospedaje: 1,
      nombre: "Hotel Capachica",
      descripcion: "Hotel con vista al lago",
      precioPorNoche: 150.0,
      idDestino: 1,
      direccion: "Calle Principal",
    ),
    Hospedaje(
      idHospedaje: 2,
      nombre: "Hostal Chifrón",
      descripcion: "Hostal familiar",
      precioPorNoche: 80.0,
      idDestino: 2,
      direccion: "Avenida Central",
    ),
    Hospedaje(
      idHospedaje: 3,
      nombre: "Cabañas Isla",
      descripcion: "Cabañas rústicas",
      precioPorNoche: 200.0,
      idDestino: 3,
      direccion: "Plaza Mayor",
    ),
    Hospedaje(
      idHospedaje: 4,
      nombre: "Hotel Llachón",
      descripcion: "Hotel de lujo",
      precioPorNoche: 300.0,
      idDestino: 4,
      direccion: "Zona Turística",
    ),
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

      final hospedajes = await _service.listarHospedajes();
      final destinos = await _destinoService.listarDestinos();

      setState(() {
        _hospedajes = hospedajes;
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

  void _mostrarFormulario([Hospedaje? hospedaje]) {
    final nombreController = TextEditingController(text: hospedaje?.nombre);
    final descripcionController = TextEditingController(text: hospedaje?.descripcion);
    final precioController = TextEditingController(
      text: hospedaje?.precioPorNoche?.toString() ?? '',
    );
    final whatsappController = TextEditingController(text: hospedaje?.whatsappContacto);
    final direccionController = TextEditingController(text: hospedaje?.direccion);
    Destino? selectedDestino;

    if (hospedaje?.idDestino != null) {
      selectedDestino = _destinos.firstWhere(
        (d) => d.idDestino == hospedaje?.idDestino,
        orElse: () => _destinos.first,
      );
    } else if (_destinos.isNotEmpty) {
      selectedDestino = _destinos.first;
    }

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(hospedaje == null ? 'Nuevo Hospedaje' : 'Editar Hospedaje'),
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
                  decoration: const InputDecoration(labelText: 'Precio por noche'),
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
                  controller: whatsappController,
                  decoration: const InputDecoration(labelText: 'WhatsApp de contacto'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: direccionController,
                  decoration: const InputDecoration(labelText: 'Dirección'),
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
                  final nuevoHospedaje = Hospedaje(
                    idHospedaje: hospedaje?.idHospedaje,
                    nombre: nombreController.text,
                    idDestino: selectedDestino?.idDestino,
                    descripcion: descripcionController.text,
                    precioPorNoche: double.tryParse(precioController.text),
                    whatsappContacto: whatsappController.text,
                    direccion: direccionController.text,
                  );

                  if (hospedaje == null) {
                    await _service.guardarHospedaje(nuevoHospedaje);
                  } else {
                    await _service.actualizarHospedaje(nuevoHospedaje);
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

  Future<void> _eliminarHospedaje(Hospedaje hospedaje) async {
    if (hospedaje.idHospedaje == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID del hospedaje no encontrado')),
      );
      return;
    }

    try {
      await _service.eliminarHospedaje(hospedaje.idHospedaje!);
      if (mounted) {
        setState(() {
          _hospedajes.removeWhere((h) => h.idHospedaje == hospedaje.idHospedaje);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hospedaje eliminado exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el hospedaje: $e')),
        );
      }
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

  List<Hospedaje> get _filteredHospedajes {
    return _hospedajes.where((hospedaje) {
      final matchesSearch = hospedaje.nombre.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDestino = _selectedDestino == null || 
          _obtenerNombreDestino(hospedaje.idDestino) == _selectedDestino;
      final matchesPrecio = hospedaje.precioPorNoche != null &&
          hospedaje.precioPorNoche! >= _precioRange.start &&
          hospedaje.precioPorNoche! <= _precioRange.end;
      final matchesDireccion = _selectedDireccion == null ||
          hospedaje.direccion == _selectedDireccion;
      
      return matchesSearch && matchesDestino && matchesPrecio && matchesDireccion;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospedajes'),
      ),
      body: Column(
        children: [
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar Hospedajes',
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
                    ..._destinos.map((destino) {
                      return DropdownMenuItem<String>(
                        value: destino.nombre,
                        child: Text(destino.nombre ?? 'Sin nombre'),
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
                  min: 50,
                  max: 500,
                  divisions: 45,
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

          // Lista de hospedajes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredHospedajes.length,
              itemBuilder: (context, index) {
                final hospedaje = _filteredHospedajes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hospedaje.nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (hospedaje.descripcion != null) ...[
                          Text(
                            hospedaje.descripcion!,
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
                              'S/. ${hospedaje.precioPorNoche?.toStringAsFixed(2) ?? "0.00"}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            if (hospedaje.direccion != null)
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
                                  hospedaje.direccion!,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                  ),
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
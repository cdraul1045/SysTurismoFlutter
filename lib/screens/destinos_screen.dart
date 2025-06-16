import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/destino_model.dart';
import '../services/destino_service.dart';
import '../services/report_service.dart';
import 'destino_form_screen.dart';

class DestinosScreen extends StatefulWidget {
  const DestinosScreen({super.key});

  @override
  State<DestinosScreen> createState() => _DestinosScreenState();
}

class _DestinosScreenState extends State<DestinosScreen> {
  final DestinoService _destinoService = DestinoService();
  final ReportService _reportService = ReportService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedUbicacion;

  // Lista de ubicaciones disponibles
  final List<String> _ubicaciones = ["Capachica", "Chifrón", "Isla", "Llachón"];

  List<Destino> _destinos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarDestinos();
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

  Future<void> _cargarDestinos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final destinos = await _destinoService.listarDestinos();
      print('Destinos cargados: ${destinos.length}');
      for (var destino in destinos) {
        print('Destino: ${destino.toString()}');
      }
      setState(() {
        _destinos = destinos;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar destinos: $e');
      setState(() {
        _errorMessage = 'Error al cargar los destinos: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _eliminarDestino(Destino destino) async {
    if (destino.idDestino == null) {
      print('Error: ID del destino es null');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: ID del destino no encontrado')),
        );
      }
      return;
    }

    try {
      print('Eliminando destino: ${destino.toString()}');
      await _destinoService.eliminarDestino(destino.idDestino!);
      if (mounted) {
        setState(() {
          _destinos.removeWhere((d) => d.idDestino == destino.idDestino);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Destino eliminado exitosamente')),
        );
      }
    } catch (e) {
      print('Error al eliminar destino: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el destino: $e')),
        );
      }
    }
  }

  Future<void> _mostrarDialogoEliminar(Destino destino) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Está seguro de eliminar el destino ${destino.nombre}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _eliminarDestino(destino);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editarDestino(Destino destino) async {
    try {
      print('Editando destino: ${destino.toString()}');
      final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DestinoFormScreen(destino: destino),
        ),
      );

      if (resultado != null && resultado is Destino) {
        print('Destino actualizado: ${resultado.toString()}');
        setState(() {
          final index = _destinos.indexWhere((d) => d.idDestino == destino.idDestino);
          if (index != -1) {
            _destinos[index] = resultado;
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Destino actualizado exitosamente')),
          );
        }
      }
    } catch (e) {
      print('Error al editar destino: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al editar el destino: $e')),
        );
      }
    }
  }

  Future<void> _agregarDestino() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DestinoFormScreen(),
      ),
    );

    if (resultado != null && resultado is Destino) {
      print('Nuevo destino agregado: ${resultado.toString()}');
      setState(() {
        _destinos.add(resultado);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Destino agregado exitosamente')),
        );
      }
    }
  }

  List<Destino> get _filteredDestinos {
    return _destinos.where((destino) {
      final matchesSearch = destino.nombre?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      final matchesUbicacion = _selectedUbicacion == null || destino.ubicacion == _selectedUbicacion;
      return matchesSearch && matchesUbicacion;
    }).toList();
  }

  Widget _buildDestinoCard(Destino destino) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del destino
          if (destino.imagenPath != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: Image.network(
                'http://192.168.0.105:8081${destino.imagenPath}',
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),

          // Contenido de la tarjeta
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        destino.nombre ?? 'Sin nombre',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editarDestino(destino),
                          tooltip: 'Editar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _mostrarDialogoEliminar(destino),
                          tooltip: 'Eliminar',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  destino.descripcion ?? 'Sin descripción',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        destino.ubicacion ?? 'Sin ubicación',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destinos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _reportService.generarReportePDF(context, _destinos),
            tooltip: 'Generar Reporte PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar Destinos',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),

          // Filtros de ubicación
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Todos'),
                  selected: _selectedUbicacion == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedUbicacion = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ..._ubicaciones.map((ubicacion) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(ubicacion),
                      selected: _selectedUbicacion == ubicacion,
                      onSelected: (selected) {
                        setState(() {
                          _selectedUbicacion = selected ? ubicacion : null;
                        });
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Lista de destinos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _cargarDestinos,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
                : _filteredDestinos.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay destinos registrados',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _cargarDestinos,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredDestinos.length,
                itemBuilder: (context, index) {
                  final destino = _filteredDestinos[index];
                  return _buildDestinoCard(destino);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarDestino,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
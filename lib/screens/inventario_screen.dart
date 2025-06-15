import 'package:flutter/material.dart';
import '../services/inventario_service.dart';
import '../services/destino_service.dart';
import '../models/inventario_model.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({Key? key}) : super(key: key);

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final InventarioService _inventarioService = InventarioService();
  final DestinoService _destinoService = DestinoService();
  List<Inventario> _inventario = [];
  List<dynamic> _destinos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final inventario = await _inventarioService.listarInventario();
      final destinos = await _destinoService.listarDestinos();

      setState(() {
        _inventario = inventario;
        _destinos = destinos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _obtenerNombreDestino(int? idDestino) {
    if (idDestino == null) return 'Sin destino';
    try {
      final destino = _destinos.firstWhere(
        (d) => d.idDestino == idDestino,
        orElse: () => null,
      );
      return destino?.nombre ?? 'Sin nombre';
    } catch (e) {
      return 'Sin destino';
    }
  }

  Future<void> _mostrarFormulario([Inventario? item]) async {
    final nombreController = TextEditingController(text: item?.nombreItem);
    final cantidadController = TextEditingController(
      text: item?.cantidadDisponible.toString(),
    );
    int? selectedDestinoId = item?.idDestino;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Agregar Item' : 'Editar Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Item',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cantidadController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad Disponible',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedDestinoId,
                decoration: const InputDecoration(
                  labelText: 'Destino',
                  border: OutlineInputBorder(),
                ),
                items: _destinos.map((destino) {
                  return DropdownMenuItem<int>(
                    value: destino.idDestino,
                    child: Text(destino.nombre ?? 'Sin nombre'),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedDestinoId = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nombreController.text.isEmpty ||
                  cantidadController.text.isEmpty ||
                  selectedDestinoId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor complete todos los campos'),
                  ),
                );
                return;
              }

              try {
                final inventario = Inventario(
                  idInventario: item?.idInventario,
                  nombreItem: nombreController.text,
                  cantidadDisponible: int.parse(cantidadController.text),
                  idDestino: selectedDestinoId,
                );

                if (item == null) {
                  await _inventarioService.guardarInventario(inventario);
                } else {
                  await _inventarioService.editarInventario(inventario);
                }

                if (mounted) {
                  Navigator.pop(context);
                  _cargarDatos();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        item == null
                            ? 'Item agregado exitosamente'
                            : 'Item actualizado exitosamente',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(item == null ? 'Agregar' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarItem(int id) async {
    try {
      await _inventarioService.eliminarInventario(id);
      _cargarDatos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item eliminado exitosamente'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Inventario'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarDatos,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _inventario.isEmpty
                  ? const Center(
                      child: Text('No hay items en el inventario'),
                    )
                  : ListView.builder(
                      itemCount: _inventario.length,
                      itemBuilder: (context, index) {
                        final item = _inventario[index];
                        final nombreDestino = _obtenerNombreDestino(item.idDestino);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(item.nombreItem ?? 'Sin nombre'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Cantidad: ${item.cantidadDisponible}'),
                                Text('Destino: $nombreDestino'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _mostrarFormulario(item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmar eliminación'),
                                      content: const Text(
                                        '¿Está seguro de eliminar este item?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _eliminarItem(item.idInventario!);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  ),
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
} 
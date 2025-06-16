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
      orElse: () => Destino(nombre: 'Sin destino'),
    );
    return destino.nombre ?? 'Sin destino';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Hospedajes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : ListView.builder(
                  itemCount: _hospedajes.length,
                  itemBuilder: (context, index) {
                    final hospedaje = _hospedajes[index];
                    return ListTile(
                      title: Text(hospedaje.nombre ?? 'Sin nombre'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Destino: ${_obtenerNombreDestino(hospedaje.idDestino)}'),
                          Text('Precio por noche: \$${hospedaje.precioPorNoche ?? 0}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _mostrarFormulario(hospedaje),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _eliminarHospedaje(hospedaje),
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
import 'package:flutter/material.dart';
import '../models/inventario_actividad_model.dart';
import '../services/inventario_actividad_service.dart';
import 'package:intl/intl.dart';

class InventarioActividadScreen extends StatefulWidget {
  const InventarioActividadScreen({super.key});

  @override
  State<InventarioActividadScreen> createState() => _InventarioActividadScreenState();
}

class _InventarioActividadScreenState extends State<InventarioActividadScreen> {
  final InventarioActividadService _service = InventarioActividadService();
  List<InventarioActividad> _inventarioActividades = [];
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

      final inventarioActividades = await _service.listarInventarioActividad();
      setState(() {
        _inventarioActividades = inventarioActividades;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _mostrarFormulario([InventarioActividad? inventarioActividad]) async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: inventarioActividad?.nombreActividad);
    final fechaController = TextEditingController(
      text: inventarioActividad?.fechaSesion != null
          ? DateFormat('yyyy-MM-dd').format(inventarioActividad!.fechaSesion!)
          : '',
    );
    final horaInicioController = TextEditingController(text: inventarioActividad?.horaInicio);
    final horaFinController = TextEditingController(text: inventarioActividad?.horaFin);
    final capacidadController = TextEditingController(
      text: inventarioActividad?.capacidadPersonas?.toString() ?? '',
    );
    final personasRegistradasController = TextEditingController(
      text: inventarioActividad?.personasRegistradas?.toString() ?? '',
    );
    final precioController = TextEditingController(
      text: inventarioActividad?.precioPorPersona?.toString() ?? '',
    );
    final descripcionController = TextEditingController(text: inventarioActividad?.descripcion);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(inventarioActividad == null ? 'Nueva Actividad' : 'Editar Actividad'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre de la Actividad'),
                  validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: fechaController,
                  decoration: const InputDecoration(labelText: 'Fecha (YYYY-MM-DD)'),
                  validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
                  onTap: () async {
                    final fecha = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (fecha != null) {
                      fechaController.text = DateFormat('yyyy-MM-dd').format(fecha);
                    }
                  },
                ),
                TextFormField(
                  controller: horaInicioController,
                  decoration: const InputDecoration(
                    labelText: 'Hora de Inicio (HH:mm)',
                    hintText: 'Ejemplo: 14:30',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Campo requerido';
                    if (!RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value!)) {
                      return 'Formato inválido. Use HH:mm (ejemplo: 14:30)';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: horaFinController,
                  decoration: const InputDecoration(
                    labelText: 'Hora de Fin (HH:mm)',
                    hintText: 'Ejemplo: 14:30',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Campo requerido';
                    if (!RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value!)) {
                      return 'Formato inválido. Use HH:mm (ejemplo: 14:30)';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: capacidadController,
                  decoration: const InputDecoration(labelText: 'Capacidad de Personas'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: personasRegistradasController,
                  decoration: const InputDecoration(labelText: 'Personas Registradas'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: precioController,
                  decoration: const InputDecoration(labelText: 'Precio por Persona'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
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
                  if (!RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(horaInicioController.text)) {
                    throw Exception('El formato de hora de inicio debe ser HH:mm (ejemplo: 14:30)');
                  }
                  if (!RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(horaFinController.text)) {
                    throw Exception('El formato de hora de fin debe ser HH:mm (ejemplo: 14:30)');
                  }

                  final horaInicio = horaInicioController.text.split(':');
                  final horaFin = horaFinController.text.split(':');
                  final inicioMinutos = int.parse(horaInicio[0]) * 60 + int.parse(horaInicio[1]);
                  final finMinutos = int.parse(horaFin[0]) * 60 + int.parse(horaFin[1]);
                  
                  if (finMinutos <= inicioMinutos) {
                    throw Exception('La hora de fin debe ser posterior a la hora de inicio');
                  }

                  final capacidad = int.tryParse(capacidadController.text) ?? 0;
                  final registradas = int.tryParse(personasRegistradasController.text) ?? 0;
                  if (registradas > capacidad) {
                    throw Exception('Las personas registradas no pueden exceder la capacidad');
                  }

                  final nuevaActividad = InventarioActividad(
                    idInventarioActividad: inventarioActividad?.idInventarioActividad ?? 0,
                    idActividad: inventarioActividad?.idActividad,
                    nombreActividad: nombreController.text,
                    fechaSesion: DateFormat('yyyy-MM-dd').parse(fechaController.text),
                    horaInicio: '${horaInicioController.text}:00',
                    horaFin: '${horaFinController.text}:00',
                    capacidadPersonas: capacidad,
                    personasRegistradas: registradas,
                    cantidadDisponible: capacidad - registradas,
                    precioPorPersona: double.tryParse(precioController.text) ?? 0.0,
                    descripcion: descripcionController.text,
                  );

                  print('Guardando actividad: ${nuevaActividad.toJson()}');

                  if (inventarioActividad == null) {
                    await _service.guardarInventarioActividad(nuevaActividad);
                  } else {
                    await _service.editarInventarioActividad(nuevaActividad);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    _cargarDatos();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(inventarioActividad == null 
                          ? 'Actividad guardada exitosamente' 
                          : 'Actividad actualizada exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  print('Error al guardar actividad: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: Text(inventarioActividad == null ? 'Guardar' : 'Actualizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarActividad(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de que desea eliminar esta actividad?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar ?? false) {
      try {
        await _service.eliminarInventarioActividad(id);
        _cargarDatos();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Inventario de Actividades'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarDatos,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _inventarioActividades.isEmpty
                  ? const Center(child: Text('No hay actividades registradas'))
                  : ListView.builder(
                      itemCount: _inventarioActividades.length,
                      itemBuilder: (context, index) {
                        final actividad = _inventarioActividades[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(actividad.nombreActividad ?? 'Sin nombre'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Fecha: ${DateFormat('dd/MM/yyyy').format(actividad.fechaSesion!)}'),
                                Text('Horario: ${actividad.horaInicio} - ${actividad.horaFin}'),
                                Text('Capacidad: ${actividad.capacidadPersonas} personas'),
                                Text('Registrados: ${actividad.personasRegistradas} personas'),
                                Text('Disponibles: ${actividad.cantidadDisponible} personas'),
                                Text('Precio: \$${actividad.precioPorPersona}'),
                                if (actividad.descripcion != null)
                                  Text('Descripción: ${actividad.descripcion}'),
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
                                  onPressed: () => _eliminarActividad(actividad.idInventarioActividad!),
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
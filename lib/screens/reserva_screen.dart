import 'package:flutter/material.dart';
import '../models/reserva_model.dart';
import 'package:intl/intl.dart';

class ReservaScreen extends StatefulWidget {
  const ReservaScreen({super.key});

  @override
  State<ReservaScreen> createState() => _ReservaScreenState();
}

class _ReservaScreenState extends State<ReservaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedEstado;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  
  // Lista de estados disponibles
  final List<String> _estadosReserva = ["Pendiente", "Confirmada", "Cancelada"];

  // Lista de reservas de prueba
  final List<Reserva> _reservas = [
    Reserva(
      idReserva: 1,
      nombreCliente: "Juan Pérez",
      estadoReserva: "Pendiente",
      fechaInicio: DateTime(2024, 3, 15),
      fechaFin: DateTime(2024, 3, 20),
      totalPago: 1500.0,
    ),
    Reserva(
      idReserva: 2,
      nombreCliente: "María García",
      estadoReserva: "Confirmada",
      fechaInicio: DateTime(2024, 4, 1),
      fechaFin: DateTime(2024, 4, 5),
      totalPago: 2000.0,
    ),
    Reserva(
      idReserva: 3,
      nombreCliente: "Carlos López",
      estadoReserva: "Cancelada",
      fechaInicio: DateTime(2024, 3, 10),
      fechaFin: DateTime(2024, 3, 15),
      totalPago: 1800.0,
    ),
  ];

  List<Reserva> get _filteredReservas {
    return _reservas.where((reserva) {
      final matchesSearch = reserva.nombreCliente?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      final matchesEstado = _selectedEstado == null || reserva.estadoReserva == _selectedEstado;
      final matchesFechaInicio = _fechaInicio == null || 
          (reserva.fechaInicio != null && reserva.fechaInicio!.isAfter(_fechaInicio!));
      final matchesFechaFin = _fechaFin == null || 
          (reserva.fechaFin != null && reserva.fechaFin!.isBefore(_fechaFin!));
      
      return matchesSearch && matchesEstado && matchesFechaInicio && matchesFechaFin;
    }).toList();
  }

  Color _obtenerColorEstado(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'confirmada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _seleccionarFechaInicio() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        _fechaInicio = picked;
      });
    }
  }

  Future<void> _seleccionarFechaFin() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        _fechaFin = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas'),
      ),
      body: Column(
        children: [
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por Cliente',
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
                // Filtro de estado
                DropdownButton<String>(
                  value: _selectedEstado,
                  hint: const Text('Estado'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Todos los estados'),
                    ),
                    ..._estadosReserva.map((estado) {
                      return DropdownMenuItem<String>(
                        value: estado,
                        child: Text(estado),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedEstado = value;
                    });
                  },
                ),
                const SizedBox(width: 16),

                // Filtro de fecha inicio
                ElevatedButton.icon(
                  onPressed: _seleccionarFechaInicio,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_fechaInicio != null 
                    ? DateFormat('dd/MM/yyyy').format(_fechaInicio!)
                    : 'Fecha Inicio'),
                ),
                const SizedBox(width: 8),

                // Filtro de fecha fin
                ElevatedButton.icon(
                  onPressed: _seleccionarFechaFin,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_fechaFin != null 
                    ? DateFormat('dd/MM/yyyy').format(_fechaFin!)
                    : 'Fecha Fin'),
                ),
              ],
            ),
          ),

          // Lista de reservas
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredReservas.length,
              itemBuilder: (context, index) {
                final reserva = _filteredReservas[index];
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
                                reserva.nombreCliente ?? 'Cliente sin nombre',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (reserva.estadoReserva != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _obtenerColorEstado(reserva.estadoReserva).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _obtenerColorEstado(reserva.estadoReserva),
                                  ),
                                ),
                                child: Text(
                                  reserva.estadoReserva!,
                                  style: TextStyle(
                                    color: _obtenerColorEstado(reserva.estadoReserva),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Inicio: ${DateFormat('dd/MM/yyyy').format(reserva.fechaInicio ?? DateTime.now())}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  'Fin: ${DateFormat('dd/MM/yyyy').format(reserva.fechaFin ?? DateTime.now())}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'S/. ${reserva.totalPago?.toStringAsFixed(2) ?? "0.00"}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
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
        onPressed: () {
          // TODO: Implementar la funcionalidad de agregar nueva reserva
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 
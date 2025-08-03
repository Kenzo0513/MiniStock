import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_stock/models/venta.dart';
import 'package:mini_stock/services/firestore_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _firestore = FirestoreService();
  late DateTime _fechaSeleccionada;
  List<Venta> _ventas = [];
  double _total = 0.0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _fechaSeleccionada = DateTime.now();
    _cargarVentas();
  }

  Future<void> _cargarVentas() async {
    setState(() => _cargando = true);
    final ventas = await _firestore.obtenerVentasDelDia(_fechaSeleccionada);
    final total = ventas.fold(0.0, (suma, v) => suma + v.total);
    setState(() {
      _ventas = ventas;
      _total = total;
      _cargando = false;
    });
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _fechaSeleccionada = picked);
      await _cargarVentas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte de Ventas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _seleccionarFecha,
              icon: const Icon(Icons.date_range),
              label: Text(
                'Fecha: ${DateFormat.yMd().format(_fechaSeleccionada)}',
              ),
            ),
            const SizedBox(height: 16),
            _cargando
                ? const CircularProgressIndicator()
                : Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Ventas del día: ${_ventas.length}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Total vendido: \$${_total.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _ventas.length,
                            itemBuilder: (context, index) {
                              final v = _ventas[index];
                              return ListTile(
                                title: Text(v.nombreProducto),
                                subtitle: Text(
                                  '${v.cantidadVendida} unidad(es) - \$${v.total.toStringAsFixed(2)}',
                                ),
                                trailing: Text(DateFormat.Hm().format(v.fecha)),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

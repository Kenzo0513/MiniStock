import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_stock/models/venta.dart';
import 'package:mini_stock/services/firestore_service.dart';

class DailyReportScreen extends StatelessWidget {
  const DailyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final hoy = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Informe Diario')),
      body: FutureBuilder<List<Venta>>(
        future: service.obtenerVentasDelDia(hoy),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('❌ Error al cargar ventas'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('📭 No hay ventas registradas hoy'),
            );
          }

          final ventas = snapshot.data!;
          final total = ventas.fold<double>(
            0,
            (suma, venta) => suma + venta.total,
          );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🗓️ ${DateFormat.yMMMMd().format(hoy)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  '💰 Total vendido: \$${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(height: 24),
                const Text(
                  '🛒 Detalle de ventas:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: ventas.length,
                    itemBuilder: (context, index) {
                      final v = ventas[index];
                      return ListTile(
                        title: Text(v.nombreProducto),
                        subtitle: Text(
                          'Cantidad: ${v.cantidadVendida} | Total: \$${v.total.toStringAsFixed(2)}',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

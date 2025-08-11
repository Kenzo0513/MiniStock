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
      appBar: AppBar(
        title: const Text('Informe Diario'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: FutureBuilder<List<Venta>>(
        future: service.obtenerVentasDelDia(hoy),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                '❌ Error al cargar ventas',
                style: TextStyle(color: Colors.red.shade700, fontSize: 18),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                '📭 No hay ventas registradas hoy',
                style: TextStyle(color: Colors.blue.shade700, fontSize: 18),
              ),
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '💰 Total vendido: \$${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                const Divider(height: 32, thickness: 2),
                const Text(
                  '🛒 Detalle de ventas:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: ventas.length,
                    itemBuilder: (context, index) {
                      final v = ventas[index];
                      return Card(
                        color: Colors.blue.shade50,
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            v.nombreProducto,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          subtitle: Text(
                            'Cantidad: ${v.cantidadVendida}  |  Total: \$${v.total.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.blue.shade700),
                          ),
                          leading: const Icon(Icons.shopping_cart, color: Colors.blue),
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

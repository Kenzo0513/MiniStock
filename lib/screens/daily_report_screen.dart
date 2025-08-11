import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_stock/models/venta.dart';
import 'package:mini_stock/services/firestore_service.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class DailyReportScreen extends StatelessWidget {
  const DailyReportScreen({super.key});

  Future<void> _exportarPDF(
    BuildContext context,
    List<Venta> ventas,
    double total,
  ) async {
    try {
      final pdf = pw.Document();
      final fecha = DateFormat('dd-MM-yyyy').format(DateTime.now());

      pdf.addPage(
        pw.Page(
          build: (pw.Context ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Reporte Diario - $fecha',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Total vendido: \$${total.toStringAsFixed(2)}'),
              pw.SizedBox(height: 20),
              pw.Text('Detalle de ventas:'),
              pw.SizedBox(height: 10),
              ...ventas.map(
                (v) => pw.Text(
                  '${v.nombreProducto} - Cantidad: ${v.cantidadVendida} | Total: \$${v.total.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/reporte_diario_$fecha.pdf';
      final file = File(path);

      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ PDF exportado en: $path'),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al exportar PDF: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

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
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _exportarPDF(context, ventas, total),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Exportar a PDF'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

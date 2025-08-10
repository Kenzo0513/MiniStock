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

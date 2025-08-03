import 'package:flutter/material.dart';
import 'add_product_screen.dart';
import 'inventory_screen.dart';
import 'sales_screen.dart';
import 'report_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MiniStock')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProductScreen()),
                );
              },
              child: const Text('Registrar Producto'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InventoryScreen()),
                );
              },
              child: const Text('Ver Inventario'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SalesScreen()),
                );
              },
              child: const Text('Registrar Venta'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportScreen()),
                );
              },
              child: const Text('Ver Reporte Diario'),
            ),
          ],
        ),
      ),
    );
  }
}

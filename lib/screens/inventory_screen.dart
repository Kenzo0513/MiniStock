import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_stock/models/producto.dart';
import 'package:mini_stock/services/firestore_service.dart';
import 'edit_product_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  final int _umbralBajoStock = 5;

  void _mostrarAlertaBajoStock(BuildContext context, List<Producto> productos) {
    final productosBajos =
        productos.where((p) => p.cantidad <= _umbralBajoStock).toList();

    if (productosBajos.isNotEmpty) {
      final nombres = productosBajos.map((p) => p.nombre).join(', ');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ Bajo stock: $nombres',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Inventario'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder(
        stream: firestoreService.obtenerProductosConMetadata(),
        builder: (
          context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.hasError) {
            return const Center(child: Text('❌ Error al cargar productos'));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('📭 No hay productos registrados'),
            );
          }

          final isOffline = snapshot.data!.metadata.isFromCache;
          final productos = snapshot.data!.docs
              .map((doc) => Producto.fromMap(doc.data()))
              .toList();

          _mostrarAlertaBajoStock(context, productos);

          return Column(
            children: [
              if (isOffline)
                Container(
                  width: double.infinity,
                  color: Colors.redAccent,
                  padding: const EdgeInsets.all(8),
                  child: const Text(
                    '📴 Modo offline: Mostrando datos en caché',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final p = productos[index];
                    final esBajoStock = p.cantidad <= _umbralBajoStock;

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: esBajoStock
                                ? Colors.orange.shade100
                                : Colors.blue.shade100,
                            child: Icon(
                              esBajoStock
                                  ? Icons.warning
                                  : Icons.inventory_2,
                              color: esBajoStock ? Colors.orange : Colors.blue,
                            ),
                          ),
                          title: Text(
                            p.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Código: ${p.codigoBarras}'),
                              Text(
                                  '💲 ${p.precio.toStringAsFixed(2)} | 🛒 ${p.cantidad} unidades'),
                              Text(
                                '📅 Caduca: ${DateFormat.yMd().format(p.caducidad)}',
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.edit, color: Colors.grey),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditProductScreen(producto: p),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

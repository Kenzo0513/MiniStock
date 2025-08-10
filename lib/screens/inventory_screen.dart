import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_stock/models/producto.dart';
import 'package:mini_stock/services/firestore_service.dart';
import 'edit_product_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final int _umbralBajoStock = 5; // ⚠️ Umbral de alerta
  String _filtroBusqueda = "";

  // Mostrar alerta de bajo stock
  void _mostrarAlertaBajoStock(BuildContext context, List<Producto> productos) {
    final productosBajos = productos
        .where((p) => p.cantidad <= _umbralBajoStock)
        .toList();

    if (productosBajos.isNotEmpty) {
      final nombres = productosBajos.map((p) => p.nombre).join(', ');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ Productos con bajo stock: $nombres',
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
        title: const Text('Inventario'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (valor) {
                setState(() {
                  _filtroBusqueda = valor.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: firestoreService.obtenerProductosConMetadata(),
        builder:
            (
              context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
            ) {
              if (snapshot.hasError) {
                return const Center(child: Text('Error al cargar productos'));
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No hay productos registrados'),
                );
              }

              // Detectar si los datos vienen de caché (modo offline)
              final isOffline = snapshot.data!.metadata.isFromCache;

              // Convertir a lista de productos y aplicar filtro
              final productos = snapshot.data!.docs
                  .map((doc) => Producto.fromMap(doc.data()))
                  .where(
                    (p) =>
                        p.nombre.toLowerCase().contains(_filtroBusqueda) ||
                        p.codigoBarras.toLowerCase().contains(_filtroBusqueda),
                  )
                  .toList();

              // Alerta de bajo stock
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
                    child: productos.isEmpty
                        ? const Center(
                            child: Text('No se encontraron productos'),
                          )
                        : ListView.builder(
                            itemCount: productos.length,
                            itemBuilder: (context, index) {
                              final p = productos[index];
                              final esBajoStock =
                                  p.cantidad <= _umbralBajoStock;

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  leading: esBajoStock
                                      ? const Icon(
                                          Icons.warning,
                                          color: Colors.orange,
                                        )
                                      : const Icon(
                                          Icons.inventory_2,
                                          color: Colors.blue,
                                        ),
                                  title: Text(p.nombre),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Código: ${p.codigoBarras}'),
                                      Text(
                                        'Precio: \$${p.precio.toStringAsFixed(2)}',
                                      ),
                                      Text('Cantidad: ${p.cantidad}'),
                                      Text(
                                        'Caducidad: ${DateFormat.yMd().format(p.caducidad)}',
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.edit),
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

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
                return const Center(child: Text('❌ Error al cargar productos'));
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('📭 No hay productos registrados'),
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

                              return GestureDetector(
                                onTapDown:
                                    (
                                      _,
                                    ) {}, // Aquí se podría agregar animación al presionar
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditProductScreen(producto: p),
                                    ),
                                  );
                                },
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: esBajoStock
                                            ? Colors.orange.shade300
                                            : Colors.blue.shade200,
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          esBajoStock
                                              ? Icons.warning
                                              : Icons.inventory_2,
                                          color: esBajoStock
                                              ? Colors.orange
                                              : Colors.blue,
                                          size: 32,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p.nombre,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.qr_code,
                                                    size: 16,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(p.codigoBarras),
                                                ],
                                              ),

                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.shopping_cart,
                                                    size: 16,
                                                    color: Colors.blue,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${p.cantidad} unidades',
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.calendar_today,
                                                    size: 16,
                                                    color: Colors.red,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    DateFormat.yMd().format(
                                                      p.caducidad,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.edit,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
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

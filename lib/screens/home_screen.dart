import 'package:flutter/material.dart';
import 'add_product_screen.dart';
import 'inventory_screen.dart';
import 'sales_screen.dart';
import 'daily_report_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildAnimatedButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required Widget page,
  }) {
    return GestureDetector(
      onTapDown: (_) {
        // Se podría agregar vibración o efecto haptics aquí si se desea
      },
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, scale, child) {
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => page),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: color),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Logo central
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white,
              child: Icon(Icons.inventory_2, size: 50, color: Colors.blue),
            ),

            const SizedBox(height: 16),

            // Título y subtítulo
            const Text(
              'MiniStock',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Latacunga, Ecuador',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // Botones en cuadrícula 2x2
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildAnimatedButton(
                      context: context,
                      icon: Icons.add_box,
                      title: 'Registrar\nProducto',
                      color: Colors.green,
                      page: const AddProductScreen(),
                    ),
                    _buildAnimatedButton(
                      context: context,
                      icon: Icons.inventory_2,
                      title: 'Ver\nInventario',
                      color: Colors.blue,
                      page: const InventoryScreen(),
                    ),
                    _buildAnimatedButton(
                      context: context,
                      icon: Icons.point_of_sale,
                      title: 'Registrar\nVenta',
                      color: Colors.orange,
                      page: const SalesScreen(),
                    ),
                    _buildAnimatedButton(
                      context: context,
                      icon: Icons.bar_chart,
                      title: 'Reporte\nDiario',
                      color: Colors.purple,
                      page: const DailyReportScreen(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

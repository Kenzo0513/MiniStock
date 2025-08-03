class Venta {
  final String id;
  final String productoId;
  final String nombreProducto;
  final int cantidadVendida;
  final double total;
  final DateTime fecha;

  Venta({
    required this.id,
    required this.productoId,
    required this.nombreProducto,
    required this.cantidadVendida,
    required this.total,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productoId': productoId,
      'nombreProducto': nombreProducto,
      'cantidadVendida': cantidadVendida,
      'total': total,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory Venta.fromMap(Map<String, dynamic> map) {
    return Venta(
      id: map['id'],
      productoId: map['productoId'],
      nombreProducto: map['nombreProducto'],
      cantidadVendida: map['cantidadVendida'],
      total: map['total'].toDouble(),
      fecha: DateTime.parse(map['fecha']),
    );
  }
}

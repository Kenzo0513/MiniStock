class Producto {
  final String id;
  final String codigoBarras;
  final String nombre;
  final double precio;
  final int cantidad;
  final DateTime caducidad;

  Producto({
    required this.id,
    required this.codigoBarras,
    required this.nombre,
    required this.precio,
    required this.cantidad,
    required this.caducidad,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'codigoBarras': codigoBarras,
    'nombre': nombre,
    'precio': precio,
    'cantidad': cantidad,
    'caducidad': caducidad.toIso8601String(),
  };

  factory Producto.fromMap(Map<String, dynamic> map) => Producto(
    id: map['id'],
    codigoBarras: map['codigoBarras'],
    nombre: map['nombre'],
    precio: (map['precio'] as num).toDouble(),
    cantidad: map['cantidad'],
    caducidad: DateTime.parse(map['caducidad']),
  );
}

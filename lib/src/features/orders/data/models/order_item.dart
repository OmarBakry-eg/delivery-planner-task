
class OrderItem {
  final String sku;
  final String name;
  final int quantity;
  final double weight;
  final double volume;
  final bool serialTracked;
  final List<String> serialNumbers;

  const OrderItem({
    required this.sku,
    required this.name,
    required this.quantity,
    required this.weight,
    required this.volume,
    required this.serialTracked,
    this.serialNumbers = const [],
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    sku: json['sku'] as String,
    name: json['name'] as String,
    quantity: json['quantity'] as int,
    weight: (json['weight'] as num).toDouble(),
    volume: (json['volume'] as num).toDouble(),
    serialTracked: json['serialTracked'] as bool,
    serialNumbers: json['serialNumbers'] != null
        ? List<String>.from(json['serialNumbers'])
        : [],
  );

  Map<String, dynamic> toJson() => {
    'sku': sku,
    'name': name,
    'quantity': quantity,
    'weight': weight,
    'volume': volume,
    'serialTracked': serialTracked,
    'serialNumbers': serialNumbers,
  };

  OrderItem copyWith({
    String? sku,
    String? name,
    int? quantity,
    double? weight,
    double? volume,
    bool? serialTracked,
    List<String>? serialNumbers,
  }) => OrderItem(
    sku: sku ?? this.sku,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    weight: weight ?? this.weight,
    volume: volume ?? this.volume,
    serialTracked: serialTracked ?? this.serialTracked,
    serialNumbers: serialNumbers ?? this.serialNumbers,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItem &&
          runtimeType == other.runtimeType &&
          sku == other.sku &&
          name == other.name &&
          quantity == other.quantity &&
          weight == other.weight &&
          volume == other.volume &&
          serialTracked == other.serialTracked;

  @override
  int get hashCode => sku.hashCode ^ name.hashCode ^ quantity.hashCode;
}



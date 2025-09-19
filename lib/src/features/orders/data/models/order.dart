
import 'package:test_hsa_group/src/features/orders/data/models/order_item.dart';

class Order {
  final String id;
  final String customerId;
  final double codAmount;
  final bool isDiscounted;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.customerId,
    required this.codAmount,
    required this.isDiscounted,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    customerId: json['customerId'] as String,
    codAmount: (json['codAmount'] as num).toDouble(),
    isDiscounted: json['isDiscounted'] as bool,
    items: (json['items'] as List)
        .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'codAmount': codAmount,
    'isDiscounted': isDiscounted,
    'items': items.map((item) => item.toJson()).toList(),
  };

  double get totalWeight =>
      items.fold(0.0, (sum, item) => sum + (item.weight * item.quantity));
  double get totalVolume =>
      items.fold(0.0, (sum, item) => sum + (item.volume * item.quantity));

  Order copyWith({
    String? id,
    String? customerId,
    double? codAmount,
    bool? isDiscounted,
    List<OrderItem>? items,
  }) => Order(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    codAmount: codAmount ?? this.codAmount,
    isDiscounted: isDiscounted ?? this.isDiscounted,
    items: items ?? this.items,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          customerId == other.customerId &&
          codAmount == other.codAmount &&
          isDiscounted == other.isDiscounted;

  @override
  int get hashCode =>
      id.hashCode ^
      customerId.hashCode ^
      codAmount.hashCode ^
      isDiscounted.hashCode;
}




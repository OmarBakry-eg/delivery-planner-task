import 'package:collection/collection.dart';
import 'package:test_hsa_group/src/features/orders/data/models/order.dart';
import 'package:test_hsa_group/src/features/trip_execution/data/models/delivery.dart';

class Trip {
  final String id;
  final String vehicleId;
  final List<DeliveryStop> stops;
  final DateTime createdAt;

  const Trip({
    required this.id,
    required this.vehicleId,
    required this.stops,
    required this.createdAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json['id'] as String,
    vehicleId: json['vehicleId'] as String,
    stops: (json['stops'] as List)
        .map((stop) => DeliveryStop.fromJson(stop as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicleId': vehicleId,
    'stops': stops.map((stop) => stop.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  bool get isCompleted =>
      stops.isNotEmpty &&
      // A trip is considered finished when there are no pending or in-transit stops.
      // This treats failed stops as finalized as well.
      stops.every(
        (s) =>
            s.status != DeliveryStatus.pending &&
            s.status != DeliveryStatus.inTransit,
      );

  double getTotalCod(List<Order?> orders) {
    return stops.fold(0.0, (total, stop) {
      final order = orders.firstWhereOrNull((o) => o?.id == stop.orderId);
      return total + (order?.codAmount ?? 0.0);
    });
  }

  double getTotalWeight(List<Order?> orders) {
    return stops.fold(0.0, (total, stop) {
      final order = orders.firstWhereOrNull((o) => o?.id == stop.orderId);
      return total + (order?.totalWeight ?? 0.0);
    });
  }

  double getTotalVolume(List<Order?> orders) {
    return stops.fold(0.0, (total, stop) {
      final order = orders.firstWhereOrNull((o) => o?.id == stop.orderId);
      return total + (order?.totalVolume ?? 0.0);
    });
  }

  Trip copyWith({
    String? id,
    String? vehicleId,
    List<DeliveryStop>? stops,
    DateTime? createdAt,
  }) => Trip(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    stops: stops ?? this.stops,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Trip &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          vehicleId == other.vehicleId;

  @override
  int get hashCode => id.hashCode ^ vehicleId.hashCode;
}

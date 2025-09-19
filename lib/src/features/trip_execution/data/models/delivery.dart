
import 'package:test_hsa_group/src/core/shared/location.dart' show Location;

enum DeliveryStatus {
  pending,
  inTransit,
  completed,
  failed;

  bool canTransitionTo(DeliveryStatus newStatus) {
    switch (this) {
      case DeliveryStatus.pending:
        return newStatus == DeliveryStatus.inTransit ||
            newStatus == DeliveryStatus.failed;
      case DeliveryStatus.inTransit:
        return newStatus == DeliveryStatus.completed ||
            newStatus == DeliveryStatus.failed;
      case DeliveryStatus.completed:
      case DeliveryStatus.failed:
        return false;
    }
  }
}

class DeliveryStop {
  final String orderId;
  final Location location;
  final DeliveryStatus status;
  final double? collectedCod;
  final List<String> failureReasons;
  final DateTime? completedAt;

  const DeliveryStop({
    required this.orderId,
    required this.location,
    this.status = DeliveryStatus.pending,
    this.collectedCod,
    this.failureReasons = const [],
    this.completedAt,
  });

  factory DeliveryStop.fromJson(Map<String, dynamic> json) => DeliveryStop(
    orderId: json['orderId'] as String,
    location: Location.fromJson(json['location'] as Map<String, dynamic>),
    status: DeliveryStatus.values.byName(
      json['status'] as String? ?? 'pending',
    ),
    collectedCod: json['collectedCod'] != null
        ? (json['collectedCod'] as num).toDouble()
        : null,
    failureReasons: json['failureReasons'] != null
        ? List<String>.from(json['failureReasons'])
        : [],
    completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'location': location.toJson(),
    'status': status.name,
    'collectedCod': collectedCod,
    'failureReasons': failureReasons,
    'completedAt': completedAt?.toIso8601String(),
  };

  DeliveryStop copyWith({
    String? orderId,
    Location? location,
    DeliveryStatus? status,
    double? collectedCod,
    List<String>? failureReasons,
    DateTime? completedAt,
  }) => DeliveryStop(
    orderId: orderId ?? this.orderId,
    location: location ?? this.location,
    status: status ?? this.status,
    collectedCod: collectedCod ?? this.collectedCod,
    failureReasons: failureReasons ?? this.failureReasons,
    completedAt: completedAt ?? this.completedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryStop &&
          runtimeType == other.runtimeType &&
          orderId == other.orderId &&
          location == other.location &&
          status == other.status;

  @override
  int get hashCode => orderId.hashCode ^ location.hashCode ^ status.hashCode;
}

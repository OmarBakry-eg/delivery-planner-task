
import 'package:test_hsa_group/src/core/shared/location.dart';

class Customer {
  final String id;
  final String name;
  final Location location;

  const Customer({
    required this.id,
    required this.name,
    required this.location,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json['id'] as String,
    name: json['name'] as String,
    location: Location.fromJson(json['location'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          location == other.location;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ location.hashCode;
}



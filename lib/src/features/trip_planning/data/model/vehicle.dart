
class VehicleCapacity {
  final double weight;
  final double volume;

  const VehicleCapacity({required this.weight, required this.volume});

  factory VehicleCapacity.fromJson(Map<String, dynamic> json) =>
      VehicleCapacity(
        weight: (json['weight'] as num).toDouble(),
        volume: (json['volume'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {'weight': weight, 'volume': volume};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleCapacity &&
          runtimeType == other.runtimeType &&
          weight == other.weight &&
          volume == other.volume;

  @override
  int get hashCode => weight.hashCode ^ volume.hashCode;
}

class Vehicle {
  final String id;
  final String name;
  final VehicleCapacity capacity;
  final double fillRate;

  const Vehicle({
    required this.id,
    required this.name,
    required this.capacity,
    required this.fillRate,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: json['id'] as String,
    name: json['name'] as String,
    capacity: VehicleCapacity.fromJson(
      json['capacity'] as Map<String, dynamic>,
    ),
    fillRate: (json['fillRate'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'capacity': capacity.toJson(),
    'fillRate': fillRate,
  };

  double get effectiveWeightCapacity => capacity.weight * fillRate;
  double get effectiveVolumeCapacity => capacity.volume * fillRate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vehicle &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          capacity == other.capacity &&
          fillRate == other.fillRate;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ capacity.hashCode ^ fillRate.hashCode;
}




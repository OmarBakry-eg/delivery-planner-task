import 'package:equatable/equatable.dart';
import 'package:test_hsa_group/src/features/orders/data/models/customer.dart';
import 'package:test_hsa_group/src/features/orders/data/models/order.dart';
import 'package:test_hsa_group/src/features/trip_execution/data/models/trip.dart';
import 'package:test_hsa_group/src/features/trip_planning/data/model/vehicle.dart';

abstract class TripPlanningState extends Equatable {
  const TripPlanningState();
}

class TripPlanningInitial extends TripPlanningState {
  @override
  List<Object> get props => [];
}

class TripPlanningLoading extends TripPlanningState {
  @override
  List<Object> get props => [];
}

class TripPlanningLoaded extends TripPlanningState {
  final List<Order> availableOrders;
  final List<Customer> customers;
  final List<Vehicle> vehicles;
  final List<Trip> trips;
  final DateTime planDate;
  final String depotTimezone;
  final String? selectedOrderFilter;
  final String? selectedVehicleId;
  final List<String> selectedOrderIds;

  const TripPlanningLoaded({
    required this.availableOrders,
    required this.customers,
    required this.vehicles,
    required this.trips,
    required this.planDate,
    required this.depotTimezone,
    this.selectedOrderFilter,
    this.selectedVehicleId,
    this.selectedOrderIds = const [],
  });

  // Include a signature of trip stop statuses to ensure state equality changes
  // when a trip's progress changes (e.g., stops completed/failed).
  String get tripsStatusSignature => trips
      .map(
        (t) =>
            '${t.id}:${t.stops.map((s) => '${s.orderId}:${s.status.index}:${s.completedAt?.millisecondsSinceEpoch ?? 0}').join('|')}',
      )
      .join('#');

  TripPlanningLoaded copyWith({
    List<Order>? availableOrders,
    List<Customer>? customers,
    List<Vehicle>? vehicles,
    List<Trip>? trips,
    DateTime? planDate,
    String? depotTimezone,
    String? selectedOrderFilter,
    String? selectedVehicleId,
    List<String>? selectedOrderIds,
  }) => TripPlanningLoaded(
    availableOrders: availableOrders ?? this.availableOrders,
    customers: customers ?? this.customers,
    vehicles: vehicles ?? this.vehicles,
    trips: trips ?? this.trips,
    planDate: planDate ?? this.planDate,
    depotTimezone: depotTimezone ?? this.depotTimezone,
    selectedOrderFilter: selectedOrderFilter ?? this.selectedOrderFilter,
    selectedVehicleId: selectedVehicleId ?? this.selectedVehicleId,
    selectedOrderIds: selectedOrderIds ?? this.selectedOrderIds,
  );

  List<Order> get filteredOrders {
    if (selectedOrderFilter == null || selectedOrderFilter!.isEmpty) {
      return availableOrders;
    }
    return availableOrders.where((order) {
      final customer = customers.firstWhere((c) => c.id == order.customerId);
      final q = selectedOrderFilter!.toLowerCase();
      return customer.name.toLowerCase().contains(q) ||
          order.id.toLowerCase().contains(q);
    }).toList();
  }

  @override
  List<Object?> get props => [
    availableOrders,
    customers,
    vehicles,
    trips,
    planDate,
    depotTimezone,
    // Add status signature so Bloc emits when trip stop statuses change
    tripsStatusSignature,
    selectedOrderFilter,
    selectedVehicleId,
    selectedOrderIds,
  ];
}

class TripPlanningError extends TripPlanningState {
  final String message;

  const TripPlanningError(this.message);

  @override
  List<Object> get props => [message];
}

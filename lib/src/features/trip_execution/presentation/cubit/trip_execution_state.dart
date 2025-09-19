import 'package:equatable/equatable.dart';
import 'package:test_hsa_group/src/features/orders/data/models/customer.dart';
import 'package:test_hsa_group/src/features/orders/data/models/order.dart';
import 'package:test_hsa_group/src/features/trip_execution/data/models/trip.dart';
import 'package:test_hsa_group/src/features/trip_execution/data/models/delivery.dart';


abstract class TripExecutionState extends Equatable {
  const TripExecutionState();
}

class TripExecutionInitial extends TripExecutionState {
  @override
  List<Object> get props => [];
}

class TripExecutionLoading extends TripExecutionState {
  @override
  List<Object> get props => [];
}

class TripExecutionLoaded extends TripExecutionState {
  final Trip trip;
  final List<Order> orders;
  final List<Customer> customers;
  final int currentStopIndex;

  const TripExecutionLoaded({
    required this.trip,
    required this.orders,
    required this.customers,
    this.currentStopIndex = 0,
  });

  TripExecutionLoaded copyWith({
    Trip? trip,
    List<Order>? orders,
    List<Customer>? customers,
    int? currentStopIndex,
  }) => TripExecutionLoaded(
    trip: trip ?? this.trip,
    orders: orders ?? this.orders,
    customers: customers ?? this.customers,
    currentStopIndex: currentStopIndex ?? this.currentStopIndex,
  );

  DeliveryStop get currentStop => trip.stops[currentStopIndex];

  Order getCurrentOrder() =>
      orders.firstWhere((o) => o.id == currentStop.orderId);

  Customer getCurrentCustomer() {
    final order = getCurrentOrder();
    return customers.firstWhere((c) => c.id == order.customerId);
  }

  bool get hasNextStop => currentStopIndex < trip.stops.length - 1;
  bool get hasPreviousStop => currentStopIndex > 0;

  @override
  List<Object?> get props => [trip, orders, customers, currentStopIndex];
}

class TripExecutionError extends TripExecutionState {
  final String message;

  const TripExecutionError(this.message);

  @override
  List<Object> get props => [message];
}

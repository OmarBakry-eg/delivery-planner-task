import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hsa_group/src/features/orders/data/models/customer.dart';
import 'package:test_hsa_group/src/features/orders/data/models/order.dart';
import 'package:test_hsa_group/src/features/trip_execution/data/models/delivery.dart';
import 'package:test_hsa_group/src/features/trip_execution/data/models/trip.dart';
import 'package:test_hsa_group/src/features/trip_planning/data/model/vehicle.dart';
import 'package:test_hsa_group/src/features/trip_planning/data/repo/trip_repo.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/cubit/trip_planning_state.dart';

class TripPlanningCubit extends Cubit<TripPlanningState> {
  final TripPlanningRepository _repository;

  TripPlanningCubit(this._repository) : super(TripPlanningInitial()) {
    // Subscribe immediately so TripExecution updates reflect in planning UI
    _repoSub = _repository.changes.listen((data) {
      final availableOrders = _repository.getAvailableOrders();
      final current = state;
      if (current is TripPlanningLoaded) {
        final preservedVehicleId = current.selectedVehicleId;
        final preservedOrderIds = current.selectedOrderIds
            .where((id) => availableOrders.any((o) => o.id == id))
            .toList();
        emit(
          TripPlanningLoaded(
            availableOrders: availableOrders,
            customers: data.customers,
            vehicles: data.vehicles,
            trips: data.trips,
            planDate: data.planDate,
            depotTimezone: data.depotTimezone,
            selectedOrderFilter: current.selectedOrderFilter,
            selectedVehicleId: preservedVehicleId,
            selectedOrderIds: preservedOrderIds,
          ),
        );
      } else {
        emit(
          TripPlanningLoaded(
            availableOrders: availableOrders,
            customers: data.customers,
            vehicles: data.vehicles,
            trips: data.trips,
            planDate: data.planDate,
            depotTimezone: data.depotTimezone,
          ),
        );
      }
    });
  }

  StreamSubscription? _repoSub;

  @override
  Future<void> close() {
    _repoSub?.cancel();
    return super.close();
  }

  Future<void> loadData() async {
    try {
      emit(TripPlanningLoading());

      final appData = await _repository.loadData();
      // Subscribe once to propagate live updates from execution
      _repoSub ??= _repository.changes.listen((data) {
        final availableOrders = _repository.getAvailableOrders();
        final current = state;
        if (current is TripPlanningLoaded) {
          // Keep selections but drop ones no longer available
          final preservedVehicleId = current.selectedVehicleId;
          final preservedOrderIds = current.selectedOrderIds
              .where((id) => availableOrders.any((o) => o.id == id))
              .toList();
          emit(
            TripPlanningLoaded(
              availableOrders: availableOrders,
              customers: data.customers,
              vehicles: data.vehicles,
              trips: data.trips,
              planDate: data.planDate,
              depotTimezone: data.depotTimezone,
              selectedOrderFilter: current.selectedOrderFilter,
              selectedVehicleId: preservedVehicleId,
              selectedOrderIds: preservedOrderIds,
            ),
          );
        } else {
          emit(
            TripPlanningLoaded(
              availableOrders: availableOrders,
              customers: data.customers,
              vehicles: data.vehicles,
              trips: data.trips,
              planDate: data.planDate,
              depotTimezone: data.depotTimezone,
            ),
          );
        }
      });
      final availableOrders = _repository.getAvailableOrders();
      emit(
        TripPlanningLoaded(
          availableOrders: availableOrders,
          customers: appData.customers,
          vehicles: appData.vehicles,
          trips: appData.trips,
          planDate: appData.planDate,
          depotTimezone: appData.depotTimezone,
        ),
      );
    } catch (e) {
      emit(TripPlanningError('Failed to load data: $e'));
    }
  }

  void filterOrders(String? filter) {
    final currentState = state;
    if (currentState is TripPlanningLoaded) {
      final normalized = (filter ?? '').trim();
      emit(
        currentState.copyWith(
          selectedOrderFilter: normalized.isEmpty ? '' : normalized,
        ),
      );
    }
  }

  Future<String> createTrip(String vehicleId, List<String> orderIds) async {
    try {
      final currentState = state;
      if (currentState is! TripPlanningLoaded) return 'Invalid state';

      final vehicle = currentState.vehicles.firstWhere(
        (v) => v.id == vehicleId,
      );
      final orders = orderIds
          .map(
            (id) => currentState.availableOrders.firstWhere((o) => o.id == id),
          )
          .toList();

      // Validate capacity
      final totalWeight = orders.fold(
        0.0,
        (sum, order) => sum + order.totalWeight,
      );
      final totalVolume = orders.fold(
        0.0,
        (sum, order) => sum + order.totalVolume,
      );

      if (totalWeight > vehicle.effectiveWeightCapacity) {
        return 'Total weight (${totalWeight.toStringAsFixed(1)} kg) exceeds vehicle capacity (${vehicle.effectiveWeightCapacity.toStringAsFixed(1)} kg)';
      }

      if (totalVolume > vehicle.effectiveVolumeCapacity) {
        return 'Total volume (${totalVolume.toStringAsFixed(2)} m³) exceeds vehicle capacity (${vehicle.effectiveVolumeCapacity.toStringAsFixed(2)} m³)';
      }

      // Check serial number requirements
      for (final order in orders) {
        for (final item in order.items) {
          if (item.serialTracked &&
              item.quantity > 1 &&
              item.serialNumbers.length != item.quantity) {
            return 'Order ${order.id}: ${item.name} requires ${item.quantity} unique serial numbers';
          }
        }
      }

      final stops = orderIds.map((orderId) {
        final customer = _repository.getCustomerById(
          currentState.availableOrders
              .firstWhere((o) => o.id == orderId)
              .customerId,
        );
        return DeliveryStop(orderId: orderId, location: customer.location);
      }).toList();

      final trip = Trip(
        id: 'TRIP-${DateTime.now().millisecondsSinceEpoch}',
        vehicleId: vehicleId,
        stops: stops,
        createdAt: DateTime.now(),
      );

      await _repository.saveTrip(trip);
      return 'Success';
    } catch (e) {
      return 'Failed to create trip: $e';
    }
  }

  Future<String> deleteTrip(String tripId) async {
    try {
      await _repository.deleteTrip(tripId);
      return 'Success';
    } catch (e) {
      return 'Failed to delete trip: $e';
    }
  }

  Customer getCustomerForOrder(String orderId) {
    final currentState = state;
    if (currentState is! TripPlanningLoaded) throw Exception('Invalid state');

    final order = currentState.availableOrders.firstWhere(
      (o) => o.id == orderId,
    );
    return currentState.customers.firstWhere((c) => c.id == order.customerId);
  }

  Vehicle getVehicleById(String vehicleId) {
    final currentState = state;
    if (currentState is! TripPlanningLoaded) throw Exception('Invalid state');

    return currentState.vehicles.firstWhere((v) => v.id == vehicleId);
  }

  Order? getOrderById(String orderId) {
    final currentState = state;
    if (currentState is! TripPlanningLoaded) throw Exception('Invalid state');

    return currentState.availableOrders.firstWhereOrNull(
      (o) => o.id == orderId,
    );
  }

  double calculateWeightUtilization(String vehicleId, List<String> orderIds) {
    final currentState = state;
    if (currentState is! TripPlanningLoaded) return 0.0;

    final vehicle = currentState.vehicles.firstWhere((v) => v.id == vehicleId);
    final totalWeight = orderIds.fold(0.0, (sum, orderId) {
      final order = currentState.availableOrders.firstWhere(
        (o) => o.id == orderId,
      );
      return sum + order.totalWeight;
    });

    return totalWeight / vehicle.effectiveWeightCapacity;
  }

  double calculateVolumeUtilization(String vehicleId, List<String> orderIds) {
    final currentState = state;
    if (currentState is! TripPlanningLoaded) return 0.0;

    final vehicle = currentState.vehicles.firstWhere((v) => v.id == vehicleId);
    final totalVolume = orderIds.fold(0.0, (sum, orderId) {
      final order = currentState.availableOrders.firstWhere(
        (o) => o.id == orderId,
      );
      return sum + order.totalVolume;
    });

    return totalVolume / vehicle.effectiveVolumeCapacity;
  }

  double calculateTotalCod(List<String> orderIds) {
    final currentState = state;
    if (currentState is! TripPlanningLoaded) return 0.0;

    return orderIds.fold(0.0, (sum, orderId) {
      final order = currentState.availableOrders.firstWhere(
        (o) => o.id == orderId,
      );
      return sum + order.codAmount;
    });
  }

  // UI selection state previously handled by setState in TripBuilder
  void selectVehicle(String? vehicleId) {
    final current = state;
    if (current is! TripPlanningLoaded) return;
    emit(
      current.copyWith(
        selectedVehicleId: vehicleId,
        selectedOrderIds: current.selectedOrderIds,
      ),
    );
  }

  void toggleOrderSelection(String orderId, bool selected) {
    final current = state;
    if (current is! TripPlanningLoaded) return;
    final updated = [...current.selectedOrderIds];
    if (selected) {
      if (!updated.contains(orderId)) updated.add(orderId);
    } else {
      updated.remove(orderId);
    }
    emit(current.copyWith(selectedOrderIds: updated));
  }

  void resetSelections(String selectedVehicleId) {
    final current = state;
    if (current is! TripPlanningLoaded) return;
    emit(
      current.copyWith(
        selectedVehicleId: selectedVehicleId,
        selectedOrderIds: const [],
      ),
    );
  }
}

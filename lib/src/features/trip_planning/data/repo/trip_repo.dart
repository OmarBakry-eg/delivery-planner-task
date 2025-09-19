import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:test_hsa_group/src/core/config/app_config.dart';
import 'package:test_hsa_group/src/features/orders/data/models/customer.dart';
import 'package:test_hsa_group/src/features/orders/data/models/order.dart';
import 'package:test_hsa_group/src/features/trip_execution/domain/entities/trip.dart';
import 'package:test_hsa_group/src/features/trip_planning/data/model/vehicle.dart';

class AppData2 {
  final DateTime planDate;
  final String depotTimezone;
  final LatLng depot;
  final List<Vehicle> vehicles;
  final List<Order> orders;
  final List<Customer> customers;
  final List<Trip> trips;

  const AppData2({
    required this.planDate,
    required this.depotTimezone,
    required this.depot,
    required this.vehicles,
    required this.orders,
    required this.customers,
    this.trips = const [],
  });

  AppData2 copyWith({
    DateTime? planDate,
    String? depotTimezone,
    LatLng? depot,
    List<Vehicle>? vehicles,
    List<Order>? orders,
    List<Customer>? customers,
    List<Trip>? trips,
  }) => AppData2(
    planDate: planDate ?? this.planDate,
    depotTimezone: depotTimezone ?? this.depotTimezone,
    depot: depot ?? this.depot,
    vehicles: vehicles ?? this.vehicles,
    orders: orders ?? this.orders,
    customers: customers ?? this.customers,
    trips: trips ?? this.trips,
  );
}

class TripRepository {
  static const String _boxName = 'routeweaver_data';
  static const String _dataKey = 'app_data';
  late Box _box;
  AppData2? _cachedData;
  final StreamController<AppData2> _changeController =
      StreamController<AppData2>.broadcast();

  Stream<AppData2> get changes => _changeController.stream;

  Future<void> initialize() async {
    await AppConfig.initialize();
    _box = await Hive.openBox(_boxName);
  }

  Future<AppData2> loadData() async {
    if (_cachedData != null) return _cachedData!;

    // Try to load from Hive first
    final savedData = _box.get(_dataKey);
    try {
      if (savedData != null) {
        final Map<String, dynamic> savedDataString = Map<String, dynamic>.from(
          savedData as Map<dynamic, dynamic>,
        );
        _cachedData = _parseAppDataFromJson(savedDataString);
        return _cachedData!;
      }
    } catch (e) {
      //
    }

    // Load from assets if no saved data
    final String jsonString = await rootBundle.loadString(
      'assets/sample_data.json',
    );
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    _cachedData = _parseAppDataFromJson(jsonData);
    _cachedData = _applyEnvDatasetSizing(_cachedData!);
    // Save to Hive for future use
    await _saveData(_cachedData!);
    return _cachedData!;
  }

  AppData2 _parseAppDataFromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>;
    final depot = meta['depot'] as Map<String, dynamic>;
    return AppData2(
      planDate: DateTime.parse(meta['planDate'] as String),
      depotTimezone: meta['depotTimezone'] as String,
      depot: LatLng(
        (depot['lat'] as num).toDouble(),
        (depot['lon'] as num).toDouble(),
      ),
      vehicles: (json['vehicles'] as List)
          .map((v) => Vehicle.fromJson(v as Map<String, dynamic>))
          .toList(),
      orders: (json['orders'] as List)
          .map((o) => Order.fromJson(o as Map<String, dynamic>))
          .toList(),
      customers: (json['customers'] as List)
          .map((c) => Customer.fromJson(c as Map<String, dynamic>))
          .toList(),
      trips: json['trips'] != null
          ? (json['trips'] as List)
                .map((t) => Trip.fromJson(t as Map<String, dynamic>))
                .toList()
          : [],
    );
  }

  AppData2 _applyEnvDatasetSizing(AppData2 data) {
    // Dev: limit to 10 orders; Prod: limit to 20 orders
    final limit = AppConfig.flavor == BuildFlavor.dev ? 10 : 20;
    final limitedOrders = data.orders.take(limit).toList();
    // Filter trips to only include stops whose order still exists
    final availableOrderIds = limitedOrders.map((o) => o.id).toSet();
    final limitedTrips = data.trips.map((t) {
      final filteredStops = t.stops
          .where((s) => availableOrderIds.contains(s.orderId))
          .toList();
      return t.copyWith(stops: filteredStops);
    }).toList();
    return data.copyWith(orders: limitedOrders, trips: limitedTrips);
  }

  Future<void> saveTrip(Trip trip) async {
    final currentData = await loadData();
    final updatedTrips = [...currentData.trips];

    final existingIndex = updatedTrips.indexWhere((t) => t.id == trip.id);
    if (existingIndex >= 0) {
      updatedTrips[existingIndex] = trip;
    } else {
      updatedTrips.add(trip);
    }

    final updatedData = currentData.copyWith(trips: updatedTrips);
    await _saveData(updatedData);
    _cachedData = updatedData;
    _emitChange(updatedData);
  }

  Future<void> updateOrder(Order order) async {
    final currentData = await loadData();
    final updatedOrders = [...currentData.orders];

    final existingIndex = updatedOrders.indexWhere((o) => o.id == order.id);
    if (existingIndex >= 0) {
      updatedOrders[existingIndex] = order;
    }

    final updatedData = currentData.copyWith(orders: updatedOrders);
    await _saveData(updatedData);
    _cachedData = updatedData;
    _emitChange(updatedData);
  }

  Future<void> deleteTrip(String tripId) async {
    final currentData = await loadData();
    final updatedTrips = currentData.trips
        .where((t) => t.id != tripId)
        .toList();

    final updatedData = currentData.copyWith(trips: updatedTrips);
    await _saveData(updatedData);
    _cachedData = updatedData;
    _emitChange(updatedData);
  }

  Future<void> _saveData(AppData2 data) async {
    final jsonData = {
      'meta': {
        'planDate': data.planDate.toIso8601String(),
        'depotTimezone': data.depotTimezone,
        'depot': {'lat': data.depot.latitude, 'lon': data.depot.longitude},
      },
      'vehicles': data.vehicles.map((v) => v.toJson()).toList(),
      'orders': data.orders.map((o) => o.toJson()).toList(),
      'customers': data.customers.map((c) => c.toJson()).toList(),
      'trips': data.trips.map((t) => t.toJson()).toList(),
    };

    await _box.put(_dataKey, jsonData);
    // Also emit here to propagate non-trip/order changes (e.g., env sizing)
    _emitChange(data);
  }

  Customer getCustomerById(String customerId) {
    if (_cachedData == null) throw Exception('Data not loaded');
    return _cachedData!.customers.firstWhere((c) => c.id == customerId);
  }

  Order getOrderById(String orderId) {
    if (_cachedData == null) throw Exception('Data not loaded');
    return _cachedData!.orders.firstWhere((o) => o.id == orderId);
  }

  Vehicle getVehicleById(String vehicleId) {
    if (_cachedData == null) throw Exception('Data not loaded');
    return _cachedData!.vehicles.firstWhere((v) => v.id == vehicleId);
  }

  List<Order> getAllOrders() {
    if (_cachedData == null) throw Exception('Data not loaded');
    return List<Order>.from(_cachedData!.orders);
  }

  List<Order> getAvailableOrders() {
    if (_cachedData == null) throw Exception('Data not loaded');

    // Exclude orders assigned to ANY trip (active or completed)
    final assignedOrderIds = _cachedData!.trips
        .expand((trip) => trip.stops.map((stop) => stop.orderId))
        .toSet();

    final filtered = _cachedData!.orders
        .where((order) => !assignedOrderIds.contains(order.id))
        .toList();

    // Apply environment sizing limits after filtering
    if (AppConfig.flavor == BuildFlavor.dev) {
      return filtered.take(10).toList();
    }
    if (AppConfig.flavor == BuildFlavor.prod) {
      return filtered.take(5).toList();
    }

    return filtered;
  }

  void clearCache() {
    _cachedData = null;
  }

  void _emitChange(AppData2 data) {
    if (!_changeController.isClosed) {
      _changeController.add(data);
    }
  }
}

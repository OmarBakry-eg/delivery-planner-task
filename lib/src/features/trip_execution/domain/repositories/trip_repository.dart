import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';

import '../../../orders/data/models/customer.dart';
import '../../../orders/data/models/order.dart';
import 'package:test_hsa_group/src/features/trip_planning/data/model/vehicle.dart';
import '../../data/models/trip.dart';

class TripExecutionRepository {
  static const String _boxName = 'delivery_dispatcher_data';
  static const String _dataKey = 'app_data';
  late Box _box;
  AppData2? _cachedData;

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<AppData2> loadData() async {
    if (_cachedData != null) return _cachedData!;

    final savedData = _box.get(_dataKey);
    try {
      if (savedData != null) {
        final Map<String, dynamic> savedDataString = Map<String, dynamic>.from(
          savedData as Map<dynamic, dynamic>,
        );
        _cachedData = _parseAppDataFromJson(savedDataString);
        return _cachedData!;
      }
    } catch (_) {}

    final String jsonString = await rootBundle.loadString(
      'assets/sample_data.json',
    );
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    _cachedData = _parseAppDataFromJson(jsonData);
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
  }

  Future<void> deleteTrip(String tripId) async {
    final currentData = await loadData();
    final updatedTrips = currentData.trips
        .where((t) => t.id != tripId)
        .toList();
    final updatedData = currentData.copyWith(trips: updatedTrips);
    await _saveData(updatedData);
    _cachedData = updatedData;
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
  }
}

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

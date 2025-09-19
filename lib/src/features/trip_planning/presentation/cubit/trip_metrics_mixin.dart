// import 'package:test_hsa_group/features/trip_execution/domain/entities/delivery.dart';
// import 'package:test_hsa_group/features/trip_execution/domain/entities/trip.dart';
// import 'package:test_hsa_group/features/trip_planning/data/trip_repo.dart';

// class TripMetrics {
//   final double totalWeight;
//   final double totalVolume;
//   final double totalCod;
//   final double weightUtilization;
//   final double volumeUtilization;
//   final int completedStops;
//   final int inTransitStops;
//   final int remainingStops;
//   final int totalStops;

//   const TripMetrics({
//     required this.totalWeight,
//     required this.totalVolume,
//     required this.totalCod,
//     required this.weightUtilization,
//     required this.volumeUtilization,
//     required this.completedStops,
//     required this.inTransitStops,
//     required this.remainingStops,
//     required this.totalStops,
//   });
// }

// mixin TripMetricsMixin {
//   TripRepository get repository;

//   TripMetrics computeTripMetrics(Trip trip) {
//     double totalWeight = 0.0;
//     double totalVolume = 0.0;
//     double totalCod = 0.0;

//     for (final stop in trip.stops) {
//       try {
//         final order = repository.getOrderById(stop.orderId);
//         totalWeight += order.totalWeight;
//         totalVolume += order.totalVolume;
//         totalCod += order.codAmount;
//       } catch (_) {
//         // Missing order: treat as zero contributions
//       }
//     }

//     final vehicle = repository.getVehicleById(trip.vehicleId);
//     final double weightUtilization = _safeDivide(
//       totalWeight,
//       vehicle.effectiveWeightCapacity,
//     );
//     final double volumeUtilization = _safeDivide(
//       totalVolume,
//       vehicle.effectiveVolumeCapacity,
//     );

//     final int completedStops = trip.stops
//         .where((s) => s.status == DeliveryStatus.completed)
//         .length;
//     final int inTransitStops = trip.stops
//         .where((s) => s.status == DeliveryStatus.inTransit)
//         .length;
//     final int totalStops = trip.stops.length;
//     final int remainingStops = totalStops - completedStops;

//     return TripMetrics(
//       totalWeight: totalWeight,
//       totalVolume: totalVolume,
//       totalCod: totalCod,
//       weightUtilization: weightUtilization.isFinite ? weightUtilization : 0.0,
//       volumeUtilization: volumeUtilization.isFinite ? volumeUtilization : 0.0,
//       completedStops: completedStops,
//       inTransitStops: inTransitStops,
//       remainingStops: remainingStops,
//       totalStops: totalStops,
//     );
//   }

//   double _safeDivide(num numerator, num denominator) {
//     if (denominator == 0 || denominator.isNaN) return 0.0;
//     final result = numerator / denominator;
//     if (result.isNaN || result.isInfinite) return 0.0;
//     return result.toDouble();
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hsa_group/src/features/trip_planning/data/model/vehicle.dart';
import 'package:test_hsa_group/src/features/orders/data/models/customer.dart';
import 'package:test_hsa_group/src/features/orders/data/models/order.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/cubit/trip_planning_cubit.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/cubit/trip_planning_state.dart';

part 'capacity_indicators.dart';
class TripBuilder extends StatefulWidget {
  final List<Order> availableOrders;
  final List<Vehicle> vehicles;
  final List<Customer> customers;

  const TripBuilder({
    super.key,
    required this.availableOrders,
    required this.vehicles,
    required this.customers,
  });

  @override
  State<TripBuilder> createState() => _TripBuilderState();
}

class _TripBuilderState extends State<TripBuilder> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Select Vehicle',
              border: OutlineInputBorder(),
            ),
            value: context.select<TripPlanningCubit, String?>((cubit) {
              final s = cubit.state;
              if (s is TripPlanningLoaded) return s.selectedVehicleId;
              return null;
            }),
            items: widget.vehicles.map<DropdownMenuItem<String>>((vehicle) {
              return DropdownMenuItem<String>(
                value: vehicle.id,
                child: Text(
                  '${vehicle.name} (Weight: ${vehicle.effectiveWeightCapacity.toStringAsFixed(0)} kg, Volume: ${vehicle.effectiveVolumeCapacity.toStringAsFixed(1)} m³)',
                ),
              );
            }).toList(),
            onChanged: context.read<TripPlanningCubit>().selectVehicle,
          ),
          if (context.select<TripPlanningCubit, bool>((cubit) {
            final s = cubit.state;
            return s is TripPlanningLoaded && s.selectedVehicleId != null;
          })) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Capacity Utilization',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'COD: \$${context.select<TripPlanningCubit, double>((cubit) {
                    final s = cubit.state;
                    if (s is TripPlanningLoaded) {
                      return cubit.calculateTotalCod(s.selectedOrderIds);
                    }
                    return 0.0;
                  }).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _CapacityIndicators(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Orders (${widget.availableOrders.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      context.select<TripPlanningCubit, bool>((cubit) {
                        final s = cubit.state;
                        return s is TripPlanningLoaded &&
                            s.selectedOrderIds.isNotEmpty;
                      })
                      ? _createTrip
                      : null,
                  child: Text(
                    'Create Trip (${context.select<TripPlanningCubit, int>((cubit) {
                      final s = cubit.state;
                      if (s is TripPlanningLoaded) return s.selectedOrderIds.length;
                      return 0;
                    })})',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            widget.availableOrders.isEmpty
                ? const Center(child: Text('No available orders'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.availableOrders.length,
                    itemBuilder: (context, index) {
                      return Builder(
                        builder: (context) {
                          final order = widget.availableOrders[index];
                          final customer = widget.customers.firstWhere(
                            (c) => c.id == order.customerId,
                          );
                          final isSelected = context
                              .select<TripPlanningCubit, bool>((cubit) {
                                final s = cubit.state;
                                if (s is TripPlanningLoaded) {
                                  return s.selectedOrderIds.contains(order.id);
                                }
                                return false;
                              });
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : null,
                            child: CheckboxListTile(
                              value: isSelected,
                              onChanged: (value) => context
                                  .read<TripPlanningCubit>()
                                  .toggleOrderSelection(
                                    order.id,
                                    value == true,
                                  ),
                              title: Text(order.id),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(customer.name),
                                  Text(
                                    'Weight: ${order.totalWeight.toStringAsFixed(1)} kg • Volume: ${order.totalVolume.toStringAsFixed(3)} m³',
                                  ),
                                  if (order.codAmount > 0)
                                    Text(
                                      'COD: \$${order.codAmount.toStringAsFixed(2)}',
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ],
        ],
      ),
    );
  }

  Future<void> _createTrip() async {
    final s = context.read<TripPlanningCubit>().state;
    if (s is! TripPlanningLoaded || s.selectedVehicleId == null) return;
    final result = await context.read<TripPlanningCubit>().createTrip(
      s.selectedVehicleId!,
      s.selectedOrderIds,
    );

    if (mounted) {
      if (result == 'Success') {
        context.read<TripPlanningCubit>().resetSelections(s.selectedVehicleId!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip created successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result), backgroundColor: Colors.red),
        );
      }
    }
  }
}

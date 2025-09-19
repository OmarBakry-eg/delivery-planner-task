import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hsa_group/src/features/trip_execution/data/models/delivery.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/cubit/trip_execution_cubit.dart';


class StopNavigator extends StatelessWidget {
  final int currentIndex;
  final int totalStops;
  final List<DeliveryStop> stops;

  const StopNavigator({
    super.key,
    required this.currentIndex,
    required this.totalStops,
    required this.stops,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: currentIndex > 0
                    ? () => context.read<TripExecutionCubit>().previousStop()
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  'Stop ${currentIndex + 1} of $totalStops',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: currentIndex < totalStops - 1
                    ? () => context.read<TripExecutionCubit>().nextStop()
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(totalStops, (index) {
              final stop = stops[index];
              Color color = Colors.grey;
              switch (stop.status) {
                case DeliveryStatus.completed:
                  color = Colors.green;
                  break;
                case DeliveryStatus.inTransit:
                  color = Colors.orange;
                  break;
                case DeliveryStatus.failed:
                  color = Colors.red;
                  break;
                case DeliveryStatus.pending:
                  color = Colors.grey;
                  break;
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      context.read<TripExecutionCubit>().navigateToStop(index),
                  child: Container(
                    height: 8,
                    margin: EdgeInsets.only(
                      right: index < totalStops - 1 ? 2 : 0,
                      left: index > 0 ? 2 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: index == currentIndex
                          ? color
                          : color.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}



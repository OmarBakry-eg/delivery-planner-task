
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hsa_group/src/features/trip_execution/data/models/trip.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/screens/trip_execution_screen.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/cubit/trip_planning_cubit.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/widgets/show_map.dart';

class TripCardPopupMenuButton extends StatelessWidget {
  const TripCardPopupMenuButton({
    super.key,
    required this.currentTrip,
  });

  final Trip currentTrip;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'execute') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TripExecutionScreen(tripId: currentTrip.id),
            ),
          );
        } else if (value == 'delete') {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Trip'),
              content: const Text(
                'Are you sure you want to delete this trip?',
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
    
          if (confirmed == true) {
            if (context.mounted) {
              final result = await context
                  .read<TripPlanningCubit>()
                  .deleteTrip(currentTrip.id);
              if (result != 'Success') {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                }
              }
            }
          }
        } else if (value == 'map') {
          showTripMap(context, currentTrip);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'execute',
          child: Row(
            children: [
              Icon(Icons.play_arrow),
              SizedBox(width: 8),
              Text('Execute Trip'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'map',
          child: Row(
            children: [
              Icon(Icons.map),
              SizedBox(width: 8),
              Text('View Map'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

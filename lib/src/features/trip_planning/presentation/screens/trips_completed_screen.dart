import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/cubit/trip_planning_cubit.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/cubit/trip_planning_state.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/widgets/trip_card.dart';

class TripsCompletedScreen extends StatelessWidget {
  const TripsCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completed Trips')),
      body: BlocBuilder<TripPlanningCubit, TripPlanningState>(
        builder: (context, state) {
          if (state is TripPlanningLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TripPlanningError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                ],
              ),
            );
          }

          if (state is TripPlanningLoaded) {
            final completedTrips = state.trips
                .where((t) => t.isCompleted)
                .toList();
            if (completedTrips.isEmpty) {
              return const Center(child: Text('No completed trips'));
            }

            return ListView.separated(
              separatorBuilder: (context, index) => const Divider(thickness: 2),
              padding: const EdgeInsets.all(16),
              itemCount: completedTrips.length,
              itemBuilder: (context, index) {
                final trip = completedTrips[index];
                return TripCard(
                  key: ValueKey(trip.id),
                  trip: trip,
                  expanded: true,
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

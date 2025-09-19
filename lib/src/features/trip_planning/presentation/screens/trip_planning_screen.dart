import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hsa_group/src/utils/timezone_utils.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/cubit/trip_planning_cubit.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/cubit/trip_planning_state.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/screens/trips_completed_screen.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/widgets/trip_builder.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/widgets/trip_card.dart';

class TripPlanningScreen extends StatelessWidget {
  const TripPlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<TripPlanningCubit, TripPlanningState>(
          builder: (context, state) {
            if (state is TripPlanningLoaded) {
              final formatted = TimezoneUtils.formatInTimezone(
                state.planDate,
                state.depotTimezone,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Trip Planner'),
                  Text(
                    'Plan date: $formatted',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              );
            }
            return const Text('Trip Planner');
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TripsCompletedScreen()),
              );
            },
            icon: const Icon(Icons.done_all),
            //   label: const Text('Completed Trips'),
          ),
        ],
      ),
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
                  Text(
                    'Error: ${state.message}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<TripPlanningCubit>().loadData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is TripPlanningLoaded) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  if (state.trips.isNotEmpty) ...[
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: state.trips
                          .where((t) => !t.isCompleted)
                          .length,
                      itemBuilder: (context, index) {
                        final activeTrips = state.trips
                            .where((t) => !t.isCompleted)
                            .toList();
                        final trip = activeTrips[index];
                        return TripCard(key: ValueKey(trip.id), trip: trip);
                      },
                    ),
                    const Divider(thickness: 2),
                  ],
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Create New Trip',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TripBuilder(
                    availableOrders: state.availableOrders,
                    vehicles: state.vehicles,
                    customers: state.customers,
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}

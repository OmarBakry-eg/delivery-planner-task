import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/cubit/trip_execution_cubit.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/cubit/trip_execution_state.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/widgets/stop_details.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/widgets/stop_navigator.dart';

class TripExecutionScreen extends StatefulWidget {
  final String tripId;

  const TripExecutionScreen({super.key, required this.tripId});

  @override
  State<TripExecutionScreen> createState() => _TripExecutionScreenState();
}

class _TripExecutionScreenState extends State<TripExecutionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TripExecutionCubit>().loadTrip(widget.tripId);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trip: ${widget.tripId}')),
      body: BlocBuilder<TripExecutionCubit, TripExecutionState>(
        builder: (context, state) {
          if (state is TripExecutionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
    
          if (state is TripExecutionError) {
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
                        context.read<TripExecutionCubit>().loadTrip(widget.tripId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
    
          if (state is TripExecutionLoaded) {
            return Column(
              children: [
                StopNavigator(
                  currentIndex: state.currentStopIndex,
                  totalStops: state.trip.stops.length,
                  stops: state.trip.stops,
                ),
                Expanded(
                  child: StopDetails(
                    stop: state.currentStop,
                    order: state.getCurrentOrder(),
                    customer: state.getCurrentCustomer(),
                  ),
                ),
              ],
            );
          }
    
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}
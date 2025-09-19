part of 'trip_builder.dart';
class _CapacityIndicators extends StatelessWidget {
  const _CapacityIndicators();

  @override
  Widget build(BuildContext context) {
        final selectedVehicleId = context.select<TripPlanningCubit, String?>((
      cubit,
    ) {
      final s = cubit.state;
      if (s is TripPlanningLoaded) return s.selectedVehicleId;
      return null;
    });
    if (selectedVehicleId == null) return const SizedBox.shrink();

    final selectedOrderIds = context.select<TripPlanningCubit, List<String>>((
      cubit,
    ) {
      final s = cubit.state;
      if (s is TripPlanningLoaded) return s.selectedOrderIds;
      return const [];
    });

    final weightUtil = context
        .read<TripPlanningCubit>()
        .calculateWeightUtilization(selectedVehicleId, selectedOrderIds);
    final volumeUtil = context
        .read<TripPlanningCubit>()
        .calculateVolumeUtilization(selectedVehicleId, selectedOrderIds);
    final vehicle = context.read<TripPlanningCubit>().getVehicleById(
      selectedVehicleId,
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Weight', style: TextStyle(fontSize: 12)),
                  LinearProgressIndicator(
                    value: weightUtil.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      weightUtil > 1.0 ? Colors.red : Colors.blue,
                    ),
                  ),
                  Text(
                    '${(weightUtil * 100).toStringAsFixed(0)}% • ${(vehicle.effectiveWeightCapacity * weightUtil).toStringAsFixed(1)} kg',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Volume', style: TextStyle(fontSize: 12)),
                  LinearProgressIndicator(
                    value: volumeUtil.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      volumeUtil > 1.0 ? Colors.red : Colors.green,
                    ),
                  ),
                  Text(
                    '${(volumeUtil * 100).toStringAsFixed(0)}% • ${(vehicle.effectiveVolumeCapacity * volumeUtil).toStringAsFixed(2)} m³',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
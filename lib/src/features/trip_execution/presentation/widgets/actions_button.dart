import 'package:flutter/material.dart';
import 'package:test_hsa_group/src/features/trip_execution/domain/entities/delivery.dart';
class ActionButtons extends StatelessWidget {
  final List<DeliveryStatus> validTransitions;
  final Function(DeliveryStatus) onStatusUpdate;

  const ActionButtons({
    super.key,
    required this.validTransitions,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    if (validTransitions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No actions available for this status')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...validTransitions.map((status) {
              String buttonText = '';
              Color? buttonColor;

              switch (status) {
                case DeliveryStatus.inTransit:
                  buttonText = 'Start Transit';
                  buttonColor = Colors.blue;
                  break;
                case DeliveryStatus.completed:
                  buttonText = 'Mark Completed';
                  buttonColor = Colors.green;
                  break;
                case DeliveryStatus.failed:
                  buttonText = 'Mark Failed';
                  buttonColor = Colors.red;
                  break;
                case DeliveryStatus.pending:
                  // This shouldn't happen with current state machine
                  buttonText = 'Mark Pending';
                  break;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => onStatusUpdate(status),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(buttonText),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hsa_group/src/features/orders/data/models/customer.dart';
import 'package:test_hsa_group/src/features/orders/data/models/order.dart';
import 'package:test_hsa_group/src/features/trip_execution/domain/entities/delivery.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/cubit/failure_reasons_cubit.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/cubit/failure_reasons_state.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/cubit/trip_execution_cubit.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/widgets/actions_button.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/widgets/cod_collection_card.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/widgets/customer_card.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/widgets/serial_number_card.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/widgets/status_card.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/widgets/trip_execution_order_card.dart';

class StopDetails extends StatefulWidget {
  final DeliveryStop stop;
  final Order order;
  final Customer customer;

  const StopDetails({
    super.key,
    required this.stop,
    required this.order,
    required this.customer,
  });

  @override
  State<StopDetails> createState() => _StopDetailsState();
}

class _StopDetailsState extends State<StopDetails> {
  final TextEditingController _codController = TextEditingController();
  final List<TextEditingController> _serialControllers = [];
  @override
  void initState() {
    super.initState();
    _codController.text = widget.stop.collectedCod?.toStringAsFixed(2) ?? '';
    _setupSerialControllers();
  }

  @override
  void didUpdateWidget(StopDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stop.orderId != widget.stop.orderId) {
      _codController.text = widget.stop.collectedCod?.toStringAsFixed(2) ?? '';
      _setupSerialControllers();
    }
  }

  void _setupSerialControllers() {
    _serialControllers.clear();
    for (final item in widget.order.items) {
      if (item.serialTracked && item.quantity > 1) {
        for (int i = 0; i < item.quantity; i++) {
          final controller = TextEditingController();
          if (i < item.serialNumbers.length) {
            controller.text = item.serialNumbers[i];
          }
          _serialControllers.add(controller);
        }
      }
    }
  }

  @override
  void dispose() {
    _codController.dispose();
    for (final controller in _serialControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.stop.status;
    final validTransitions = context
        .read<TripExecutionCubit>()
        .getValidTransitions(status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusCard(status: status),
          const SizedBox(height: 16),
          CustomerCard(customer: widget.customer),
          const SizedBox(height: 16),
          TripExecutionOrderCard(order: widget.order),
          if (widget.order.codAmount > 0 &&
              status != DeliveryStatus.completed &&
              status != DeliveryStatus.failed) ...[
            const SizedBox(height: 16),
            CodCollectionCard(
              expectedAmount: widget.order.codAmount,
              controller: _codController,
            ),
          ],
          if (_needsSerialNumbers()) ...[
            const SizedBox(height: 16),
            SerialNumberCard(
              order: widget.order,
              controllers: _serialControllers,
            ),
          ],
          if (status == DeliveryStatus.failed &&
              widget.stop.failureReasons.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Failure Reasons',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.stop.failureReasons.map(
                      (reason) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $reason'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ActionButtons(
            validTransitions: validTransitions,
            onStatusUpdate: _updateStatus,
          ),
        ],
      ),
    );
  }

  bool _needsSerialNumbers() {
    return widget.order.items.any(
      (item) => item.serialTracked && item.quantity > 1,
    );
  }

  Future<void> _updateStatus(DeliveryStatus newStatus) async {
    double? collectedCod;
    List<String>? serialNumbers;
    List<String>? failureReasons;

    if (newStatus == DeliveryStatus.completed) {
      // Validate COD
      if (widget.order.codAmount > 0) {
        final codText = _codController.text.trim();
        if (codText.isEmpty) {
          _showError('COD amount is required');
          return;
        }
        collectedCod = double.tryParse(codText);
        if (collectedCod == null) {
          _showError('Invalid COD amount');
          return;
        }
      }

      // Validate serial numbers
      if (_needsSerialNumbers()) {
        serialNumbers = _serialControllers.map((c) => c.text.trim()).toList();
      }
    }

    if (newStatus == DeliveryStatus.failed) {
      final result = await _showFailureDialog();
      if (result == null || result.isEmpty) return;
      failureReasons = result;
    }
    if (mounted) {
      final result = await context.read<TripExecutionCubit>().updateStopStatus(
        newStatus,
        collectedCod: collectedCod,
        failureReasons: failureReasons,
        serialNumbers: serialNumbers,
      );

      if (result == 'Success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Status updated to ${_getStatusDisplayName(newStatus)}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        _showError(result);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<List<String>?> _showFailureDialog() async {
    final controller = TextEditingController();
    return await showDialog<List<String>>(
      context: context,
      builder: (ctx) => BlocProvider(
        create: (_) => FailureReasonsCubit(),
        child: BlocBuilder<FailureReasonsCubit, FailureReasonsState>(
          builder: (context, state) => AlertDialog(
            title: const Text('Mark as Failed'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Failure reason',
                    hintText: 'Enter reason for failure',
                  ),
                  onSubmitted: (value) {
                    context.read<FailureReasonsCubit>().addReason(value);
                    controller.clear();
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    context.read<FailureReasonsCubit>().addReason(
                      controller.text,
                    );
                    controller.clear();
                  },
                  child: const Text('Add Reason'),
                ),
                const SizedBox(height: 16),
                if (state.reasons.isNotEmpty) ...[
                  const Text(
                    'Reasons:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...state.reasons.map(
                    (reason) => Chip(
                      label: Text(reason),
                      onDeleted: () => context
                          .read<FailureReasonsCubit>()
                          .removeReason(reason),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: state.reasons.isNotEmpty
                    ? () => Navigator.pop(context, state.reasons)
                    : null,
                child: const Text('Confirm'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusDisplayName(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return 'Pending';
      case DeliveryStatus.inTransit:
        return 'In Transit';
      case DeliveryStatus.completed:
        return 'Completed';
      case DeliveryStatus.failed:
        return 'Failed';
    }
  }
}
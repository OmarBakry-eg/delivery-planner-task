import 'package:flutter/material.dart';

class SerialNumberCard extends StatelessWidget {
  final dynamic order;
  final List<TextEditingController> controllers;

  const SerialNumberCard({
    super.key,
    required this.order,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    int controllerIndex = 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Serial Numbers',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...order.items
                .where((item) => item.serialTracked && item.quantity > 1)
                .map<Widget>((item) {
                  final startIndex = controllerIndex;
                  controllerIndex += item.quantity as int;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.name} (Qty: ${item.quantity})',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      ...List.generate(item.quantity, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextField(
                            controller: controllers[startIndex + index],
                            decoration: InputDecoration(
                              labelText: 'Serial ${index + 1}',
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }
}



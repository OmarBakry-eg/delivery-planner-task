part of 'order_card_widget.dart';

class _OrderCardItemsWidget extends StatelessWidget {
  final OrderItem item;
  const _OrderCardItemsWidget({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('SKU: ${item.sku}'),
                const Spacer(),
                if (item.serialTracked) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Serial Tracked',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Weight: ${(item.weight * item.quantity).toStringAsFixed(1)} kg',
                ),
                const SizedBox(width: 16),
                Text(
                  'Volume: ${(item.volume * item.quantity).toStringAsFixed(3)} m³',
                ),
              ],
            ),
            if (item.serialTracked &&
                item.serialNumbers.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Serial Numbers: ${item.serialNumbers.join(", ")}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

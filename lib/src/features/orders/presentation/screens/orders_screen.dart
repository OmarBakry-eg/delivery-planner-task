import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hsa_group/src/features/orders/presentation/widgets/order_card_widget.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/cubit/trip_planning_cubit.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/cubit/trip_planning_state.dart';

class AllOrdersScreen extends StatelessWidget {
  const AllOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Hub'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<TripPlanningCubit, TripPlanningState>(
              builder: (context, state) {
                if (state is! TripPlanningLoaded) {
                  return const SizedBox.shrink();
                }

                return TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search orders or customers...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) =>
                      context.read<TripPlanningCubit>().filterOrders(value),
                );
              },
            ),
          ),
        ),
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
            final orders = state.filteredOrders;

            if (orders.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No orders found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Try adjusting your search filters',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final customer = state.customers.firstWhere(
                  (c) => c.id == order.customerId,
                );
                return OrderCard(order: order, customer: customer);
              },
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hsa_group/src/features/home/presentation/cubit/home_cubit.dart';
import 'package:test_hsa_group/src/features/home/presentation/cubit/home_state.dart';
import 'package:test_hsa_group/src/features/orders/presentation/screens/orders_screen.dart';
import 'package:test_hsa_group/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/screens/trip_planning_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      const AllOrdersScreen(),
      const TripPlanningScreen(),
      const SettingsScreen(),
    ];

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, homeState) {
        return Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: IndexedStack(
              key: ValueKey(homeState.selectedIndex),
              index: homeState.selectedIndex,
              children: pages,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: homeState.selectedIndex,
            onTap: context.read<HomeCubit>().setSelectedIndex,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2),
                label: 'Orders',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Trips'),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}

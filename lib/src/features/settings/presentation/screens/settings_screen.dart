import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hsa_group/src/core/config/app_config.dart';
import 'package:test_hsa_group/src/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:test_hsa_group/src/features/settings/presentation/cubit/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Theme',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.system,
                        groupValue: state.themeMode,
                        onChanged: state.isBusy
                            ? null
                            : (mode) {
                                if (mode != null) {
                                  context.read<SettingsCubit>().changeTheme(
                                    mode,
                                  );
                                }
                              },
                        title: const Text('System'),
                      ),
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.light,
                        groupValue: state.themeMode,
                        onChanged: state.isBusy
                            ? null
                            : (mode) {
                                if (mode != null) {
                                  context.read<SettingsCubit>().changeTheme(
                                    mode,
                                  );
                                }
                              },
                        title: const Text('Light'),
                      ),
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.dark,
                        groupValue: state.themeMode,
                        onChanged: state.isBusy
                            ? null
                            : (mode) {
                                if (mode != null) {
                                  context.read<SettingsCubit>().changeTheme(
                                    mode,
                                  );
                                }
                              },
                        title: const Text('Dark'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Environment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RadioListTile<BuildFlavor>(
                        value: BuildFlavor.dev,
                        groupValue: state.flavor,
                        onChanged: state.isBusy
                            ? null
                            : (flavor) {
                                if (flavor != null) {
                                  context
                                      .read<SettingsCubit>()
                                      .changeEnvironment(context, flavor);
                                }
                              },
                        title: const Text('Development (10 orders)'),
                      ),
                      RadioListTile<BuildFlavor>(
                        value: BuildFlavor.prod,
                        groupValue: state.flavor,
                        onChanged: state.isBusy
                            ? null
                            : (flavor) {
                                if (flavor != null) {
                                  context
                                      .read<SettingsCubit>()
                                      .changeEnvironment(context, flavor);
                                }
                              },
                        title: const Text('Production (5 orders)'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: state.isBusy
                              ? null
                              : () => context.read<SettingsCubit>().logout(
                                  context,
                                ),
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

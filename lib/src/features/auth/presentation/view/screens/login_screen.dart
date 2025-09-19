import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_hsa_group/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:test_hsa_group/src/features/auth/presentation/cubit/auth_state.dart';

part 'animated_background.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'dispatcher@demo.com');
  final _passwordController = TextEditingController(text: 'password123');
  // obscuring handled by AuthCubit

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          _AnimatedBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child:
                    Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.route,
                                      size: 40,
                                      color: Colors.blue,
                                    ).animate().scale(duration: 500.ms),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Delivery Dispatcher',
                                      style: GoogleFonts.inter(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ).animate().fadeIn(
                                      duration: 400.ms,
                                      curve: Curves.easeOut,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Welcome back, Dispatcher',
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Please sign in to continue',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                BlocConsumer<AuthCubit, AuthState>(
                                  listener: (context, state) {
                                    if (state is AuthFailure) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(state.message),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  builder: (context, state) {
                                    final isLoading = state is AuthLoading;
                                    return Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          TextFormField(
                                                controller: _emailController,
                                                enabled: !isLoading,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'Email',
                                                      prefixIcon: Icon(
                                                        Icons.email_outlined,
                                                      ),
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                validator: (v) {
                                                  if (v == null ||
                                                      v.trim().isEmpty) {
                                                    return 'Email is required';
                                                  }
                                                  if (!v.contains('@')) {
                                                    return 'Enter a valid email';
                                                  }
                                                  return null;
                                                },
                                              )
                                              .animate()
                                              .slideX(
                                                begin: -0.1,
                                                end: 0,
                                                duration: 350.ms,
                                              )
                                              .fadeIn(),
                                          const SizedBox(height: 12),
                                          TextFormField(
                                                controller: _passwordController,
                                                enabled: !isLoading,
                                                obscureText: context
                                                    .select<AuthCubit, bool>(
                                                      (cubit) =>
                                                          cubit.obscurePassword,
                                                    ),
                                                decoration: InputDecoration(
                                                  labelText: 'Password',
                                                  prefixIcon: const Icon(
                                                    Icons.lock_outline,
                                                  ),
                                                  border:
                                                      const OutlineInputBorder(),
                                                  suffixIcon: IconButton(
                                                    onPressed: context
                                                        .read<AuthCubit>()
                                                        .togglePasswordVisibility,
                                                    icon: Icon(
                                                      context.select<
                                                            AuthCubit,
                                                            bool
                                                          >(
                                                            (cubit) => cubit
                                                                .obscurePassword,
                                                          )
                                                          ? Icons.visibility
                                                          : Icons
                                                                .visibility_off,
                                                    ),
                                                  ),
                                                ),
                                                validator: (v) {
                                                  if (v == null || v.isEmpty) {
                                                    return 'Password is required';
                                                  }
                                                  if (v.length < 6) {
                                                    return 'Minimum 6 characters';
                                                  }
                                                  return null;
                                                },
                                              )
                                              .animate()
                                              .slideX(
                                                begin: 0.1,
                                                end: 0,
                                                duration: 350.ms,
                                              )
                                              .fadeIn(),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 48,
                                            child: ElevatedButton(
                                              onPressed: isLoading
                                                  ? null
                                                  : _onSubmit,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    theme.colorScheme.primary,
                                                foregroundColor:
                                                    theme.colorScheme.onPrimary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: isLoading
                                                  ? const SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                    )
                                                  : const Text('Sign In'),
                                            ),
                                          ).animate().fadeIn().scale(
                                            curve: Curves.easeOutBack,
                                            duration: 400.ms,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.info_outline, size: 16),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Use demo credentials above',
                                    ).animate().fadeIn(duration: 500.ms),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .moveY(begin: 12, end: 0, duration: 400.ms),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthCubit>().signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }
}


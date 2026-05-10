import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skill_circle_app/core/constants/app_routes.dart';
import 'package:skill_circle_app/core/utils/validators.dart';
import 'package:skill_circle_app/features/auth/presentation/controllers/auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (_, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authFailureMessage(error))),
          );
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9E6D), Color(0xFFFB6F58)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 26),
                          SizedBox(height: 10),
                          Text(
                            'Create Account',
                            style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Build your profile and start learning with the community.',
                            style: TextStyle(color: Color(0xFFFFF0E8), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Display name',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.alternate_email_rounded),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                              ),
                              obscureText: true,
                              validator: Validators.strongPassword,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: authState.isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }

                              await ref
                                  .read(authControllerProvider.notifier)
                                  .register(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    displayName: _nameController.text,
                                  );
                            },
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Account'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text('Back to sign in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
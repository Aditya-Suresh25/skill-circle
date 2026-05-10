import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skill_circle_app/core/constants/app_routes.dart';
import 'package:skill_circle_app/core/providers/app_config_provider.dart';
import 'package:skill_circle_app/core/utils/validators.dart';
import 'package:skill_circle_app/features/auth/presentation/controllers/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final appConfig = ref.watch(appConfigProvider);

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
                          colors: [Color(0xFF0F6571), Color(0xFF19A7B8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 26),
                          SizedBox(height: 10),
                          Text(
                            'Welcome Back',
                            style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Sign in to continue your growth journey with your circles.',
                            style: TextStyle(color: Color(0xFFE3FBFF), height: 1.4),
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
                                  .signIn(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );
                            },
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign In'),
                    ),
                    if (appConfig.enableGoogleSignIn) ...[
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: authState.isLoading
                            ? null
                            : () async {
                                await ref.read(authControllerProvider.notifier).signInWithGoogle();
                              },
                        icon: const Icon(Icons.g_mobiledata),
                        label: const Text('Continue with Google'),
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.register),
                      child: const Text('Create a new account'),
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
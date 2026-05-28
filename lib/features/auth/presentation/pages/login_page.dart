import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skill_circle_app/core/constants/app_routes.dart';
import 'package:skill_circle_app/core/providers/app_config_provider.dart';
import 'package:skill_circle_app/core/utils/validators.dart';
import 'package:skill_circle_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:skill_circle_app/features/mentor/presentation/providers/mentor_providers.dart';
import 'package:skill_circle_app/features/profile/presentation/providers/profile_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  // used to indicate mentor-signin action in progress
  bool _mentorActionLoading = false;
  bool _adminActionLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
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
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 420),
                  offset: Offset.zero,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF181225), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.28), blurRadius: 34, spreadRadius: 2),
                        ],
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
                            style: TextStyle(color: Color(0xFFE8D9FF), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              focusNode: _emailFocus,
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
                              focusNode: _passwordFocus,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                                ),
                              ),
                              obscureText: _obscurePassword,
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
                              if (!_formKey.currentState!.validate()) return;
                              await ref.read(authControllerProvider.notifier).signIn(
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
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: authState.isLoading || _mentorActionLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              setState(() => _mentorActionLoading = true);
                              try {
                                await ref.read(authControllerProvider.notifier).signIn(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );
                                debugPrint('telemetry:mentor_signin_redirect');
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed in — redirecting to Mentor Dashboard')));
                                context.go(AppRoutes.mentorDashboard);
                              } finally {
                                if (mounted) setState(() => _mentorActionLoading = false);
                              }
                            },
                      icon: const Icon(Icons.workspace_premium_outlined),
                      label: const Text('Sign In as Mentor'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: authState.isLoading || _adminActionLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              setState(() => _adminActionLoading = true);
                              try {
                                await ref.read(authControllerProvider.notifier).signIn(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );
                                debugPrint('telemetry:admin_signin_redirect');
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed in — opening Admin Dashboard')));
                                context.go(AppRoutes.adminDashboard);
                              } finally {
                                if (mounted) setState(() => _adminActionLoading = false);
                              }
                            },
                      icon: const Icon(Icons.admin_panel_settings_rounded),
                      label: const Text('Sign In as Admin'),
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
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: authState.isLoading || _mentorActionLoading
                            ? null
                            : () async {
                                setState(() => _mentorActionLoading = true);
                                try {
                                  await ref.read(authControllerProvider.notifier).signInWithGoogle();
                                  debugPrint('telemetry:mentor_google_signin_redirect');
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed in with Google — redirecting to Mentor Dashboard')));
                                  context.go(AppRoutes.mentorDashboard);
                                } finally {
                                  if (mounted) setState(() => _mentorActionLoading = false);
                                }
                              },
                        icon: const Icon(Icons.g_mobiledata),
                        label: const Text('Continue with Google as Mentor'),
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.register),
                      child: const Text('Create a new account'),
                    ),
                    const SizedBox(height: 6),
                    Builder(builder: (ctx) {
                      final mentorAsync = ref.watch(currentMentorProfileProvider);
                      return mentorAsync.when(
                        data: (mentor) {
                          if (mentor != null) {
                            return TextButton(
                              onPressed: () {
                                debugPrint('telemetry:open_mentor_dashboard');
                                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Opening Mentor Dashboard')));
                                context.go(AppRoutes.mentorDashboard);
                              },
                              child: const Text('Open Mentor Dashboard'),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    }),
                    const SizedBox(height: 6),
                    Builder(builder: (ctx) {
                      final profileAsync = ref.watch(currentProfileProvider);
                      return profileAsync.when(
                        data: (profile) {
                          if (profile?.role.toLowerCase() == 'admin') {
                            return TextButton(
                              onPressed: () {
                                debugPrint('telemetry:open_admin_dashboard');
                                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Opening Admin Dashboard')));
                                context.go(AppRoutes.adminDashboard);
                              },
                              child: const Text('Open Admin Dashboard'),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    }),
                  ],
                ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
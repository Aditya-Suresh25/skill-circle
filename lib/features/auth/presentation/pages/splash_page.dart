import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skill_circle_app/core/constants/app_routes.dart';
import 'package:skill_circle_app/core/services/app_router.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Starting...')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: CircularProgressIndicator(color: ClayTokens.brand)),
            const SizedBox(height: 20),
            Text('Auth provider state: ${authState.runtimeType}', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Auth has data: ${authState.hasValue}', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Firebase currentUser: ${firebaseUser?.uid ?? 'null'}', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (authState.hasError) ...[
              Text('Auth error: ${authState.error}', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              const SizedBox(height: 12),
            ],
            ElevatedButton(
              onPressed: () {
                // Manual navigation to login
                context.go(AppRoutes.login);
              },
              child: const Text('Go to Login (manual)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // If firebase user exists, go to home
                if (firebaseUser != null) {
                  context.go(AppRoutes.home);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No logged-in user')));
                }
              },
              child: const Text('Go to Home if logged in'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // Refresh provider synchronously (returns new AsyncValue)
                final _ = ref.refresh(authStateProvider);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refreshed auth state provider')));
              },
              child: const Text('Refresh Auth Provider'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/services/app_router.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF127C8A), Color(0xFF19A7B8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ClayTokens.brand.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.hub_rounded, color: Colors.white, size: 34),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Skill Circle',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    firebaseUser == null ? 'Preparing your workspace...' : 'Welcome back, syncing your feed...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: ClayTokens.textSecond),
                  ),
                  const SizedBox(height: 20),
                  const LinearProgressIndicator(
                    minHeight: 6,
                    borderRadius: BorderRadius.all(Radius.circular(99)),
                    backgroundColor: Color(0x1A127C8A),
                    color: ClayTokens.brand,
                  ),
                  if (authState.hasError) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Network is slow. Retrying authentication...',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
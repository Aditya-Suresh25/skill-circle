import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';
import 'package:skill_circle_app/services/auth_service.dart';
import 'package:skill_circle_app/config/app_routes.dart';

// ══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS  — reuse on every screen
// ══════════════════════════════════════════════════════════════════════════════

/// Raised clay card — primary container primitive.
class ClayCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;

  const ClayCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = ClayTokens.radiusLG,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(ClayTokens.spaceLG),
      decoration: BoxDecoration(
        color: color ?? ClayTokens.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: ClayTokens.clayShadow,
      ),
      child: child,
    );
  }
}

/// Clay text field with optional inline label.
/// Label is bundled here so callers stay terse.
class ClayTextField extends StatefulWidget {
  final String? label;
  final String hint;
  final IconData prefixIcon;
  final bool obscure;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextEditingController? controller;

  const ClayTextField({
    super.key,
    this.label,
    required this.hint,
    required this.prefixIcon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.controller,
  });

  @override
  State<ClayTextField> createState() => _ClayTextFieldState();
}

class _ClayTextFieldState extends State<ClayTextField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: ClayTokens.textSM,
              fontWeight: FontWeight.w600,
              color: ClayTokens.textSecond,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: ClayTokens.spaceSM),
        ],
        Container(
          constraints: const BoxConstraints(minHeight: ClayTokens.fieldHeight),
          decoration: BoxDecoration(
            color: ClayTokens.brandPale,
            borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
            boxShadow: ClayTokens.clayField,
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscure && !_visible,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            style: const TextStyle(
              color: ClayTokens.textPrimary,
              fontSize: ClayTokens.textBase,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: ClayTokens.textHint,
                fontSize: ClayTokens.textBase,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ClayTokens.spaceMD,
                ),
                child: Icon(
                  widget.prefixIcon,
                  color: ClayTokens.brandLight,
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 52),
              suffixIcon: widget.obscure
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _visible = !_visible),
                      child: SizedBox(
                        // Explicit 48×48 touch zone — critical on mobile
                        width: ClayTokens.minTouch,
                        height: ClayTokens.minTouch,
                        child: Icon(
                          _visible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: ClayTokens.brandLight,
                          size: 20,
                        ),
                      ),
                    )
                  : null,
              filled: false,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
                borderSide: const BorderSide(
                  color: ClayTokens.brandLight,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
                borderSide: const BorderSide(
                  color: ClayTokens.error,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: ClayTokens.spaceMD,
                vertical: ClayTokens.spaceMD,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Primary clay button — gradient fill, branded glow, press-scale animation.
class ClayButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;

  const ClayButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
  });

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
  );
  late final Animation<double> _scale = Tween(begin: 1.0, end: 0.96).animate(
    CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => _ctrl.forward(),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              _ctrl.reverse();
              if (!widget.loading) widget.onTap?.call();
            },
      onTapCancel: widget.onTap == null ? null : () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: ClayTokens.buttonHeight,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
            boxShadow: ClayTokens.clayButton,
          ),
          alignment: Alignment.center,
          child: widget.loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: ClayTokens.textBase,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Outlined clay button — for social / secondary actions.
class ClayOutlinedButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ClayOutlinedButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: ClayTokens.minTouch + 4, // 52 px
        decoration: BoxDecoration(
          color: ClayTokens.surface,
          borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
          boxShadow: ClayTokens.clayShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: ClayTokens.brand, size: 22),
            const SizedBox(width: ClayTokens.spaceSM),
            Text(
              label,
              style: const TextStyle(
                fontSize: ClayTokens.textBase,
                fontWeight: FontWeight.w600,
                color: ClayTokens.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ambient decorative blob.
/// [alpha] uses withValues(alpha:) internally — no withOpacity.
class ClayBlob extends StatelessWidget {
  final double size;
  final Color color;
  final double alpha;
  final AlignmentGeometry alignment;

  const ClayBlob({
    super.key,
    required this.size,
    required this.color,
    required this.alignment,
    this.alpha = 0.18,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // ✅ withValues(alpha:) — withOpacity is deprecated
          color: color.withValues(alpha: alpha),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LOGIN SCREEN
// Mobile-first priorities:
//  • SafeArea + SingleChildScrollView — content survives small viewports
//  • resizeToAvoidBottomInset:true — keyboard pushes layout up naturally
//  • viewInsets.bottom padding — last field never hidden by keyboard
//  • All tap targets ≥ 48 dp
//  • Blob sizes relative to screen width — looks right on any phone
// ══════════════════════════════════════════════════════════════════════════════
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Validate login
    final username = AuthService.validateLogin(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (username != null) {
      // Login successful — navigate to dashboard
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } else {
      // Login failed
      setState(() {
        _errorMessage = 'Invalid email or password. Try luffy123@gmail.com / luffy12345';
        _isLoading = false;
      });
    }
  }

  void _handleSignUp() {
    Navigator.of(context).pushNamed(AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // Tighter vertical breathing room on compact phones (< 680 dp tall)
    final topPad =
        mq.size.height < 680 ? ClayTokens.spaceXL : ClayTokens.spaceXXL;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: ClayTokens.pageBg,
      body: Stack(
        children: [
          // ── Ambient blobs (sized relative to screen width) ─────────────────
          ClayBlob(
            size: mq.size.width * 0.72,
            color: const Color(0xFF8B5CF6),
            alignment: const Alignment(-1.15, -0.9),
            alpha: 0.18,
          ),
          ClayBlob(
            size: mq.size.width * 0.52,
            color: const Color(0xFFA78BFA),
            alignment: const Alignment(1.25, -0.35),
            alpha: 0.15,
          ),
          ClayBlob(
            size: mq.size.width * 0.42,
            color: const Color(0xFF7C3AED),
            alignment: const Alignment(0.95, 1.15),
            alpha: 0.12,
          ),

          // ── Scrollable content ─────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                ClayTokens.spaceLG,
                topPad,
                ClayTokens.spaceLG,
                // Extra bottom pad so last input clears the keyboard
                ClayTokens.spaceXL + mq.viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Logo ────────────────────────────────────────────────
                  Center(
                    child: ClayCard(
                      borderRadius: ClayTokens.radiusXL,
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius:
                              BorderRadius.circular(ClayTokens.radiusMD),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: ClayTokens.spaceXL),

                  // ── Heading ──────────────────────────────────────────────
                  const Text(
                    'Welcome back ✦',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ClayTokens.textXXL,
                      fontWeight: FontWeight.w800,
                      color: ClayTokens.textPrimary,
                      letterSpacing: -0.8,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: ClayTokens.spaceSM),
                  const Text(
                    'Sign in to your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ClayTokens.textBase,
                      color: ClayTokens.textSecond,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: ClayTokens.spaceXL),

                  // ── Form card ────────────────────────────────────────────
                  ClayCard(
                    padding: const EdgeInsets.all(ClayTokens.spaceLG),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClayTextField(
                          label: 'Email address',
                          hint: 'you@example.com',
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          controller: _emailController,
                        ),
                        const SizedBox(height: ClayTokens.spaceMD + 4),
                        ClayTextField(
                          label: 'Password',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscure: true,
                          textInputAction: TextInputAction.done,
                          controller: _passwordController,
                        ),
                        const SizedBox(height: ClayTokens.spaceSM),
                        if (_errorMessage != null) ...[
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              fontSize: ClayTokens.textSM,
                              color: ClayTokens.error,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: ClayTokens.spaceSM),
                        ],

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: ClayTokens.brand,
                              padding: const EdgeInsets.symmetric(
                                horizontal: ClayTokens.spaceXS,
                                vertical: ClayTokens.spaceSM,
                              ),
                              minimumSize: const Size(
                                ClayTokens.minTouch,
                                ClayTokens.minTouch,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontSize: ClayTokens.textSM,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: ClayTokens.spaceMD),
                        ClayButton(
                          label: _isLoading ? 'Signing in...' : 'Sign in',
                          onTap: _isLoading ? () {} : _handleLogin,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: ClayTokens.spaceLG),

                  // ── OR divider ────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          // ✅ withValues(alpha:)
                          color: ClayTokens.brandLight.withValues(alpha: 0.30),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: ClayTokens.spaceSM + 4),
                        child: Text(
                          'or continue with',
                          style: TextStyle(
                            fontSize: ClayTokens.textXS + 1,
                            // ✅ withValues(alpha:)
                            color: ClayTokens.textSecond.withValues(alpha: 0.70),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: ClayTokens.brandLight.withValues(alpha: 0.30),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: ClayTokens.spaceMD),

                  // ── Social buttons ────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: ClayOutlinedButton(
                          icon: Icons.g_mobiledata_rounded,
                          label: 'Google',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: ClayTokens.spaceSM + 4),
                      Expanded(
                        child: ClayOutlinedButton(
                          icon: Icons.apple_rounded,
                          label: 'Apple',
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: ClayTokens.spaceXXL),

                  // ── Sign-up link ──────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?  ",
                        style: TextStyle(
                          fontSize: ClayTokens.textBase,
                          color: ClayTokens.textSecond,
                        ),
                      ),
                      GestureDetector(
                        onTap: _handleSignUp,
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            fontSize: ClayTokens.textBase,
                            fontWeight: FontWeight.w700,
                            color: ClayTokens.brand,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: ClayTokens.spaceXL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
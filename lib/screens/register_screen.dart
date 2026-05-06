import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

// ══════════════════════════════════════════════════════════════════════════════
// REGISTER SCREEN
// ══════════════════════════════════════════════════════════════════════════════

enum _Role { student, mentor }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ── Form key ──────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ───────────────────────────────────────────────────────────
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // ── UI state ──────────────────────────────────────────────────────────────
  bool  _obscurePass    = true;
  bool  _obscureConfirm = true;
  _Role _role           = _Role.student;
  bool  _loading        = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _onRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    // TODO: Replace with your real registration logic
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Welcome, ${_nameCtrl.text.trim()}! Registered as ${_role.name}.',
        ),
        backgroundColor: ClayTokens.brand,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ClayTokens.radiusSM),
        ),
      ),
    );
  }

  // ── Validators ────────────────────────────────────────────────────────────
  String? _nameValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-z]{2,}$');
    if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _confirmValidator(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != _passCtrl.text) return 'Passwords do not match';
    return null;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: ClayTokens.pageBg,
      body: Stack(
        children: [
          // ── Ambient blobs ─────────────────────────────────────────────────
          Align(
            alignment: const Alignment(-1.4, -1.0),
            child: Container(
              width: mq.size.width * 0.62,
              height: mq.size.width * 0.62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ClayTokens.brandMid.withValues(alpha: 0.14),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(1.4, 0.8),
            child: Container(
              width: mq.size.width * 0.40,
              height: mq.size.width * 0.40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ClayTokens.brand.withValues(alpha: 0.09),
              ),
            ),
          ),

          // ── Scrollable form ───────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ClayTokens.spaceMD),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: ClayTokens.spaceLG),

                    // ── Header ─────────────────────────────────────────────
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: ClayTokens.textXXL,
                        fontWeight: FontWeight.w800,
                        color: ClayTokens.textPrimary,
                        letterSpacing: -0.8,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: ClayTokens.spaceXS),
                    Text(
                      'Join Skill Circle Community',
                      style: TextStyle(
                        fontSize: ClayTokens.textBase,
                        color: ClayTokens.textSecond.withValues(alpha: 0.85),
                      ),
                    ),

                    const SizedBox(height: ClayTokens.spaceXL),

                    // ── Full Name ──────────────────────────────────────────
                    const _FieldLabel('Full Name'),
                    const SizedBox(height: ClayTokens.spaceXS),
                    _ClayFormField(
                      controller: _nameCtrl,
                      hint: 'Enter your full name',
                      keyboardType: TextInputType.name,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: _nameValidator,
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: ClayTokens.spaceMD),

                    // ── Email ──────────────────────────────────────────────
                    const _FieldLabel('Email'),
                    const SizedBox(height: ClayTokens.spaceXS),
                    _ClayFormField(
                      controller: _emailCtrl,
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                      validator: _emailValidator,
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: ClayTokens.spaceMD),

                    // ── Password ───────────────────────────────────────────
                    const _FieldLabel('Password'),
                    const SizedBox(height: ClayTokens.spaceXS),
                    _ClayFormField(
                      controller: _passCtrl,
                      hint: 'Enter your password',
                      obscureText: _obscurePass,
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: _obscurePass
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      onSuffixTap: () =>
                          setState(() => _obscurePass = !_obscurePass),
                      validator: _passwordValidator,
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: ClayTokens.spaceMD),

                    // ── Confirm Password ───────────────────────────────────
                    const _FieldLabel('Confirm Password'),
                    const SizedBox(height: ClayTokens.spaceXS),
                    _ClayFormField(
                      controller: _confirmCtrl,
                      hint: 'Re-enter your password',
                      obscureText: _obscureConfirm,
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      onSuffixTap: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: _confirmValidator,
                      textInputAction: TextInputAction.done,
                    ),

                    const SizedBox(height: ClayTokens.spaceLG),

                    // ── Role selection ─────────────────────────────────────
                    const _FieldLabel('Select Role'),
                    const SizedBox(height: ClayTokens.spaceSM),
                    Row(
                      children: [
                        Expanded(
                          child: _RoleOption(
                            label: 'Student',
                            icon: Icons.school_rounded,
                            selected: _role == _Role.student,
                            onTap: () => setState(() => _role = _Role.student),
                          ),
                        ),
                        const SizedBox(width: ClayTokens.spaceSM),
                        Expanded(
                          child: _RoleOption(
                            label: 'Mentor',
                            icon: Icons.workspace_premium_rounded,
                            selected: _role == _Role.mentor,
                            onTap: () => setState(() => _role = _Role.mentor),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: ClayTokens.spaceXL),

                    // ── Register button ────────────────────────────────────
                    _RegisterButton(
                      loading: _loading,
                      onTap: _onRegister,
                    ),

                    const SizedBox(height: ClayTokens.spaceMD),

                    // ── Login link ─────────────────────────────────────────
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // TODO: Navigator.pushReplacement → LoginScreen
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: ClayTokens.brand,
                          padding: const EdgeInsets.symmetric(
                            horizontal: ClayTokens.spaceMD,
                            vertical: ClayTokens.spaceSM,
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: ClayTokens.textSM,
                              color: ClayTokens.textSecond
                                  .withValues(alpha: 0.85),
                            ),
                            children: const [
                              TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  color: ClayTokens.brand,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: ClayTokens.spaceMD),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FIELD LABEL
// ══════════════════════════════════════════════════════════════════════════════
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: ClayTokens.textSM,
        fontWeight: FontWeight.w700,
        color: ClayTokens.textPrimary,
        letterSpacing: 0.2,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CLAY FORM FIELD
// ══════════════════════════════════════════════════════════════════════════════

/// A clay-styled [TextFormField] that uses [ClayTokens] throughout.
class _ClayFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?) validator;
  final TextInputAction textInputAction;

  const _ClayFormField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    required this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.onSuffixTap,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Clay shadow wraps the field
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ClayTokens.radiusSM),
        boxShadow: ClayTokens.clayField,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,
        style: const TextStyle(
          fontSize: ClayTokens.textBase,
          color: ClayTokens.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: ClayTokens.textBase,
            color: ClayTokens.textHint,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: ClayTokens.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ClayTokens.spaceMD,
            vertical: ClayTokens.spaceMD,
          ),
          prefixIcon: Icon(
            prefixIcon,
            size: 20,
            color: ClayTokens.brandLight,
          ),
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Icon(
                    suffixIcon,
                    size: 20,
                    color: ClayTokens.brandLight,
                  ),
                )
              : null,
          // ── Borders pulled from ClayTokens ────────────────────────────────
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ClayTokens.radiusSM),
            borderSide: BorderSide(
              color: ClayTokens.brandLight.withValues(alpha: 0.55),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ClayTokens.radiusSM),
            borderSide: const BorderSide(
              color: ClayTokens.brand,
              width: 2.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ClayTokens.radiusSM),
            borderSide: const BorderSide(
              color: ClayTokens.error,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ClayTokens.radiusSM),
            borderSide: const BorderSide(
              color: ClayTokens.error,
              width: 2.0,
            ),
          ),
          errorStyle: const TextStyle(
            fontSize: ClayTokens.textXS + 1,
            color: ClayTokens.error,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ROLE OPTION CARD
// ══════════════════════════════════════════════════════════════════════════════
class _RoleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 54,
        decoration: BoxDecoration(
          color: selected ? ClayTokens.brandPale : ClayTokens.surface,
          borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
          border: Border.all(
            color: selected
                ? ClayTokens.brand
                : ClayTokens.brandLight.withValues(alpha: 0.55),
            width: selected ? 2.0 : 1.5,
          ),
          boxShadow: ClayTokens.clayShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Radio circle indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      selected ? ClayTokens.brand : ClayTokens.textHint,
                  width: 2.0,
                ),
                color: selected ? ClayTokens.brand : ClayTokens.surface,
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 11, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: ClayTokens.spaceSM),
            Icon(
              icon,
              size: 18,
              color: selected ? ClayTokens.brand : ClayTokens.textHint,
            ),
            const SizedBox(width: ClayTokens.spaceXS),
            Text(
              label,
              style: TextStyle(
                fontSize: ClayTokens.textSM,
                fontWeight: FontWeight.w700,
                color: selected
                    ? ClayTokens.brandDeep
                    : ClayTokens.textSecond,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// REGISTER BUTTON
// ══════════════════════════════════════════════════════════════════════════════
class _RegisterButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _RegisterButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: ClayTokens.buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
        // Clay button glow from tokens
        boxShadow: ClayTokens.clayButton,
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: ClayTokens.brand,
          disabledBackgroundColor: ClayTokens.brandLight,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Register',
                style: TextStyle(
                  fontSize: ClayTokens.textBase,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
      ),
    );
  }
}
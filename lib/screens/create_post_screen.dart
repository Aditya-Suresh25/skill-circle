import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Create Post Screen
// ─────────────────────────────────────────────────────────────────────────────
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key, this.circleId});

  final String? circleId;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _contentCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _publishPost() {
    // Basic empty field validation check
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with publishing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Publishing your post...'),
          backgroundColor: ClayTokens.brandMid,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
          ),
        ),
      );
      
      // TODO: Add backend submission logic here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClayTokens.pageBg,

      // ── AppBar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: ClayTokens.pageBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ClayTokens.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create Post',
          style: TextStyle(
            fontSize: ClayTokens.textLG,
            fontWeight: FontWeight.w800,
            color: ClayTokens.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),

      // ── Body ────────────────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // Required Padding: 16
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title Field ─────────────────────────────────────────────
              const Text(
                'Title',
                style: TextStyle(
                  fontSize: ClayTokens.textSM,
                  fontWeight: FontWeight.w700,
                  color: ClayTokens.textSecond,
                ),
              ),
              const SizedBox(height: ClayTokens.spaceSM),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
                  boxShadow: ClayTokens.clayShadow,
                ),
                child: TextFormField(
                  controller: _titleCtrl,
                  style: const TextStyle(
                    fontSize: ClayTokens.textBase,
                    color: ClayTokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: _inputDecoration('Enter an engaging title...'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title for your post';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: ClayTokens.spaceLG),

              // ── Content Field ───────────────────────────────────────────
              const Text(
                'Content',
                style: TextStyle(
                  fontSize: ClayTokens.textSM,
                  fontWeight: FontWeight.w700,
                  color: ClayTokens.textSecond,
                ),
              ),
              const SizedBox(height: ClayTokens.spaceSM),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
                  boxShadow: ClayTokens.clayShadow,
                ),
                child: TextFormField(
                  controller: _contentCtrl,
                  maxLines: 10,
                  minLines: 6,
                  style: const TextStyle(
                    fontSize: ClayTokens.textBase,
                    color: ClayTokens.textPrimary,
                    height: 1.5,
                  ),
                  decoration: _inputDecoration('What do you want to share with the circle?'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Post content cannot be empty';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: ClayTokens.spaceLG),

              // ── Media Attachment Buttons ────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _MediaButton(
                      icon: Icons.image_outlined,
                      label: 'Add Image',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: ClayTokens.spaceMD),
                  Expanded(
                    child: _MediaButton(
                      icon: Icons.attach_file_rounded,
                      label: 'Upload File',
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: ClayTokens.spaceXL * 1.5),

              // ── Publish Button (Full Width) ─────────────────────────────
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _publishPost,
                  child: Container(
                    height: ClayTokens.buttonHeight,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [ClayTokens.brandDeep, ClayTokens.brand, ClayTokens.brandMid],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
                      boxShadow: ClayTokens.clayButton,
                    ),
                    child: const Center(
                      child: Text(
                        'Publish Post',
                        style: TextStyle(
                          fontSize: ClayTokens.textLG,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: ClayTokens.spaceXL), // Bottom breathing room
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper method for shared text field styling ──
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: ClayTokens.textHint, fontSize: ClayTokens.textBase),
      filled: true,
      fillColor: ClayTokens.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ClayTokens.spaceMD,
        vertical: ClayTokens.spaceMD,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ClayTokens.radiusMD), // Rounded TextFields
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(color: ClayTokens.error, fontWeight: FontWeight.w500),
      // Adding a subtle red border when validation fails
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
        borderSide: BorderSide(color: ClayTokens.error.withValues(alpha: 0.5), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
        borderSide: const BorderSide(color: ClayTokens.error, width: 2),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Media Button Component
// ─────────────────────────────────────────────────────────────────────────────
class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: ClayTokens.brandPale,
          borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
          border: Border.all(
            color: ClayTokens.brandLight.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: ClayTokens.brand),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: ClayTokens.textSM,
                fontWeight: FontWeight.w700,
                color: ClayTokens.brand,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Standalone Testing Entry Point
// ─────────────────────────────────────────────────────────────────────────────
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const CreatePostScreen(),
  ));
}
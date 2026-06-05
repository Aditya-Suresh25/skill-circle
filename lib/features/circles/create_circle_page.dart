import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skill_circle_app/core/appwrite.dart';
import 'package:skill_circle_app/core/widgets/glass.dart';
import 'package:skill_circle_app/features/circles/circles_page.dart';

class CreateCirclePage extends ConsumerStatefulWidget {
  const CreateCirclePage({super.key});

  @override
  ConsumerState<CreateCirclePage> createState() => _CreateCirclePageState();
}

class _CreateCirclePageState extends ConsumerState<CreateCirclePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  Uint8List? _avatarBytes;
  String? _avatarName;
  String? _avatarMime;

  Uint8List? _bannerBytes;
  String? _bannerName;
  String? _bannerMime;

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isBanner) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: isBanner ? 1024 : 512,
        maxHeight: isBanner ? 512 : 512,
        imageQuality: 75,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      setState(() {
        if (isBanner) {
          _bannerBytes = bytes;
          _bannerName = image.name;
          _bannerMime = image.mimeType ?? 'image/jpeg';
        } else {
          _avatarBytes = bytes;
          _avatarName = image.name;
          _avatarMime = image.mimeType ?? 'image/jpeg';
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final service = ref.read(appwriteServiceProvider);
      String? avatarUrl;
      String? bannerUrl;

      // Upload files if picked
      if (_avatarBytes != null) {
        final att = await service.uploadFile(_avatarBytes!, _avatarName!, _avatarMime!, user.id);
        avatarUrl = att.url;
      }
      if (_bannerBytes != null) {
        final att = await service.uploadFile(_bannerBytes!, _bannerName!, _bannerMime!, user.id);
        bannerUrl = att.url;
      }

      // Create Circle
      await service.createCircle(
        _nameController.text.trim(),
        _descController.text.trim(),
        user.id,
        imageUrl: avatarUrl,
        bannerUrl: bannerUrl,
      );

      // Refresh session (joins the circle as creator)
      await ref.read(currentUserProvider.notifier).checkSession();
      ref.invalidate(circlesListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Skill Circle created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create circle: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Circle', style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
      ),
      body: AuroraBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner Selector
                GestureDetector(
                  onTap: () => _pickImage(true),
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.4),
                      image: _bannerBytes != null ? DecorationImage(image: MemoryImage(_bannerBytes!), fit: BoxFit.cover) : null,
                    ),
                    child: _bannerBytes == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded, size: 36, color: Colors.white.withValues(alpha: 0.40)),
                              const SizedBox(height: 8),
                              Text(
                                'Add Banner Image',
                                style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withValues(alpha: 0.50)),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Avatar Selector
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFC084FC), width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          backgroundImage: _avatarBytes != null ? MemoryImage(_avatarBytes!) : null,
                          child: _avatarBytes == null
                              ? const Icon(Icons.group_rounded, size: 48, color: Colors.white)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _pickImage(false),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B5CF6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Form Fields Card
                GlassPanel(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Circle Name',
                          prefixIcon: Icon(Icons.title_rounded, color: Color(0xFF9A9AAE)),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Enter circle name' : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _descController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description_outlined, color: Color(0xFF9A9AAE)),
                          alignLabelWithHint: true,
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Enter circle description' : null,
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)),
                              )
                            : Text('Create Circle', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skill_circle_app/features/skill_circles/presentation/providers/skill_circles_providers.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

class CreateCircleScreen extends ConsumerStatefulWidget {
  const CreateCircleScreen({super.key});

  @override
  ConsumerState<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends ConsumerState<CreateCircleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _hasAttemptedSubmit = false;

  PlatformFile? _pfpFile;
  PlatformFile? _bannerFile;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickBanner() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null) {
      setState(() {
        _bannerFile = result.files.first;
      });
    }
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null) {
      setState(() {
        _pfpFile = result.files.first;
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _hasAttemptedSubmit = true);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(createCircleControllerProvider.notifier).createCircle(
          name: _nameController.text,
          description: _descriptionController.text,
          pfpFile: _pfpFile,
          bannerFile: _bannerFile,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(createCircleControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (previous?.isLoading ?? false) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Skill circle created successfully')),
            );
            if (context.mounted) {
              context.pop(true);
            }
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    final state = ref.watch(createCircleControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Skill Circle'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Start a new learning space for your community.',
                  style: TextStyle(
                    color: ClayTokens.textSecond,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Image Pickers Section
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Banner
                    GestureDetector(
                      onTap: _pickBanner,
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 40),
                        decoration: BoxDecoration(
                          color: ClayTokens.pageBg,
                          borderRadius: BorderRadius.circular(16),
                          image: _bannerFile?.bytes != null
                              ? DecorationImage(
                                  image: MemoryImage(_bannerFile!.bytes!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _bannerFile == null
                            ? const Center(
                                child: Icon(Icons.add_photo_alternate_rounded, size: 40, color: Colors.white54),
                              )
                            : null,
                      ),
                    ),
                    
                    // Avatar
                    Positioned(
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _pickAvatar,
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: ClayTokens.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: ClayTokens.pageBg, width: 4),
                            image: _pfpFile?.bytes != null
                                ? DecorationImage(
                                    image: MemoryImage(_pfpFile!.bytes!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _pfpFile == null
                              ? Icon(Icons.camera_alt_rounded, size: 30, color: ClayTokens.brand)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Circle Name',
                    hintText: 'e.g. Flutter Builders',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Circle name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe what this circle is about...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'Description is required';
                    }
                    if (text.length < 10) {
                      return 'Description must be at least 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_hasAttemptedSubmit && state.hasError) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      state.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Circle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
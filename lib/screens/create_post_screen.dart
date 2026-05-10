import 'package:flutter/material.dart';
import 'package:skill_circle_app/features/posts/presentation/widgets/post_composer.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClayTokens.pageBg,
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: widget.circleId == null
              ? const Center(
                  child: Text('Open a circle to create a media-enabled post.'),
                )
              : PostComposer(circleId: widget.circleId),
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
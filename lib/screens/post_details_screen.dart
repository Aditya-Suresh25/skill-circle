import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────────────────────────────────────
class PostDetailData {
  final String title;
  final String username;
  final String userAvatarName;
  final String content;
  final String? attachedFileName;
  final String timeAgo;

  PostDetailData({
    required this.title,
    required this.username,
    required this.userAvatarName,
    required this.content,
    this.attachedFileName,
    required this.timeAgo,
  });
}

class CommentData {
  final String username;
  final String userAvatarName;
  final String text;
  final String timeAgo;

  CommentData({
    required this.username,
    required this.userAvatarName,
    required this.text,
    required this.timeAgo,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Sample Data
// ─────────────────────────────────────────────────────────────────────────────
final PostDetailData _samplePost = PostDetailData(
  title: 'Best architecture for a new app?',
  username: 'Sarah Jenkins',
  userAvatarName: 'Sarah',
  content: 'I am starting a new scalable project and wondering if Riverpod + Clean Architecture is still the way to go in 2026, or if there are newer patterns worth exploring. I have attached my current folder structure draft below. Would love to hear your thoughts!',
  attachedFileName: 'architecture_draft_v2.pdf',
  timeAgo: '2 hours ago',
);

final List<CommentData> _sampleComments = [
  CommentData(
    username: 'Marcus Doe',
    userAvatarName: 'Marcus',
    text: 'Riverpod is definitely still a solid choice. I pair it with a feature-first folder structure rather than layer-first. Makes scaling much easier.',
    timeAgo: '1 hr ago',
  ),
  CommentData(
    username: 'Elena R.',
    userAvatarName: 'Elena',
    text: 'I checked your PDF. Looks good, but be careful not to over-engineer the domain layer if the app is heavily CRUD-based!',
    timeAgo: '45 mins ago',
  ),
  CommentData(
    username: 'Alex Chen',
    userAvatarName: 'Alex',
    text: 'Have you considered looking into the new built-in state management tools introduced recently? Might save you an external dependency.',
    timeAgo: '10 mins ago',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Post Details Screen
// ─────────────────────────────────────────────────────────────────────────────
class PostDetailsScreen extends StatefulWidget {
  final String? postId;

  const PostDetailsScreen({super.key, this.postId});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final TextEditingController _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _sendComment() {
    if (_commentCtrl.text.trim().isNotEmpty) {
      // TODO: Handle comment submission
      FocusScope.of(context).unfocus();
      _commentCtrl.clear();
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
        title: Text(
          _samplePost.title,
          style: const TextStyle(
            fontSize: ClayTokens.textLG,
            fontWeight: FontWeight.w800,
            color: ClayTokens.textPrimary,
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      // ── Body ────────────────────────────────────────────────────────────
      body: Column(
        children: [
          // Scrollable Post and Comments
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: ClayTokens.spaceMD, vertical: ClayTokens.spaceSM),
              children: [
                // 1. Main Post Card
                _buildPostCard(),
                
                const SizedBox(height: ClayTokens.spaceLG),
                
                // 2. Comments Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: ClayTokens.spaceXS),
                  child: Text(
                    'Comments (${_sampleComments.length})',
                    style: const TextStyle(
                      fontSize: ClayTokens.textLG,
                      fontWeight: FontWeight.w800,
                      color: ClayTokens.textPrimary,
                    ),
                  ),
                ),
                
                const SizedBox(height: ClayTokens.spaceMD),
                
                // 3. Comments List
                ..._sampleComments.map((comment) => _buildCommentItem(comment)),
              ],
            ),
          ),
          
          // ── Bottom Comment Input Anchored to Keyboard ───────────────────
          _buildCommentInputBox(),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Component Builders
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildPostCard() {
    return Container(
      padding: const EdgeInsets.all(ClayTokens.spaceLG),
      decoration: BoxDecoration(
        color: ClayTokens.surface,
        borderRadius: BorderRadius.circular(ClayTokens.radiusLG),
        boxShadow: ClayTokens.clayShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Row(
            children: [
              _Avatar(name: _samplePost.userAvatarName, size: 44),
              const SizedBox(width: ClayTokens.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _samplePost.username,
                      style: const TextStyle(
                        fontSize: ClayTokens.textBase,
                        fontWeight: FontWeight.w700,
                        color: ClayTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _samplePost.timeAgo,
                      style: const TextStyle(
                        fontSize: ClayTokens.textXS,
                        fontWeight: FontWeight.w500,
                        color: ClayTokens.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz_rounded, color: ClayTokens.textHint),
            ],
          ),
          
          const SizedBox(height: ClayTokens.spaceLG),
          
          // Post Content
          Text(
            _samplePost.content,
            style: TextStyle(
              fontSize: ClayTokens.textBase,
              color: ClayTokens.textPrimary.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),
          
          // Attached File Section (if any)
          if (_samplePost.attachedFileName != null) ...[
            const SizedBox(height: ClayTokens.spaceLG),
            Container(
              padding: const EdgeInsets.all(ClayTokens.spaceSM),
              decoration: BoxDecoration(
                color: ClayTokens.brandPale,
                borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
                border: Border.all(color: ClayTokens.brandLight.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: ClayTokens.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, size: 18, color: ClayTokens.brand),
                  ),
                  const SizedBox(width: ClayTokens.spaceSM),
                  Expanded(
                    child: Text(
                      _samplePost.attachedFileName!,
                      style: const TextStyle(
                        fontSize: ClayTokens.textSM,
                        fontWeight: FontWeight.w600,
                        color: ClayTokens.brandDeep,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.download_rounded, size: 20, color: ClayTokens.brand),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentData comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: ClayTokens.spaceMD),
      padding: const EdgeInsets.all(ClayTokens.spaceMD),
      decoration: BoxDecoration(
        color: ClayTokens.surface,
        borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
        boxShadow: ClayTokens.clayShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(name: comment.userAvatarName, size: 36),
          const SizedBox(width: ClayTokens.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(
                        fontSize: ClayTokens.textSM,
                        fontWeight: FontWeight.w700,
                        color: ClayTokens.textPrimary,
                      ),
                    ),
                    Text(
                      comment.timeAgo,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: ClayTokens.textHint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.text,
                  style: TextStyle(
                    fontSize: ClayTokens.textSM,
                    color: ClayTokens.textSecond.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInputBox() {
    return Container(
      decoration: BoxDecoration(
        color: ClayTokens.pageBg,
        boxShadow: [
          BoxShadow(
            color: ClayTokens.brandLight.withValues(alpha: 0.15),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: ClayTokens.spaceMD, vertical: ClayTokens.spaceSM),
          child: Row(
            children: [
              // Avatar for the active user typing
              const _Avatar(name: 'My Profile', size: 40),
              const SizedBox(width: ClayTokens.spaceSM),
              
              // Input Field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: ClayTokens.surface,
                    borderRadius: BorderRadius.circular(ClayTokens.radiusFull),
                    boxShadow: ClayTokens.clayField,
                  ),
                  child: TextField(
                    controller: _commentCtrl,
                    maxLines: 3,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendComment(),
                    style: const TextStyle(fontSize: ClayTokens.textSM, color: ClayTokens.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: ClayTokens.textHint),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: ClayTokens.spaceSM),
              
              // Send Button
              GestureDetector(
                onTap: _sendComment,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [ClayTokens.brand, ClayTokens.brandMid],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: ClayTokens.clayButton,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Avatar Utility (DRY)
// ─────────────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String name;
  final double size;

  const _Avatar({required this.name, required this.size});

  Color _accentFromName(String name) {
    const accents = [
      Color(0xFF7C3AED), Color(0xFF8B5CF6), Color(0xFF6D28D9),
      Color(0xFF9333EA), Color(0xFF7E22CE), Color(0xFFA855F7),
    ];
    final idx = name.codeUnits.fold(0, (a, b) => a + b) % accents.length;
    return accents[idx];
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentFromName(name);
    final initials = name.trim().isEmpty 
        ? '?' 
        : name.trim().substring(0, 1).toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.12),
        boxShadow: ClayTokens.clayAvatar,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w800,
            color: accent,
          ),
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
    home: const PostDetailsScreen(),
  ));
}
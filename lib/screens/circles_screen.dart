import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';
// Importing the bento card from utils to keep things DRY
import 'package:skill_circle_app/widgets/circle_card.dart'; 

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────
class CircleData {
  final String name;
  final String subtitle;
  final int members;
  final IconData icon;
  final Color iconColor;
  bool joined;

  CircleData({
    required this.name,
    required this.subtitle,
    required this.members,
    required this.icon,
    required this.iconColor,
    this.joined = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Sample data
// ─────────────────────────────────────────────────────────────────────────────
final List<CircleData> _allCircles = [
  CircleData(name: 'Web Development',  subtitle: 'HTML, CSS, JS & beyond', members: 4821, icon: Icons.code_rounded,        iconColor: ClayTokens.brand),
  CircleData(name: 'UI/UX Design',     subtitle: 'Design that delights',   members: 3102, icon: Icons.brush_rounded,        iconColor: ClayTokens.brandMid),
  CircleData(name: 'Machine Learning', subtitle: 'Models, math & magic',   members: 5643, icon: Icons.memory_rounded,       iconColor: ClayTokens.brandDeep),
  CircleData(name: 'Data Science',     subtitle: 'Numbers tell stories',   members: 2987, icon: Icons.bar_chart_rounded,    iconColor: ClayTokens.success),
  CircleData(name: 'iOS Development',  subtitle: 'Swift & SwiftUI circle', members: 1834, icon: Icons.phone_iphone_rounded, iconColor: ClayTokens.brandLight),
  CircleData(name: 'Flutter & Dart',   subtitle: 'Cross-platform magic',   members: 3471, icon: Icons.flutter_dash,         iconColor: ClayTokens.brand),
  CircleData(name: 'Cloud & DevOps',   subtitle: 'Ship fast, scale smart', members: 2214, icon: Icons.cloud_rounded,        iconColor: ClayTokens.textSecond),
  CircleData(name: 'Cybersecurity',    subtitle: 'Stay safe, stay sharp',  members: 1659, icon: Icons.shield_rounded,       iconColor: ClayTokens.error),
  CircleData(name: 'Open Source',      subtitle: 'Build for the world',    members: 6012, icon: Icons.public_rounded,       iconColor: ClayTokens.brand),
  CircleData(name: 'Product Thinking', subtitle: 'Strategy meets craft',   members: 1389, icon: Icons.lightbulb_rounded,    iconColor: ClayTokens.brandMid),
];

// ─────────────────────────────────────────────────────────────────────────────
// CirclesScreen
// ─────────────────────────────────────────────────────────────────────────────
class CirclesScreen extends StatefulWidget {
  const CirclesScreen({super.key});

  @override
  State<CirclesScreen> createState() => _CirclesScreenState();
}

class _CirclesScreenState extends State<CirclesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<CircleData> _visible = List.from(_allCircles);

  void _onSearch(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      _visible = q.isEmpty
          ? List.from(_allCircles)
          : _allCircles
              .where((c) =>
                  c.name.toLowerCase().contains(q) ||
                  c.subtitle.toLowerCase().contains(q))
              .toList();
    });
  }

  void _toggleJoin(int idx) => setState(() => _visible[idx].joined = !_visible[idx].joined);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
        centerTitle: false,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
        title: Row(
          children: [
            // Logo badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ClayTokens.brand, ClayTokens.brandMid],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(ClayTokens.radiusSM),
                boxShadow: ClayTokens.clayButton,
              ),
              child: const Icon(Icons.hub_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: ClayTokens.spaceSM + 4),
            const Text(
              'Skill Circles',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: ClayTokens.textXL,
                fontWeight: FontWeight.w700,
                color: ClayTokens.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Notification bell
          Container(
            margin: const EdgeInsets.only(right: ClayTokens.spaceMD),
            decoration: BoxDecoration(
              color: ClayTokens.surface,
              borderRadius: BorderRadius.circular(ClayTokens.radiusSM),
              boxShadow: ClayTokens.clayShadow,
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: ClayTokens.textSecond, size: 22),
              onPressed: () {},
            ),
          ),
        ],
      ),

      // ── Body ────────────────────────────────────────────────────────────
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: ClayTokens.spaceXS),

          // ── Header blurb ──────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: ClayTokens.spaceMD),
            child: Text(
              'Find your people. Level up together.',
              style: TextStyle(
                fontSize: ClayTokens.textSM,
                color: ClayTokens.textSecond,
                letterSpacing: 0.1,
              ),
            ),
          ),

          const SizedBox(height: ClayTokens.spaceMD),

          // ── Search bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ClayTokens.spaceMD),
            child: _SearchBar(controller: _searchCtrl, onChanged: _onSearch),
          ),

          const SizedBox(height: ClayTokens.spaceMD),

          // ── Count label ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ClayTokens.spaceMD),
            child: Text(
              '${_visible.length} circles',
              style: const TextStyle(
                fontSize: ClayTokens.textSM,
                fontWeight: FontWeight.w600,
                color: ClayTokens.textHint,
                letterSpacing: 0.4,
              ),
            ),
          ),

          const SizedBox(height: ClayTokens.spaceSM),

          // ── Grid Layout for Bento Cards ───────────────────────────────
          Expanded(
            child: _visible.isEmpty
                ? _EmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      ClayTokens.spaceMD,
                      4,
                      ClayTokens.spaceMD,
                      100, // Extra bottom padding so the FAB doesn't cover cards
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: ClayTokens.spaceMD,
                      mainAxisSpacing: ClayTokens.spaceMD,
                      childAspectRatio: 0.85, // Perfect ratio for the square bento look
                    ),
                    itemCount: _visible.length,
                    itemBuilder: (ctx, i) {
                      final data = _visible[i];
                      
                      // Using the BentoCircleCard from circle_card.dart
                      return BentoCircleCard(
                        circleName: data.name,
                        memberCount: data.members,
                        // Extracting a short tag from the subtitle for the UI
                        tag: data.subtitle.split(' ').first,
                        joined: data.joined,
                        onJoin: () => _toggleJoin(i),
                      );
                    },
                  ),
          ),
        ],
      ),

      // ── FAB ─────────────────────────────────────────────────────────────
      floatingActionButton: _ClayFAB(
        onTap: () {},
        label: 'Create Circle',
        icon: Icons.add_rounded,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Bar
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: ClayTokens.surface,
        borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
        boxShadow: ClayTokens.clayShadow,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: ClayTokens.textBase,
          color: ClayTokens.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search circles…',
          hintStyle: const TextStyle(
            color: ClayTokens.textHint,
            fontSize: ClayTokens.textBase,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: ClayTokens.textHint,
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    color: ClayTokens.textHint,
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: ClayTokens.brandPale,
              shape: BoxShape.circle,
              boxShadow: ClayTokens.clayShadow,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: ClayTokens.brandLight,
              size: 36,
            ),
          ),
          const SizedBox(height: ClayTokens.spaceMD),
          const Text(
            'No circles found',
            style: TextStyle(
              fontSize: ClayTokens.textLG,
              fontWeight: FontWeight.w700,
              color: ClayTokens.textPrimary,
            ),
          ),
          const SizedBox(height: ClayTokens.spaceXS),
          const Text(
            'Try a different keyword',
            style: TextStyle(
              fontSize: ClayTokens.textBase,
              color: ClayTokens.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Clay FAB
// ─────────────────────────────────────────────────────────────────────────────
class _ClayFAB extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;

  const _ClayFAB({required this.onTap, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: ClayTokens.spaceLG),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ClayTokens.brandDeep, ClayTokens.brand, ClayTokens.brandMid],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(ClayTokens.radiusFull),
          boxShadow: [
            BoxShadow(
              color: ClayTokens.brand.withValues(alpha: 0.45),
              offset: const Offset(0, 8),
              blurRadius: 20,
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.25),
              offset: const Offset(0, -1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: ClayTokens.spaceSM),
            Text(
              label,
              style: const TextStyle(
                fontSize: ClayTokens.textBase,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point (for standalone testing)
// ─────────────────────────────────────────────────────────────────────────────
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CirclesScreen(),
  ));
}
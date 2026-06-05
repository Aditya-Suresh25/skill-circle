import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_circle_app/core/appwrite.dart';
import 'package:skill_circle_app/core/widgets/glass.dart';
import 'package:skill_circle_app/models/circle.dart';

// Providers for loading circles list
final circlesListProvider = FutureProvider.autoDispose<List<SkillCircle>>((ref) async {
  final service = ref.watch(appwriteServiceProvider);
  return service.getCircles();
});

class CirclesPage extends ConsumerStatefulWidget {
  const CirclesPage({super.key});

  @override
  ConsumerState<CirclesPage> createState() => _CirclesPageState();
}

class _CirclesPageState extends ConsumerState<CirclesPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circlesAsync = ref.watch(circlesListProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-circle'),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('Create Circle', style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
      ),
      body: AuroraBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover Circles',
                      style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Connect and grow with others in specialised circles',
                      style: GoogleFonts.outfit(fontSize: 15, color: Colors.white.withValues(alpha: 0.65)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.toLowerCase().trim();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search circles...',
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF9A9AAE)),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                icon: const Icon(Icons.clear_rounded, color: Color(0xFF9A9AAE)),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: circlesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFC084FC)))),
                  error: (err, _) => Center(child: Text('Error loading circles: $err', style: const TextStyle(color: Colors.white))),
                  data: (circles) {
                    final filtered = circles.where((c) {
                      return c.circleName.toLowerCase().contains(_searchQuery) ||
                          c.description.toLowerCase().contains(_searchQuery);
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bubble_chart_outlined, size: 64, color: Colors.white.withValues(alpha: 0.25)),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isEmpty ? 'No circles found' : 'No matches for "$_searchQuery"',
                              style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.50)),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final circle = filtered[index];
                        final isJoined = user != null && circle.members.contains(user.id);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: GlassPanel(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 54,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFFC084FC).withValues(alpha: 0.30)),
                                        image: circle.imageUrl != null
                                            ? DecorationImage(image: NetworkImage(circle.imageUrl!), fit: BoxFit.cover)
                                            : null,
                                        color: Colors.white.withValues(alpha: 0.10),
                                      ),
                                      child: circle.imageUrl == null
                                          ? const Icon(Icons.group_rounded, color: Color(0xFFC084FC), size: 28)
                                          : null,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            circle.circleName,
                                            style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.people_outline_rounded, size: 14, color: Colors.white.withValues(alpha: 0.50)),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${circle.memberCount} members',
                                                style: GoogleFonts.outfit(fontSize: 12, color: Colors.white.withValues(alpha: 0.50)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  circle.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withValues(alpha: 0.75)),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        context.push('/circle/${circle.circleId}');
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: BorderSide(color: Colors.white.withValues(alpha: 0.20)),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        minimumSize: Size.zero,
                                      ),
                                      child: const Text('View Circle'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (user == null) return;
                                        final service = ref.read(appwriteServiceProvider);
                                        if (isJoined) {
                                          await service.leaveCircle(circle.circleId, user.id);
                                        } else {
                                          await service.joinCircle(circle.circleId, user.id);
                                        }
                                        // Refresh session and circles list
                                        await ref.read(currentUserProvider.notifier).checkSession();
                                        ref.invalidate(circlesListProvider);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isJoined ? Colors.redAccent.withValues(alpha: 0.20) : const Color(0xFF8B5CF6),
                                        foregroundColor: isJoined ? Colors.redAccent : Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        minimumSize: Size.zero,
                                      ),
                                      child: Text(isJoined ? 'Leave' : 'Join'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

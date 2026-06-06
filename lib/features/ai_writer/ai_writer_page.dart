import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_circle_app/core/gemini.dart';
import 'package:skill_circle_app/core/widgets/glass.dart';

class AiWriterPage extends ConsumerStatefulWidget {
  const AiWriterPage({super.key});

  @override
  ConsumerState<AiWriterPage> createState() => _AiWriterPageState();
}

class _AiWriterPageState extends ConsumerState<AiWriterPage> {
  final _textController = TextEditingController();
  String _selectedMode = 'professional'; // 'shorter', 'longer', 'professional', 'friendly', 'engaging', 'grammar'
  String? _rewrittenText;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _transform() async {
    final input = _textController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _rewrittenText = null;
    });

    try {
      final gemini = ref.read(geminiServiceProvider);
      final result = await gemini.rewrite(input, _selectedMode);
      setState(() {
        _rewrittenText = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _copyToClipboard() {
    if (_rewrittenText == null) return;
    Clipboard.setData(ClipboardData(text: _rewrittenText!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modes = {
      'professional': '💼 Professional Tone',
      'friendly': '👋 Friendly & Warm',
      'engaging': '✨ Highly Engaging',
      'shorter': '✂️ Condense & Shorten',
      'longer': '📝 Expand & Elaborate',
      'grammar': '🔍 Fix Grammar & Spelling',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('AI Writer', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
      ),
      body: AuroraBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'AI Writing Assistant',
                style: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Draft and refine your circle posts, channel messages, or bios using Gemini AI.',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.60)),
              ),
              const SizedBox(height: 24),

              // Input Box Card
              GradientPanel(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _textController,
                      maxLines: 5,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter your rough draft here...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.40)),
                        fillColor: Colors.white.withValues(alpha: 0.04),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedMode,
                      dropdownColor: Colors.grey.shade900,
                      decoration: const InputDecoration(
                        labelText: 'Transform Mode',
                        prefixIcon: Icon(Icons.tune_rounded),
                      ),
                      items: modes.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedMode = val);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _transform,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                            )
                          : const Icon(Icons.auto_awesome_rounded),
                      label: Text('Transform Draft', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Output Container
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.40)),
                  ),
                  child: Text(_errorMessage!, style: GoogleFonts.inter(color: Theme.of(context).colorScheme.error)),
                ),
              ],

              if (_rewrittenText != null)
                GradientPanel(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Optimised Output',
                            style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          IconButton(
                            onPressed: _copyToClipboard,
                            icon: Icon(Icons.copy_all_rounded, color: Theme.of(context).colorScheme.secondary),
                            tooltip: 'Copy Output',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      SelectableText(
                        _rewrittenText!,
                        style: GoogleFonts.inter(fontSize: 15, height: 1.5, color: Colors.white.withValues(alpha: 0.90)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

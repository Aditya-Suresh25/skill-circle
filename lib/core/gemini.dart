import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  return GeminiService(apiKey);
});

class GeminiService {
  GeminiService(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.7,
            maxOutputTokens: 1000,
          ),
          systemInstruction: Content.system('''
You are Skill Circle AI Writer.
Your purpose is to help users create professional, engaging, and community-friendly content.
Rules:
- Preserve user intent.
- Be highly articulate and complete your thoughts.
- Sound human and natural.
- Format with clear paragraphs or bullet points for readability.
- Do not abruptly cut off sentences.
- Output ONLY the requested content. Do NOT include conversational filler, introductory phrases (e.g., "Here is the text", "Here are some options"), or concluding remarks.
'''),
        );

  final GenerativeModel _model;

  Future<String> improvePost(String input) async {
    _validateInput(input);
    final prompt = 'Improve this post for clarity, grammar, and engagement. Keep the original intent and tone intact:\n\n$input';
    return _generate(prompt);
  }

  Future<String> generateCaption(String description, String tone) async {
    _validateInput(description);
    final prompt = 'Create an engaging caption with a $tone tone based on this description:\n\n$description';
    return _generate(prompt);
  }

  Future<String> generateIcebreaker(String theme) async {
    _validateInput(theme);
    final prompt = 'Generate 2-3 engaging, conversational icebreakers/discussion starters for a community circle about: $theme';
    return _generate(prompt);
  }

  Future<String> generateBio({required String skills, required String interests}) async {
    if (skills.trim().isEmpty && interests.trim().isEmpty) {
      throw ArgumentError('Please provide skills or interests to generate a bio.');
    }
    final prompt = 'Create a short, professional, and friendly bio using these skills: "$skills" and interests: "$interests".';
    return _generate(prompt);
  }

  Future<String> generateAnnouncement({required String topic, required String details}) async {
    _validateInput(topic);
    final prompt = 'Draft a clean, professional, and inspiring community announcement about "$topic" using these details:\n\n$details';
    return _generate(prompt);
  }

  Future<String> rewrite(String input, String mode) async {
    _validateInput(input);
    String instructions = '';
    switch (mode.toLowerCase()) {
      case 'shorter':
        instructions = 'Make the following writing much shorter and direct, keeping the key message.';
        break;
      case 'longer':
        instructions = 'Elaborate slightly on the writing, adding helpful clarity without adding extra fluff.';
        break;
      case 'professional':
        instructions = 'Rewrite the writing in a polished, professional, and business-friendly tone.';
        break;
      case 'friendly':
        instructions = 'Rewrite the writing in a warm, welcoming, friendly, and approachable tone.';
        break;
      case 'engaging':
        instructions = 'Rewrite the writing to be more engaging, interesting, and exciting.';
        break;
      case 'grammar':
        instructions = 'Fix all grammar, punctuation, and spelling errors in the writing.';
        break;
      default:
        instructions = 'Improve the quality of this writing.';
    }

    final prompt = '$instructions\n\n$input';
    return _generate(prompt);
  }

  Future<String> generateCircleIdeas(String circleName, String description) async {
    final prompt = 'Generate 3 interactive project/learning ideas and 3 icebreaker topics for a skill circle called "$circleName" with this description: "$description".';
    return _generate(prompt);
  }

  void _validateInput(String input) {
    if (input.trim().isEmpty) {
      throw ArgumentError('Input text cannot be empty.');
    }
  }

  Future<String> _generate(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        throw Exception('Gemini generated an empty response.');
      }
      return text.trim();
    } catch (e) {
      if (e.toString().contains('API_KEY_INVALID')) {
        throw Exception('Invalid Gemini API Key. Please verify your configuration.');
      }
      throw Exception('Failed to generate content: ${e.toString()}');
    }
  }
}

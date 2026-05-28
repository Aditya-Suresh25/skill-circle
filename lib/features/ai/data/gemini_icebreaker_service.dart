import 'dart:convert';

import 'package:http/http.dart' as http;

class GeminiIcebreakerService {
  const GeminiIcebreakerService({this.model = 'gemini-1.5-flash'});

  final String model;

  Future<List<String>> generateIcebreakers({
    required String apiKey,
    required String communityTopic,
    required List<String> userInterests,
  }) async {
    final topic = communityTopic.trim();
    final interests = _normalizeInterests(userInterests);
    final fallback = _fallbackQuestions(topic: topic, interests: interests);

    if (apiKey.trim().isEmpty || topic.isEmpty) {
      return fallback;
    }

    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$model:generateContent',
      {'key': apiKey.trim()},
    );

    final prompt = _buildPrompt(topic: topic, interests: interests);

    try {
      final response = await http.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(<String, Object?>{
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': <String, Object?>{
            'temperature': 0.6,
            'topP': 0.9,
            'maxOutputTokens': 120,
            'responseMimeType': 'application/json',
          },
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return fallback;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return fallback;
      }

      final candidateText = _extractCandidateText(decoded);
      final parsed = _parseQuestions(candidateText);
      return parsed.isEmpty ? fallback : parsed;
    } catch (_) {
      return fallback;
    }
  }

  String _buildPrompt({required String topic, required List<String> interests}) {
    final interestText = interests.isEmpty ? 'none' : interests.join(', ');
    return [
      'You write friendly community icebreakers.',
      'Topic: $topic',
      'Interests: $interestText',
      'Return only JSON: {"questions":["...","...","..."]}',
      'Rules: exactly 3 questions, under 15 words each, modern, specific, and not robotic.',
    ].join(' ');
  }

  String _extractCandidateText(Map<String, dynamic> decoded) {
    final candidates = decoded['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      return '';
    }

    final firstCandidate = candidates.first;
    if (firstCandidate is! Map<String, dynamic>) {
      return '';
    }

    final content = firstCandidate['content'];
    if (content is! Map<String, dynamic>) {
      return '';
    }

    final parts = content['parts'];
    if (parts is! List) {
      return '';
    }

    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is Map<String, dynamic>) {
        final text = part['text'];
        if (text is String && text.trim().isNotEmpty) {
          buffer.write(text);
        }
      }
    }
    return buffer.toString().trim();
  }

  List<String> _parseQuestions(String candidateText) {
    if (candidateText.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(candidateText);
      if (decoded is Map<String, dynamic>) {
        final questions = decoded['questions'];
        if (questions is List) {
          return _normalizeQuestions(questions.whereType<String>().toList(growable: false));
        }
      }
    } catch (_) {
      // Fall back to text parsing.
    }

    final lines = candidateText
        .split(RegExp(r'[\n\r]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) => line.replaceFirst(RegExp(r'^[\-\d\.)\s]+'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    return _normalizeQuestions(lines);
  }

  List<String> _normalizeQuestions(List<String> questions) {
    final cleaned = <String>[];
    for (final question in questions) {
      final text = question.trim();
      if (text.isEmpty) {
        continue;
      }
      final normalized = text.endsWith('?') ? text : '$text?';
      if (normalized.split(RegExp(r'\s+')).length <= 15) {
        cleaned.add(normalized);
      }
      if (cleaned.length == 3) {
        break;
      }
    }
    return cleaned;
  }

  List<String> _normalizeInterests(List<String> interests) {
    return interests
        .map((interest) => interest.trim())
        .where((interest) => interest.isNotEmpty)
        .take(3)
        .toList(growable: false);
  }

  List<String> _fallbackQuestions({required String topic, required List<String> interests}) {
    final interest = interests.isEmpty ? 'this' : interests.first;
    final topicLabel = topic.isEmpty ? 'this circle' : topic;

    final templates = <String>[
      'What got you into $topicLabel first?',
      'Which part of $interest are you exploring right now?',
      'What is one thing you want to learn next?',
    ];

    return _normalizeQuestions(templates);
  }
}
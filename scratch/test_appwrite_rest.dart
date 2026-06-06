import 'dart:convert';
import 'dart:io';

void main() async {
  final envLines = File('assets/env/.env.dev').readAsLinesSync();
  final env = <String, String>{};
  for (var line in envLines) {
    if (line.contains('=')) {
      final parts = line.split('=');
      env[parts[0]] = parts.sublist(1).join('=');
    }
  }

  final endpoint = env['APPWRITE_ENDPOINT']!;
  final projectId = env['APPWRITE_PROJECT_ID']!;
  final databaseId = env['APPWRITE_DATABASE_ID']!;
  final collectionId = env['APPWRITE_POSTS_COLLECTION_ID']!;

  final url = Uri.parse('\$endpoint/databases/\$databaseId/collections/\$collectionId/documents');
  
  final payload = {
    'documentId': 'unique()',
    'data': {
      'postId': '123',
      'circle_id': 'circle_id',
      'mentor_id': 'mentor_id',
      'title': 'Test Task',
      'post_content': 'Test desc',
      'deadline': DateTime.now().toUtc().toIso8601String(),
      'difficulty': 'Beginner',
      'category': 'General',
      'estimated_minutes': 30,
      'points': 10,
      'status': 'not_started',
      'assignment_scope': 'all_mentees',
      'assigned_user_ids': [],
      'assigned_circle_ids': [],
      'order_index': 0,
      'resources': [],
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'user_id': 'mentor_id',
      'username': 'Mentor',
    }
  };

  final request = await HttpClient().postUrl(url);
  request.headers.set('X-Appwrite-Project', projectId);
  request.headers.set('Content-Type', 'application/json');
  // Since we don't have a session, we might get an unauthorized error.
  // But wait, creating a post requires authentication.
  // Let's just see what error it returns! Maybe schema error comes before auth error? Or auth error comes first.
  
  request.write(jsonEncode(payload));
  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();
  print('Status: \${response.statusCode}');
  print('Body: \$body');
  
  exit(0);
}

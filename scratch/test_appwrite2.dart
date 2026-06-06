import 'dart:io';
import 'package:appwrite/appwrite.dart';

void main() async {
  final envLines = File('assets/env/.env.dev').readAsLinesSync();
  final env = <String, String>{};
  for (var line in envLines) {
    if (line.contains('=')) {
      final parts = line.split('=');
      env[parts[0]] = parts.sublist(1).join('=');
    }
  }

  final client = Client()
      .setEndpoint(env['APPWRITE_ENDPOINT']!)
      .setProject(env['APPWRITE_PROJECT_ID']!);

  final databases = Databases(client);

  try {
    await databases.createDocument(
      databaseId: env['APPWRITE_DATABASE_ID']!,
      collectionId: env['APPWRITE_POSTS_COLLECTION_ID']!,
      documentId: ID.unique(),
      data: {
        'postId': ID.unique(),
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
      },
    );
    print('SUCCESS');
  } on AppwriteException catch (e) {
    print('AppwriteException: \${e.message}');
  } catch (e) {
    print('Error: \$e');
  }
  exit(0);
}

import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: 'assets/env/.env.dev');

  final client = Client()
      .setEndpoint(dotenv.env['APPWRITE_ENDPOINT']!)
      .setProject(dotenv.env['APPWRITE_PROJECT_ID']!);

  final databases = Databases(client);

  try {
    await databases.createDocument(
      databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
      collectionId: dotenv.env['APPWRITE_POSTS_COLLECTION_ID']!,
      documentId: ID.unique(),
      data: {
        'postId': 'test_id',
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

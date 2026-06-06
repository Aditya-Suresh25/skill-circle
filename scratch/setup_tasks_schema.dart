import 'dart:convert';
import 'dart:io';

const apiKey = 'standard_96948115bcf92034a6d191a20f71925dfc6c188eddedccc49475ca536637d109c234d36d8a8cbe160df3d865eeaa567accb5d63ed13b9bf7228b56df963012d4baa7870a7632ac274077635ee77b1fe6f38b27e3459a4d8608c0533f2a10faa487e067fd1ca0ccfd21237f34288d592423d200978fd556d8c2e7e7d1070e1282';

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

  final client = HttpClient();

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$endpoint$path');
    final request = await client.postUrl(url);
    request.headers.set('X-Appwrite-Project', projectId);
    request.headers.set('X-Appwrite-Key', apiKey);
    request.headers.set('Content-Type', 'application/json');
    request.write(jsonEncode(body));
    
    final response = await request.close();
    final resBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(resBody);
    } else {
      print('Error \${response.statusCode}: \$resBody');
      return null;
    }
  }

  Future<void> createAttribute(String collectionId, String type, Map<String, dynamic> body) async {
    print('Creating $type attribute ${body["key"]}...');
    await post('/databases/$databaseId/collections/$collectionId/attributes/$type', body);
    await Future.delayed(Duration(milliseconds: 500)); // Rate limit buffer
  }

  // 1. Create Tasks Collection
  print('Creating tasks collection...');
  final tasksCol = await post('/databases/$databaseId/collections', {
    'collectionId': 'tasks',
    'name': 'Tasks',
    'permissions': [
      'read("users")',
      'create("users")',
      'update("users")',
      'delete("users")'
    ],
    'documentSecurity': false
  });

  if (tasksCol != null) {
    print('Tasks Collection Created: ${tasksCol["\$id"]}');
    final cid = tasksCol['\$id'];

    // String attributes
    await createAttribute(cid, 'string', {'key': 'circle_id', 'size': 64, 'required': true});
    await createAttribute(cid, 'string', {'key': 'mentor_id', 'size': 64, 'required': true});
    await createAttribute(cid, 'string', {'key': 'title', 'size': 255, 'required': true});
    await createAttribute(cid, 'string', {'key': 'description', 'size': 10000, 'required': false});
    await createAttribute(cid, 'string', {'key': 'difficulty', 'size': 32, 'required': false, 'default': 'Beginner'});
    await createAttribute(cid, 'string', {'key': 'category', 'size': 64, 'required': false, 'default': 'General'});
    await createAttribute(cid, 'string', {'key': 'status', 'size': 32, 'required': false, 'default': 'not_started'});
    await createAttribute(cid, 'string', {'key': 'assignment_scope', 'size': 64, 'required': false, 'default': 'all_mentees'});
    
    // Int attributes
    await createAttribute(cid, 'integer', {'key': 'estimated_minutes', 'required': false, 'default': 30});
    await createAttribute(cid, 'integer', {'key': 'points', 'required': false, 'default': 10});
    await createAttribute(cid, 'integer', {'key': 'order_index', 'required': false, 'default': 0});
    
    // Datetime attributes
    await createAttribute(cid, 'datetime', {'key': 'deadline', 'required': false});
    await createAttribute(cid, 'datetime', {'key': 'created_at', 'required': false});
    await createAttribute(cid, 'datetime', {'key': 'timestamp', 'required': false});

    // Array attributes
    await createAttribute(cid, 'string', {'key': 'assigned_user_ids', 'size': 64, 'required': false, 'array': true});
    await createAttribute(cid, 'string', {'key': 'assigned_circle_ids', 'size': 64, 'required': false, 'array': true});
    await createAttribute(cid, 'string', {'key': 'resources', 'size': 1000, 'required': false, 'array': true});
  }

  // 2. Create Task Submissions Collection
  print('Creating task submissions collection...');
  final subCol = await post('/databases/$databaseId/collections', {
    'collectionId': 'task_submissions',
    'name': 'Task Submissions',
    'permissions': [
      'read("users")',
      'create("users")',
      'update("users")',
      'delete("users")'
    ],
    'documentSecurity': false
  });

  if (subCol != null) {
    print('Task Submissions Collection Created: ${subCol["\$id"]}');
    final cid = subCol['\$id'];

    // String attributes
    await createAttribute(cid, 'string', {'key': 'task_id', 'size': 64, 'required': true});
    await createAttribute(cid, 'string', {'key': 'user_id', 'size': 64, 'required': true});
    await createAttribute(cid, 'string', {'key': 'username', 'size': 128, 'required': false});
    await createAttribute(cid, 'string', {'key': 'content', 'size': 10000, 'required': false});
    await createAttribute(cid, 'string', {'key': 'status', 'size': 32, 'required': false, 'default': 'pending'});
    await createAttribute(cid, 'string', {'key': 'grade', 'size': 32, 'required': false});
    await createAttribute(cid, 'string', {'key': 'feedback', 'size': 5000, 'required': false});
    
    // Datetime attributes
    await createAttribute(cid, 'datetime', {'key': 'submitted_at', 'required': false});
    
    // Array attributes
    await createAttribute(cid, 'string', {'key': 'attachments', 'size': 1000, 'required': false, 'array': true});
  }

  print('Done!');
  exit(0);
}

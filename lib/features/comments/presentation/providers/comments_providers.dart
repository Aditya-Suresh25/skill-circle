import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/features/comments/data/repositories/firebase_comment_repository.dart';
import 'package:skill_circle_app/features/comments/domain/repositories/comment_repository.dart';

final commentsFirestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final firestore = ref.read(commentsFirestoreProvider);
  return FirebaseCommentRepository(firestore);
});

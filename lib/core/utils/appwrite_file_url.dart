String buildAppwriteFileViewUrl({
  required String endpoint,
  required String bucketId,
  required String projectId,
  required String fileId,
}) {
  final base = endpoint.endsWith('/') ? endpoint.substring(0, endpoint.length - 1) : endpoint;
  final encodedBucketId = Uri.encodeComponent(bucketId);
  final encodedFileId = Uri.encodeComponent(fileId);
  final encodedProjectId = Uri.encodeQueryComponent(projectId);

  return '$base/storage/buckets/$encodedBucketId/files/$encodedFileId/view?project=$encodedProjectId';
}
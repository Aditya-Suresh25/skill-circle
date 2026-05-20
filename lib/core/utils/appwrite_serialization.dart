DateTime? parseAppwriteDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value);
  return null;
}

String serializeAppwriteDate(DateTime value) {
  return value.toUtc().toIso8601String();
}

class PhotoRecord {
  const PhotoRecord({required this.id, required this.createdAt});

  final int id;
  final DateTime createdAt;

  factory PhotoRecord.fromJson(Map<String, dynamic> json) {
    return PhotoRecord(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

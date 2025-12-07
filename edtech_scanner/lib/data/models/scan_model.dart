class ScanModel {
  final String scanId;
  final String? userId;
  final String equipmentId;
  final String equipmentName;
  final String className;
  final double confidenceScore;
  final String imagePath;
  final String? thumbnailPath;
  final DateTime timestamp;
  final bool syncedToBackend;
  final String? notes;

  ScanModel({
    required this.scanId,
    this.userId,
    required this.equipmentId,
    required this.equipmentName,
    required this.className,
    required this.confidenceScore,
    required this.imagePath,
    this.thumbnailPath,
    required this.timestamp,
    this.syncedToBackend = false,
    this.notes,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      scanId: json['scan_id'] ?? '',
      userId: json['user_id'],
      equipmentId: json['equipment_id'] ?? '',
      equipmentName: json['equipment_name'] ?? '',
      className: json['class_name'] ?? '',
      confidenceScore: json['confidence_score']?.toDouble() ?? 0.0,
      imagePath: json['image_path'] ?? '',
      thumbnailPath: json['thumbnail_path'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      syncedToBackend: json['synced_to_backend'] == 1,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scan_id': scanId,
      'user_id': userId,
      'equipment_id': equipmentId,
      'equipment_name': equipmentName,
      'class_name': className,
      'confidence_score': confidenceScore,
      'image_path': imagePath,
      'thumbnail_path': thumbnailPath,
      'timestamp': timestamp.toIso8601String(),
      'synced_to_backend': syncedToBackend ? 1 : 0,
      'notes': notes,
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }
}

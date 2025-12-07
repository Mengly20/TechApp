class EquipmentModel {
  final String equipmentId;
  final String className;
  final String nameEn;
  final String? nameKm;
  final String category;
  final String descriptionEn;
  final String? descriptionKm;
  final String usageEn;
  final String? usageKm;
  final String? safetyInfoEn;
  final String? safetyInfoKm;
  final String? imageUrl;
  final List<String> tags;

  EquipmentModel({
    required this.equipmentId,
    required this.className,
    required this.nameEn,
    this.nameKm,
    required this.category,
    required this.descriptionEn,
    this.descriptionKm,
    required this.usageEn,
    this.usageKm,
    this.safetyInfoEn,
    this.safetyInfoKm,
    this.imageUrl,
    this.tags = const [],
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      equipmentId: json['equipment_id'] ?? '',
      className: json['class_name'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameKm: json['name_km'],
      category: json['category'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      descriptionKm: json['description_km'],
      usageEn: json['usage_en'] ?? '',
      usageKm: json['usage_km'],
      safetyInfoEn: json['safety_info_en'],
      safetyInfoKm: json['safety_info_km'],
      imageUrl: json['image_url'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipment_id': equipmentId,
      'class_name': className,
      'name_en': nameEn,
      'name_km': nameKm,
      'category': category,
      'description_en': descriptionEn,
      'description_km': descriptionKm,
      'usage_en': usageEn,
      'usage_km': usageKm,
      'safety_info_en': safetyInfoEn,
      'safety_info_km': safetyInfoKm,
      'image_url': imageUrl,
      'tags': tags,
    };
  }
}

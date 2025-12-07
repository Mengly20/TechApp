import 'dart:io';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import '../data/models/scan_model.dart';
import '../data/models/equipment_model.dart';

class ScanService {
  final _uuid = const Uuid();
  
  // Mock equipment database
  final List<EquipmentModel> _mockEquipmentDatabase = [
    EquipmentModel(
      equipmentId: 'eq_001',
      className: 'microscope',
      nameEn: 'Compound Microscope',
      category: 'Microscopy',
      descriptionEn: 'An optical instrument with multiple lenses for magnifying small objects',
      usageEn: 'Used to observe cells, microorganisms, and other tiny specimens',
      safetyInfoEn: 'Handle with care, avoid touching lenses, use proper lighting',
      tags: ['optical', 'magnification', 'biology'],
    ),
    EquipmentModel(
      equipmentId: 'eq_002',
      className: 'beaker',
      nameEn: 'Laboratory Beaker',
      category: 'Glassware',
      descriptionEn: 'A cylindrical container with a flat bottom used for mixing and heating liquids',
      usageEn: 'Used for holding, mixing, and heating liquids in laboratory',
      safetyInfoEn: 'Use heat-resistant beakers for heating, handle hot glassware with tongs',
      tags: ['glassware', 'container', 'chemistry'],
    ),
    EquipmentModel(
      equipmentId: 'eq_003',
      className: 'test-tube',
      nameEn: 'Test Tube',
      category: 'Glassware',
      descriptionEn: 'A thin glass tube closed at one end, used for holding small amounts of liquid',
      usageEn: 'Used for chemical reactions, heating small amounts of substances',
      safetyInfoEn: 'Always point away from people when heating, use test tube holders',
      tags: ['glassware', 'chemistry', 'reactions'],
    ),
    EquipmentModel(
      equipmentId: 'eq_004',
      className: 'bunsen-burner',
      nameEn: 'Bunsen Burner',
      category: 'Heating',
      descriptionEn: 'A gas burner used for heating and sterilization',
      usageEn: 'Used to heat substances, sterilize equipment, and perform flame tests',
      safetyInfoEn: 'Keep flammable materials away, tie back long hair, wear safety goggles',
      tags: ['heating', 'flame', 'safety'],
    ),
    EquipmentModel(
      equipmentId: 'eq_005',
      className: 'flask',
      nameEn: 'Erlenmeyer Flask',
      category: 'Glassware',
      descriptionEn: 'A conical flask with a narrow neck, used for mixing and heating',
      usageEn: 'Used for titrations, mixing solutions, and heating liquids',
      safetyInfoEn: 'Handle with care, use appropriate heating methods',
      tags: ['glassware', 'mixing', 'chemistry'],
    ),
  ];

  Future<Map<String, dynamic>> analyzeImage(File imageFile, String? userId) async {
    // Mock AI analysis - simulate processing time
    await Future.delayed(const Duration(seconds: 2));
    
    // Randomly select equipment for demo
    final random = Random();
    final equipment = _mockEquipmentDatabase[random.nextInt(_mockEquipmentDatabase.length)];
    final confidence = 0.75 + random.nextDouble() * 0.20; // 75-95% confidence
    
    // Create scan model
    final scan = ScanModel(
      scanId: _uuid.v4(),
      userId: userId,
      equipmentId: equipment.equipmentId,
      equipmentName: equipment.nameEn,
      className: equipment.className,
      confidenceScore: confidence,
      imagePath: imageFile.path,
      timestamp: DateTime.now(),
    );
    
    return {
      'equipment': equipment,
      'scan': scan,
    };
  }

  Future<String> chatWithAI(
    String equipmentId,
    String equipmentName,
    String userMessage,
    List<Map<String, String>> conversationHistory,
  ) async {
    // Mock AI chat - simulate response time
    await Future.delayed(const Duration(seconds: 1));
    
    // Generate mock responses based on common questions
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('use') || lowerMessage.contains('how')) {
      return 'To use a $equipmentName, first ensure it is clean and in good condition. Follow the standard laboratory procedures and always wear appropriate safety equipment. Would you like specific step-by-step instructions?';
    } else if (lowerMessage.contains('safety') || lowerMessage.contains('danger')) {
      return 'When using $equipmentName, always wear safety goggles and appropriate protective gear. Keep your work area clean and organized. Never perform experiments unsupervised. What specific safety aspect would you like to know more about?';
    } else if (lowerMessage.contains('clean') || lowerMessage.contains('maintain')) {
      return 'To maintain your $equipmentName, clean it thoroughly after each use with appropriate cleaning solutions. Store it in a safe, dry place. Regular maintenance ensures accuracy and longevity. Do you need specific cleaning instructions?';
    } else {
      return 'That\'s an interesting question about $equipmentName! This equipment is commonly used in laboratory settings for scientific experiments. Could you please be more specific about what aspect you\'d like to learn about?';
    }
  }
}

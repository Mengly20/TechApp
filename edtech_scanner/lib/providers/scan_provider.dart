import 'package:flutter/material.dart';
import 'dart:io';
import '../data/models/scan_model.dart';
import '../data/models/equipment_model.dart';
import '../services/scan_service.dart';

class ScanProvider with ChangeNotifier {
  final ScanService _scanService = ScanService();
  
  ScanModel? _currentScan;
  EquipmentModel? _identifiedEquipment;
  bool _isAnalyzing = false;
  String? _errorMessage;
  List<Map<String, String>> _chatMessages = [];

  ScanModel? get currentScan => _currentScan;
  EquipmentModel? get identifiedEquipment => _identifiedEquipment;
  bool get isAnalyzing => _isAnalyzing;
  String? get errorMessage => _errorMessage;
  List<Map<String, String>> get chatMessages => _chatMessages;

  Future<void> analyzeImage(File imageFile, String? userId) async {
    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _scanService.analyzeImage(imageFile, userId);
      
      _identifiedEquipment = result['equipment'];
      _currentScan = result['scan'];
      
      // Initialize chat with equipment context
      _chatMessages = [
        {
          'role': 'assistant',
          'content': 'I identified: ${_identifiedEquipment?.nameEn}. How can I help you learn about this equipment?'
        }
      ];
    } catch (e) {
      _errorMessage = 'Failed to analyze image: $e';
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  Future<void> sendChatMessage(String message) async {
    if (_identifiedEquipment == null) return;

    // Add user message
    _chatMessages.add({'role': 'user', 'content': message});
    notifyListeners();

    try {
      final response = await _scanService.chatWithAI(
        _identifiedEquipment!.equipmentId,
        _identifiedEquipment!.nameEn,
        message,
        _chatMessages,
      );

      // Add AI response
      _chatMessages.add({'role': 'assistant', 'content': response});
    } catch (e) {
      _chatMessages.add({
        'role': 'assistant',
        'content': 'Sorry, I encountered an error. Please try again.'
      });
    } finally {
      notifyListeners();
    }
  }

  void clearScan() {
    _currentScan = null;
    _identifiedEquipment = null;
    _chatMessages = [];
    _errorMessage = null;
    notifyListeners();
  }

  void resetChat() {
    if (_identifiedEquipment != null) {
      _chatMessages = [
        {
          'role': 'assistant',
          'content': 'I identified: ${_identifiedEquipment?.nameEn}. How can I help you learn about this equipment?'
        }
      ];
      notifyListeners();
    }
  }
}

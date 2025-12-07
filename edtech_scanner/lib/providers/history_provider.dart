import 'package:flutter/material.dart';
import '../data/models/scan_model.dart';
import '../services/local_storage_service.dart';

class HistoryProvider with ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  
  List<ScanModel> _scanHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ScanModel> get scanHistory => _scanHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalScans => _scanHistory.length;

  Future<void> loadHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _scanHistory = await _storageService.getAllScans();
      _scanHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      _errorMessage = 'Failed to load history: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveScan(ScanModel scan) async {
    try {
      await _storageService.saveScan(scan);
      _scanHistory.insert(0, scan);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to save scan: $e';
      notifyListeners();
    }
  }

  Future<void> deleteScan(String scanId) async {
    try {
      await _storageService.deleteScan(scanId);
      _scanHistory.removeWhere((scan) => scan.scanId == scanId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete scan: $e';
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    try {
      await _storageService.clearAllScans();
      _scanHistory = [];
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to clear history: $e';
      notifyListeners();
    }
  }

  ScanModel? getScanById(String scanId) {
    try {
      return _scanHistory.firstWhere((scan) => scan.scanId == scanId);
    } catch (e) {
      return null;
    }
  }
}

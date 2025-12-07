import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../providers/history_provider.dart';
import '../../data/models/scan_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);

    if (historyProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (historyProvider.scanHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No scan history yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your scans will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${historyProvider.totalScans} Scans',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  _showClearHistoryDialog(context, historyProvider);
                },
                icon: const Icon(Icons.delete_outline, size: 20),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
        
        // Scan List
        Expanded(
          child: ListView.builder(
            itemCount: historyProvider.scanHistory.length,
            itemBuilder: (context, index) {
              final scan = historyProvider.scanHistory[index];
              return _ScanListItem(
                scan: scan,
                onDelete: () {
                  historyProvider.deleteScan(scan.scanId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scan deleted')),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showClearHistoryDialog(BuildContext context, HistoryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to delete all scan history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _ScanListItem extends StatelessWidget {
  final ScanModel scan;
  final VoidCallback onDelete;

  const _ScanListItem({
    required this.scan,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: scan.imagePath.isNotEmpty && File(scan.imagePath).existsSync()
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(scan.imagePath),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.science,
                  color: Color(0xFF2563EB),
                ),
              ),
        title: Text(
          scan.equipmentName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Confidence: ${(scan.confidenceScore * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('MMM dd, yyyy • hh:mm a').format(scan.timestamp),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
            }
          },
        ),
        onTap: () {
          _showScanDetails(context, scan);
        },
      ),
    );
  }

  void _showScanDetails(BuildContext context, ScanModel scan) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (scan.imagePath.isNotEmpty && File(scan.imagePath).existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(scan.imagePath),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                scan.equipmentName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Confidence: ${(scan.confidenceScore * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMMM dd, yyyy • hh:mm a').format(scan.timestamp),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

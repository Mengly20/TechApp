import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/scan_provider.dart';
import '../../providers/history_provider.dart';

class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scanProvider = Provider.of<ScanProvider>(context);
    final historyProvider = Provider.of<HistoryProvider>(context, listen: false);

    if (scanProvider.isAnalyzing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analyzing...')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Analyzing with AI...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    final equipment = scanProvider.identifiedEquipment;
    final scan = scanProvider.currentScan;

    if (equipment == null || scan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan Result')),
        body: const Center(
          child: Text('No results available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await historyProvider.saveScan(scan);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Scan saved to history!')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (scan.imagePath.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(scan.imagePath),
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Confidence Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getConfidenceColor(scan.confidenceScore),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Confidence: ${(scan.confidenceScore * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Equipment Name
            Text(
              equipment.nameEn,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Category
            Chip(
              label: Text(equipment.category),
              backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
              labelStyle: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Description Section
            _SectionCard(
              title: 'Description',
              icon: Icons.info_outline,
              content: equipment.descriptionEn,
            ),
            
            const SizedBox(height: 16),
            
            // Usage Section
            _SectionCard(
              title: 'How to Use',
              icon: Icons.school,
              content: equipment.usageEn,
            ),
            
            const SizedBox(height: 16),
            
            // Safety Section
            if (equipment.safetyInfoEn != null)
              _SectionCard(
                title: 'Safety Information',
                icon: Icons.warning_amber,
                content: equipment.safetyInfoEn!,
                color: Colors.orange,
              ),
            
            const SizedBox(height: 24),
            
            // Chat with AI Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showChatDialog(context, scanProvider);
                },
                icon: const Icon(Icons.chat),
                label: const Text('Chat with AI Assistant'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return const Color(0xFF10B981);
    if (confidence >= 0.6) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  void _showChatDialog(BuildContext context, ScanProvider scanProvider) {
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Row(
                children: [
                  const Icon(Icons.chat, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'AI Assistant',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const Divider(),
              
              // Chat Messages
              Expanded(
                child: Consumer<ScanProvider>(
                  builder: (context, provider, _) {
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: provider.chatMessages.length,
                      itemBuilder: (context, index) {
                        final message = provider.chatMessages[index];
                        final isUser = message['role'] == 'user';
                        
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? const Color(0xFF2563EB)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              message['content'] ?? '',
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              
              // Suggested Questions
              if (scanProvider.chatMessages.length <= 1)
                Container(
                  height: 40,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _SuggestedChip(
                        label: 'How do I use this?',
                        onTap: () {
                          scanProvider.sendChatMessage('How do I use this?');
                        },
                      ),
                      _SuggestedChip(
                        label: 'Safety precautions?',
                        onTap: () {
                          scanProvider.sendChatMessage('What are the safety precautions?');
                        },
                      ),
                      _SuggestedChip(
                        label: 'How to maintain?',
                        onTap: () {
                          scanProvider.sendChatMessage('How to clean and maintain?');
                        },
                      ),
                    ],
                  ),
                ),
              
              // Input Field
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask a question...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: const Color(0xFF2563EB),
                    onPressed: () {
                      if (messageController.text.trim().isNotEmpty) {
                        scanProvider.sendChatMessage(messageController.text.trim());
                        messageController.clear();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;
  final Color? color;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.content,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color ?? const Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestedChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
        backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
        labelStyle: const TextStyle(
          color: Color(0xFF2563EB),
        ),
      ),
    );
  }
}

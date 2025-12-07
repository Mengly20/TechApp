import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/history_provider.dart';
import '../scan/scan_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load history when app starts
    Future.microtask(() {
      Provider.of<HistoryProvider>(context, listen: false).loadHistory();
    });
  }

  void _onItemTapped(int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if guest user is trying to access History
    if (index == 2 && authProvider.isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign in to access your scan history'),
        ),
      );
      return;
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final historyProvider = Provider.of<HistoryProvider>(context);

    final List<Widget> pages = [
      _HomeTab(historyProvider: historyProvider),
      const ScanScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('EdTech Scanner'),
        actions: [
          if (authProvider.isGuest)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                label: const Text(
                  'Guest Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: Colors.orange,
              ),
            ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final HistoryProvider historyProvider;

  const _HomeTab({required this.historyProvider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to EdTech Scanner',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Identify science equipment and learn with AI',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _StatsCard(
                  icon: Icons.camera_alt,
                  title: 'Total Scans',
                  value: '${historyProvider.totalScans}',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatsCard(
                  icon: Icons.science,
                  title: 'Equipment',
                  value: '${historyProvider.scanHistory.map((s) => s.equipmentId).toSet().length}',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Features
          const Text(
            'Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _FeatureCard(
            icon: Icons.camera_enhance,
            title: 'AI-Powered Scanning',
            description: 'Identify science equipment using advanced AI',
            color: const Color(0xFF2563EB),
            onTap: () {
              // Navigate to scan tab
            },
          ),
          
          const SizedBox(height: 12),
          
          _FeatureCard(
            icon: Icons.chat,
            title: 'AI Assistant',
            description: 'Ask questions and learn about equipment',
            color: const Color(0xFF10B981),
            onTap: () {},
          ),
          
          const SizedBox(height: 12),
          
          _FeatureCard(
            icon: Icons.history,
            title: 'Scan History',
            description: 'Access your previous scans anytime',
            color: const Color(0xFFF59E0B),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatsCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

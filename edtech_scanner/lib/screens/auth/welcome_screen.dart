import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'phone_signin_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2563EB),
              const Color(0xFF1E40AF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                
                // App Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.science,
                    size: 60,
                    color: Color(0xFF2563EB),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                const Text(
                  'EdTech Scanner',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                // Subtitle
                const Text(
                  'Identify science equipment with AI\nand learn with intelligent assistance',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const Spacer(),
                
                // Google Sign In Button
                ElevatedButton.icon(
                  onPressed: authProvider.isLoading ? null : () {
                    authProvider.signInWithGoogle();
                  },
                  icon: const Icon(Icons.login, color: Color(0xFF2563EB)),
                  label: const Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Phone Sign In Button
                OutlinedButton.icon(
                  onPressed: authProvider.isLoading ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PhoneSignInScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone, color: Colors.white),
                  label: const Text(
                    'Sign in with Phone',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Guest Button
                TextButton(
                  onPressed: authProvider.isLoading ? null : () {
                    authProvider.signInAsGuest();
                  },
                  child: const Text(
                    'Continue as Guest',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                
                if (authProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                
                if (authProvider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      authProvider.errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

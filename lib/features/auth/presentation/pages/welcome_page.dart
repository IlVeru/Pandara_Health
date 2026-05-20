import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pandara_health/core/constants/app_colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              // Logo Placeholder
              Center(
                child: Image.asset(
                  'assets/images/logo pandara health - panda.png',
                  width: 500,
                ),
              ),
              // App Name & Tagline (Image)
              Center(
                child: Image.asset(
                  'assets/images/logo pandara health putih.png',
                  width: 350,
                ),
              ),
              const Spacer(flex: 2),
              // Description
              const Text(
                'Track your health and connect with experts effortlessly. Pandara Health brings clinical precision to your personal wellness journey.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              // Register Button
              ElevatedButton(
                onPressed: () => context.push('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              // Login Button
              OutlinedButton(
                onPressed: () => context.push('/login'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.white, width: 2),
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(flex: 2),
              // Footer
              const Text(
                '© 2026 Pandara Health. All Rights Reserved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

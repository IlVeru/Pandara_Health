import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pandara_health/core/constants/app_colors.dart';
import 'package:pandara_health/features/auth/data/repositories/auth_repository.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _progressAnimation =
        Tween<double>(begin: 0, end: 1).animate(_progressController)
          ..addListener(() {
            setState(() {});
          });

    _progressController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final repository = ref.read(authRepositoryProvider);
        if (repository.isLoggedIn()) {
          context.go('/dashboard');
        } else {
          context.go('/welcome');
        }
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            // Logo
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white12,
                shape: BoxShape.circle,
              ),

              child: Image.asset(
                'assets/images/logo pandara health - panda.png',
              ),
            ),
            const SizedBox(height: 48),
            // App Name & Tagline
            Image.asset('assets/images/logo pandara health putih.png'),
            const Spacer(flex: 2),
            // Loading Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'INITIALIZING WELLNESS',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.white,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

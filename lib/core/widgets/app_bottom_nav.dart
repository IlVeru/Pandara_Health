import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pandara_health/core/constants/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 0) context.go('/dashboard');
          if (index == 1) context.go('/tracker');
          if (index == 2) context.go('/reports');
          if (index == 3) context.go('/consult');
          if (index == 4) context.go('/profile');
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.black26,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          _buildNavItem(Icons.home_outlined, 'BERANDA', currentIndex == 0),
          _buildNavItem(Icons.show_chart, 'PELACAK', currentIndex == 1),
          _buildNavItem(Icons.assessment_outlined, 'LAPORAN', currentIndex == 2),
          _buildNavItem(Icons.medical_services_outlined, 'KONSULTASI', currentIndex == 3),
          _buildNavItem(Icons.person_outline, 'PROFIL', currentIndex == 4),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, bool isSelected) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon),
      ),
      label: label,
    );
  }
}

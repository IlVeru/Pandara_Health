import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandara_health/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:pandara_health/features/auth/data/repositories/auth_repository.dart';
import '../../../../core/widgets/app_bottom_nav.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(authRepositoryProvider);
    final user = repository.getCurrentUser();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/logo_health_fix.png', height: 32),
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Profile Info
                    _buildProfileHeader(user?.name ?? 'User', user?.email ?? 'user@pandara.health'),
                    const SizedBox(height: 40),
                    // Settings Menu
                    _buildSettingsMenu(context, ref),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=400'),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          name,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          email,
          style: const TextStyle(color: Colors.black38, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSettingsMenu(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(Icons.person_outline, 'Kelola Profil', Colors.teal, false, onTap: () => context.push('/manage_profile')),
          _buildDivider(),
          _buildMenuItem(Icons.settings_outlined, 'Pengaturan', Colors.teal, false),
          _buildDivider(),
          _buildMenuItem(Icons.account_balance_wallet_outlined, 'Manajemen Akun', Colors.teal, false, onTap: () => context.push('/account_management')),
          _buildDivider(),
          _buildMenuItem(Icons.storage_outlined, 'Database Inspector', Colors.orange, false, onTap: () => context.push('/debug_db')),
          _buildDivider(),
          _buildMenuItem(Icons.help_outline, 'Bantuan', Colors.teal, false),
          _buildDivider(),
          _buildMenuItem(
            Icons.logout, 
            'Logout', 
            Colors.redAccent, 
            true, 
            onTap: () async {
              await ref.read(authRepositoryProvider).logout();
              if (context.mounted) {
                context.go('/welcome');
              }
            }
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, Color color, bool isDestructive, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.redAccent : Colors.black87,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: isDestructive ? Colors.redAccent.withValues(alpha: 0.3) : Colors.black12),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Divider(height: 1, color: Colors.black.withValues(alpha: 0.03)),
    );
  }
}

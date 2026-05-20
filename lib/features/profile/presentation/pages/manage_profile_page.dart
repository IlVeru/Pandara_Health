import 'package:flutter/material.dart';
import 'package:pandara_health/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_bottom_nav.dart';

class ManageProfilePage extends StatelessWidget {
  const ManageProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Kelola Profil',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const Spacer(),
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
                    // Change Photo Section
                    _buildPhotoSection(),
                    const SizedBox(height: 40),
                    // Info Card
                    _buildInfoCard(),
                    const SizedBox(height: 40),
                    // Action Button
                    _buildActionButton(context),
                    const SizedBox(height: 24),
                    const Text(
                      'Terakhir diperbarui: 12 Okt 2023',
                      style: TextStyle(color: Colors.black38, fontSize: 13),
                    ),
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

  Widget _buildPhotoSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=400'),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'KETUK UNTUK UBAH FOTO',
          style: TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              const Text('Informasi Akun', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 24),
          _buildInputField('Username', '@', 'pandara_user'),
          const SizedBox(height: 20),
          _buildInputField('Nama Lengkap', null, 'Jane Doe', icon: Icons.person_outline),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String? prefix, String initialValue, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            initialValue: initialValue,
            decoration: InputDecoration(
              icon: prefix != null 
                ? Text(prefix, style: const TextStyle(color: Colors.black26, fontSize: 18, fontWeight: FontWeight.bold))
                : Icon(icon, color: Colors.black26),
              border: InputBorder.none,
            ),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.pop(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: const Text(
        'Simpan Perubahan',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

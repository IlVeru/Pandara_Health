import 'package:flutter/material.dart';
import 'package:pandara_health/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_bottom_nav.dart';

class AccountManagementPage extends StatelessWidget {
  const AccountManagementPage({super.key});

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
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.03),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Manajemen Akun',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1D1D1D)),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Security Banner
                    _buildSecurityBanner(),
                    const SizedBox(height: 32),
                    
                    // Main Settings
                    const Text('PENGATURAN UTAMA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 1.2)),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => context.push('/change_password'),
                      borderRadius: BorderRadius.circular(24),
                      child: _buildSettingsCard(Icons.lock_reset, 'Ganti Password', 'Terakhir diubah 3 bulan lalu'),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => context.push('/change_email'),
                      borderRadius: BorderRadius.circular(24),
                      child: _buildSettingsCard(Icons.email_outlined, 'Ganti Email', 'user@pandara.health'),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Sync Section
                    const Text('AKSES & SINKRONISASI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 1.2)),
                    const SizedBox(height: 16),
                    _buildSyncCard(),
                    
                    const SizedBox(height: 32),
                    
                    // Danger Zone
                    const Text('ZONA BERBAHAYA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent, letterSpacing: 1.2)),
                    const SizedBox(height: 16),
                    _buildDangerZone(),
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

  Widget _buildSecurityBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF00897B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('KEAMANAN DATA', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          SizedBox(height: 8),
          Text('Terproteksi & Aman', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text(
            'Kelola kredensial dan preferensi login Anda di sini.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(IconData icon, String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(sub, style: const TextStyle(color: Colors.black26, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black12),
        ],
      ),
    );
  }

  Widget _buildSyncCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tambah Akun Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                Text('Hubungkan profil keluarga', style: TextStyle(color: Colors.black26, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.add, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Text(
            'Menghapus akun akan menghilangkan semua data kesehatan, rekam medis, dan riwayat konsultasi Anda secara permanen.',
            style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline),
                SizedBox(width: 12),
                Text('Hapus Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

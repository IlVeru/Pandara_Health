import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pandara_health/core/constants/app_colors.dart';
import 'package:pandara_health/features/auth/data/repositories/auth_repository.dart';
import 'package:pandara_health/features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../../../core/widgets/app_bottom_nav.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  ImageProvider _getProfileImage(String? profilePic) {
    if (profilePic != null && profilePic.isNotEmpty) {
      if (profilePic.startsWith('http') || profilePic.startsWith('https')) {
        return NetworkImage(profilePic);
      } else {
        return FileImage(File(profilePic));
      }
    }
    return const NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200');
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(dashboardStatsProvider);
    final user = ref.watch(currentUserProvider);
    
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
                  GestureDetector(
                    onTap: () => context.go('/dashboard'),
                    child: Image.asset('assets/images/logo_health_fix.png', height: 32),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: _getProfileImage(user?.profilePic),
                      backgroundColor: AppColors.primary,
                    ),
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
                    Text(
                      'Halo, ${user?.name ?? 'User'}! 👋',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1D1D1D)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bagaimana kabar kesehatanmu hari ini?',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    _buildEnhancedVitalCard(stats),
                    const SizedBox(height: 32),
                    const Text(
                      'Akses Cepat',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D1D1D)),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickAccessGrid(),
                    const SizedBox(height: 32),
                    const Text(
                      'Daftar Dokter Spesialis',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D1D1D)),
                    ),
                    const SizedBox(height: 16),
                    _buildDoctorList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _buildEnhancedVitalCard(DashboardStats stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF00BFA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ringkasan Vital', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        const Text('Kondisi Anda: ', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const Text('Sehat', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.shield_outlined, color: Colors.white, size: 40),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildVitalSubCard(Icons.favorite_outline, 'Detak Jantung', stats.heartRate.toString(), 'BPM'),
              const SizedBox(width: 16),
              _buildVitalSubCard(Icons.directions_walk, 'Langkah Hari Ini', stats.steps.toString(), ''),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lihat Detail', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSubCard(IconData icon, String label, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: value,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                children: [
                  if (unit.isNotEmpty) TextSpan(text: ' $unit', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal)),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildAccessCard(Icons.show_chart, 'Tracker', 'Pantau harian', const Color(0xFFE0F7F9), AppColors.primary, () => context.go('/tracker')),
        _buildAccessCard(Icons.assessment_outlined, 'Laporan', 'Ringkasan mingguan', const Color(0xFFF3E5F5), Colors.purple, () => context.go('/reports')),
        _buildAccessCard(Icons.shopping_bag_outlined, 'Konsultasi', 'Tanya dokter', const Color(0xFFFFF3E0), Colors.orange, () => context.go('/consult')),
        _buildAccessCard(Icons.person_outline, 'Profil', 'Atur akun', const Color(0xFFE8F5E9), Colors.green, () => context.go('/profile')),
      ],
    );
  }

  Widget _buildAccessCard(IconData icon, String title, String sub, Color bgColor, Color iconColor, VoidCallback? onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(sub, style: const TextStyle(color: Colors.black38, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorList() {
    final List<Map<String, String>> doctors = [
      {'name': 'Dr. Adrian Pratama', 'spec': 'Spesialis Jantung', 'rate': '4.9', 'exp': '12 Thn', 'img': 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=200'},
      {'name': 'Dr. Sarah Wijaya', 'spec': 'Spesialis Gizi', 'rate': '4.8', 'exp': '8 Thn', 'img': 'https://images.unsplash.com/photo-1559839734-2b71f1536783?q=80&w=200'},
      {'name': 'Dr. Budi Santoso', 'spec': 'Umum', 'rate': '4.7', 'exp': '15 Thn', 'img': 'https://plus.unsplash.com/premium_photo-1661764878654-3d0fc2eefcca?q=80&w=200'},
    ];

    return Column(
      children: doctors.map((doc) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/doctor_profile'),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    doc['img']!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 64,
                      height: 64,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.medical_services, size: 12, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                doc['spec']!,
                                style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.business_center_outlined, size: 14, color: Colors.black26),
                          const SizedBox(width: 4),
                          Flexible(child: Text('${doc['exp']} Pengalaman', style: const TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 24),
                ),
              ],
            ),
          ),
        ),
      )).toList(),
    );
  }
}

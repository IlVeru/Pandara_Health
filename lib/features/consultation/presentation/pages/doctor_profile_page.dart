import 'package:flutter/material.dart';
import 'package:pandara_health/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/widgets/app_bottom_nav.dart';

class DoctorProfilePage extends StatelessWidget {
  const DoctorProfilePage({super.key});

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
                child: Column(
                  children: [
                    // Top Photo with Gradient Overlay
                    _buildDoctorHeader(context),
                    
                    // Floating Info Card
                    Transform.translate(
                      offset: const Offset(0, -40),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            _buildInfoCard(),
                            const SizedBox(height: 24),
                            _buildAboutSection(),
                            const SizedBox(height: 24),
                            _buildLocationSection(),
                            const SizedBox(height: 32),
                            _buildConsultationAction(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  Widget _buildDoctorHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1559839734-2b71f1536783?q=80&w=600'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.1),
                const Color(0xFFF7FBFB),
              ],
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.black26),
          ),
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. Sarah\nAnindita',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFF80E1D1).withValues(alpha: 0.6), borderRadius: BorderRadius.circular(16)),
                child: const Column(
                  children: [
                    Text('8', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1D5A56))),
                    Text('TAHUN', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF1D5A56))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.medical_services_outlined, color: AppColors.primary, size: 16),
              SizedBox(width: 8),
              Text('Spesialis Kulit & Kelamin', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatBox(Icons.verified_user_outlined, 'Terverifikasi'),
              _buildStatBox(Icons.thumb_up_outlined, '98% Puas'),
              _buildStatBox(Icons.groups_outlined, '500+ Pasien'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(IconData icon, String label) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: Colors.black38, size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(24)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tentang Dokter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text(
            'Dr. Sarah Anindita adalah pakar dermatologi dengan fokus pada kesehatan kulit preventif dan perawatan regeneratif. Beliau aktif dalam penelitian klinis untuk pengobatan jerawat dan rejuvenasi kulit.',
            style: TextStyle(color: Colors.black54, height: 1.6, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Alamat Praktik', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pandara Medical Center,', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Jl. Sudirman No. 45, Jakarta Pusat', style: TextStyle(color: Colors.black38, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('LIHAT DI PETA >', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildConsultationAction(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            const String name = "Dr. Sarah Anindita";
            const String phone = "6285176914026";
            final String message = "Halo $name, saya ingin berkonsultasi mengenai kesehatan saya melalui aplikasi Pandara Health.";
            final Uri url = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");
            try {
              final bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
              if (!launched) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal membuka WhatsApp. Pastikan aplikasi WhatsApp terinstal.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Terjadi kesalahan: $e'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 20),
              SizedBox(width: 8),
              Text('Mulai Konsultasi (WhatsApp)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tersedia Hari Ini: 09:00 - 17:00 WIB',
          style: TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

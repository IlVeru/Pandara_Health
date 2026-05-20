import 'package:flutter/material.dart';
import 'package:pandara_health/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pandara_health/core/constants/weekly_report_data.dart';
import '../../../../core/widgets/app_bottom_nav.dart';

class ConsultationPage extends StatelessWidget {
  const ConsultationPage({super.key});

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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Layanan Telemedisin',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    
                    // Search Bar
                    _buildSearchBar(),
                    
                    const SizedBox(height: 24),
                    
                    // Categories
                    _buildCategories(),
                    
                    const SizedBox(height: 24),
                    
                    // Promo Banner
                    _buildPromoBanner(),
                    
                    const SizedBox(height: 32),
                    const Text(
                      'Daftar Dokter Spesialis Kami',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    _buildDoctorCard(context, 'Dr. Sarah Wijaya', 'Spesialis Penyakit Dalam', '8 Thn', 'https://images.unsplash.com/photo-1559839734-2b71f1536783?q=80&w=200', '6285176914026'),
                    const SizedBox(height: 16),
                    _buildDoctorCard(context, 'Dr. Adrian Pratama', 'Spesialis Jantung', '12 Thn', 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=200', '6285176914026'),
                    const SizedBox(height: 16),
                    _buildDoctorCard(context, 'Dr. Budi Santoso', 'Dokter Umum', '15 Thn', 'https://plus.unsplash.com/premium_photo-1661764878654-3d0fc2eefcca?q=80&w=200', '6285176914026'),
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.black26),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari dokter atau spesialisasi...',
                hintStyle: TextStyle(color: Colors.black26, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = ['Semua', 'Umum', 'Anak', 'Paru', 'Jantung', 'Gizi'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = cat == 'Semua';
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) {},
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? Colors.transparent : Colors.black12),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Konsultasi Pertama\nDiskon 50%',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Mulai perjalanan sehatmu bersama para ahli terbaik kami.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, String name, String spec, String exp, String img, String phone) {
    Color chipColor;
    Color textColor;
    IconData specIcon;

    if (spec.contains('Dalam')) {
      chipColor = const Color(0xFFFFF3E0); // soft orange
      textColor = const Color(0xFFE65100);
      specIcon = Icons.healing_rounded;
    } else if (spec.contains('Jantung')) {
      chipColor = const Color(0xFFFFEBEE); // soft red
      textColor = const Color(0xFFC62828);
      specIcon = Icons.favorite_rounded;
    } else if (spec.contains('Anak')) {
      chipColor = const Color(0xFFE8F5E9); // soft green
      textColor = const Color(0xFF2E7D32);
      specIcon = Icons.child_care_rounded;
    } else {
      // Dokter Umum / default
      chipColor = const Color(0xFFE3F2FD); // soft blue
      textColor = const Color(0xFF1565C0);
      specIcon = Icons.person_outline_rounded;
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () => context.push('/doctor_profile'),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(img),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.verified, color: Colors.blue, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: chipColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(specIcon, size: 13, color: textColor),
                              const SizedBox(width: 4),
                              Text(
                                spec,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildStatItem(Icons.business_center_outlined, exp),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final String reportText = WeeklyReportData.getFormattedReportText();
                  final String message = "Halo $name, saya ingin berkonsultasi mengenai kesehatan saya melalui aplikasi Pandara Health.\n\n$reportText\n\nMohon arahannya dokter, terima kasih.";
                  final Uri url = Uri.parse("https://api.whatsapp.com/send?phone=$phone&text=${Uri.encodeComponent(message)}");
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
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Mulai Konsultasi (WhatsApp)', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.black26),
        const SizedBox(width: 6),
        Text(value, style: const TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

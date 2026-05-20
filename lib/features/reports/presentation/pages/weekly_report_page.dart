import 'package:flutter/material.dart';
import '../../../../core/widgets/app_bottom_nav.dart';

class WeeklyReportPage extends StatelessWidget {
  const WeeklyReportPage({super.key});

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
                      'Laporan Mingguan',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black38),
                        const SizedBox(width: 8),
                        const Text('12 Mei - 18 Mei 2024', style: TextStyle(color: Colors.black38)),
                        const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black38),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Main Insight Card
                    _buildInsightCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Sleep Quality Card
                    _buildSleepQualityCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Small Summary Row
                    Row(
                      children: [
                        _buildSummaryCard(Icons.sentiment_satisfied_alt, '+5%', 'Mood', 'Stabil', Colors.orange, [1, 1, 1, 0.4]),
                        const SizedBox(width: 16),
                        _buildSummaryCard(Icons.directions_run, '-2%', 'Aktivitas', 'Aktif', Colors.teal, [1, 1, 0.4, 0.4]),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    const Text('Rekomendasi Ahli', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildExpertRecommendation(),
                    
                    const SizedBox(height: 24),
                    _buildDetailItem(Icons.favorite, 'Detak Jantung Rata-rata', '72 BPM', Colors.redAccent),
                    const SizedBox(height: 12),
                    _buildDetailItem(Icons.opacity, 'Hidrasi Harian', '2.4 L', Colors.blueAccent),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF20B2AA), Color(0xFF48D1CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              const Text('INSIGHT UTAMA', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidur Anda meningkat 10% minggu ini',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kualitas istirahat Anda lebih konsisten dibandingkan minggu lalu. Pertahankan jadwal tidur pukul 22:00 Anda.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepQualityCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kualitas Tidur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('Rata-rata 7j 45m', style: TextStyle(color: Colors.black26, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFE0F7F9), shape: BoxShape.circle),
                child: const Icon(Icons.nightlight_round, color: Color(0xFF20B2AA), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar('SN', 0.4),
              _buildBar('SL', 0.6),
              _buildBar('RB', 1.0, isSelected: true),
              _buildBar('KM', 0.5),
              _buildBar('JM', 0.4),
              _buildBar('SB', 0.3),
              _buildBar('MG', 0.7),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double height, {bool isSelected = false}) {
    return Column(
      children: [
        Container(
          height: 80 * height,
          width: 36,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF20B2AA) : const Color(0xFFF0F4F5),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isSelected ? const Color(0xFF20B2AA) : Colors.black26,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(IconData icon, String percent, String label, String status, Color color, List<double> pBars) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color.withValues(alpha: 0.6), size: 24),
                Text(percent, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Text(label, style: const TextStyle(color: Colors.black38, fontSize: 12)),
            Text(status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 16),
            Row(
              children: pBars.map((p) => Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: p),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertRecommendation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF0F4F5).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(24)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Image.asset('assets/images/logo_health_fix.png', height: 24, width: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '\"Anda terlihat kurang bergerak di hari kerja. Coba jalan kaki 15 menit setiap jam istirahat makan siang.\"',
                  style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.5, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Dr. Sarah Pandara',
                  style: TextStyle(color: Color(0xFF20B2AA), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.black38, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black12),
        ],
      ),
    );
  }
}

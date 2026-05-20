import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pandara_health/core/constants/app_colors.dart';
import 'package:pandara_health/core/data/models/hive_models.dart';
import 'package:pandara_health/core/data/repositories/health_repository.dart';

class VitalsTrackerPage extends ConsumerStatefulWidget {
  const VitalsTrackerPage({super.key});

  @override
  ConsumerState<VitalsTrackerPage> createState() => _VitalsTrackerPageState();
}

class _VitalsTrackerPageState extends ConsumerState<VitalsTrackerPage> {
  final TextEditingController _heightController = TextEditingController(text: '170');
  final TextEditingController _weightController = TextEditingController(text: '65.5');
  final TextEditingController _heartRateController = TextEditingController(text: '72');
  final TextEditingController _oxygenController = TextEditingController(text: '98');
  final TextEditingController _stepsController = TextEditingController(text: '8000');

  @override
  void initState() {
    super.initState();
    // Prefill with latest vital data if it exists
    final latest = ref.read(healthRepositoryProvider).getLatestVitals();
    if (latest != null) {
      _weightController.text = latest.weight.toString();
      _heartRateController.text = latest.heartRate.toString();
      _stepsController.text = latest.steps.toString();
      if (latest.height != null) {
        _heightController.text = latest.height.toString();
      }
      if (latest.oxygen != null) {
        _oxygenController.text = latest.oxygen.toString();
      }
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Future<void> _saveVitals() async {
    final repository = ref.read(healthRepositoryProvider);
    
    final record = VitalsRecord(
      date: DateTime.now(),
      heartRate: int.tryParse(_heartRateController.text) ?? 72,
      steps: int.tryParse(_stepsController.text) ?? 8000,
      weight: double.tryParse(_weightController.text) ?? 65.5,
      height: int.tryParse(_heightController.text) ?? 170,
      oxygen: int.tryParse(_oxygenController.text) ?? 98,
    );

    await repository.updateVitals(record);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data vitalitas berhasil disimpan!'),
          backgroundColor: AppColors.primary,
        ),
      );
      context.pop();
    }
  }

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
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.black54),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.05),
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
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Catat Data Kesehatan',
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.black38),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Hari ini, ${_getFormattedDate()}',
                                    style: const TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pantau perkembangan vitalitas tubuh Anda secara rutin untuk hasil yang optimal.',
                      style: TextStyle(color: Colors.black54, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    
                    // Body Stats Row
                    Row(
                      children: [
                        _buildHeightCard(),
                        const SizedBox(width: 16),
                        _buildWeightCard(),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Heart Rate Card
                    _buildHeartRateCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Oxygen Card
                    _buildOxygenCard(),
                    
                    const SizedBox(height: 24),
 
                    // Steps Card
                    _buildStepsCard(),
                    
                    const SizedBox(height: 40),
                    
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF00BFA5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _saveVitals,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Simpan Data Kesehatan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(width: 8),
                            Icon(Icons.check_circle_outline, size: 20, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Batal', style: TextStyle(color: Colors.black38)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'Data Anda tersimpan dengan aman dan terenkripsi.',
                        style: TextStyle(color: Colors.black26, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeightCard() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F5FF),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.indigo.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.height_rounded, color: Colors.indigo, size: 18),
                const SizedBox(width: 8),
                Text('TINGGI BADAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo.shade800)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.indigo.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                    ),
                  ),
                  const Text('cm', style: TextStyle(fontSize: 14, color: Colors.black38, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightCard() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF9F6),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_weight_outlined, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text('BERAT BADAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary.withValues(alpha: 0.8))),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                    ),
                  ),
                  const Text('kg', style: TextStyle(fontSize: 14, color: Colors.black38, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartRateCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F2),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    Text('DETAK JANTUNG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red.shade800)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ukur saat tubuh rileks untuk tingkat akurasi data yang lebih baik.',
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _heartRateController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('BPM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8095), Color(0xFFFF2D55)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.redAccent.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 48),
          ),
        ],
      ),
    );
  }

  Widget _buildOxygenCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FF),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.air, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text('KADAR OKSIGEN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kadar oksigen normal berkisar antara 95% - 100%.',
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _oxygenController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('% SpO2', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF80B3FF), Color(0xFF3385FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.blue.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.bubble_chart_rounded, color: Colors.white, size: 48),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EE),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_walk_rounded, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text('LANGKAH HARIAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aktif bergerak menjaga kesehatan jantung dan metabolisme tubuh.',
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _stepsController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('langkah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFC080), Color(0xFFFF9500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.orange.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.directions_run_rounded, color: Colors.white, size: 48),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/dashboard');
          if (index == 1) context.go('/tracker');
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.black26,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          _buildNavItem(Icons.home_outlined, 'BERANDA', false),
          _buildNavItem(Icons.show_chart, 'PELACAK', true),
          _buildNavItem(Icons.assessment_outlined, 'LAPORAN', false),
          _buildNavItem(Icons.medical_services_outlined, 'KONSULTASI', false),
          _buildNavItem(Icons.person_outline, 'PROFIL', false),
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

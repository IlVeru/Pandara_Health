import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandara_health/core/constants/app_colors.dart';
import 'package:pandara_health/core/data/models/hive_models.dart';
import 'package:pandara_health/core/data/repositories/health_repository.dart';
import 'package:go_router/go_router.dart';

class MoodTrackerPage extends ConsumerStatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  ConsumerState<MoodTrackerPage> createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends ConsumerState<MoodTrackerPage> {
  String _selectedMood = 'Neutral';
  final TextEditingController _journalController = TextEditingController();

  final List<Map<String, String>> _moods = [
    {'label': 'Angry', 'emoji': '😠'},
    {'label': 'Sad', 'emoji': '😔'},
    {'label': 'Neutral', 'emoji': '😐'},
    {'label': 'Happy', 'emoji': '😊'},
    {'label': 'Great', 'emoji': '🤩'},
  ];

  Future<void> _saveMood() async {
    final repository = ref.read(healthRepositoryProvider);
    final record = MoodRecord(
      date: DateTime.now(),
      mood: _selectedMood,
      note: _journalController.text,
    );

    await repository.addMood(record);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mood berhasil disimpan!'),
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
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: 'Bagaimana ',
                                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                  children: [
                                    TextSpan(
                                      text: 'perasaanmu',
                                      style: TextStyle(color: AppColors.primary),
                                    ),
                                    TextSpan(text: ' hari ini?'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Luangkan waktu sejenak untuk mengenali emosimu.',
                      style: TextStyle(color: Colors.black54, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    
                    // Mood Tracker Card
                    _buildMoodCard(),
                    
                    const SizedBox(height: 32),
                    const Text.rich(
                      TextSpan(
                        text: 'Apa yang membuatmu merasa begini? ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: '(Opsional)',
                            style: TextStyle(color: Colors.black38, fontSize: 14, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildJournalInput(),
                    
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _saveMood,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Simpan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.check_circle, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Batal', style: TextStyle(color: Colors.black38)),
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

  Widget _buildMoodCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.sentiment_satisfied, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 16),
              const Text('Mood Tracker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _moods.map((mood) {
                final isSelected = _selectedMood == mood['label'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = mood['label']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected 
                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))] 
                        : [],
                    ),
                    child: Column(
                      children: [
                        Text(mood['emoji']!, style: const TextStyle(fontSize: 32)),
                        if (isSelected) ...[
                          const SizedBox(height: 4),
                          Text(
                            mood['label']!,
                            style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08), // Warna kotak status mood
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Text(
              'Anda merasa $_selectedMood hari ini.',
              style: const TextStyle(
                color: AppColors.primary, 
                fontSize: 14, 
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: TextField(
        controller: _journalController,
        maxLines: 8,
        decoration: const InputDecoration(
          hintText: 'Tuliskan detail harimu di sini...',
          hintStyle: TextStyle(color: Colors.black26),
          border: InputBorder.none,
        ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/data/models/hive_models.dart';
import '../../../../core/data/models/weekly_report_model.dart';
import '../../../../core/data/repositories/health_repository.dart';
import '../../../../core/data/services/report_service.dart';
import '../../../../core/widgets/app_bottom_nav.dart';

class WeeklyReportPage extends ConsumerStatefulWidget {
  const WeeklyReportPage({super.key});

  @override
  ConsumerState<WeeklyReportPage> createState() => _WeeklyReportPageState();
}

class _WeeklyReportPageState extends ConsumerState<WeeklyReportPage> {
  DateTimeRange selectedRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 6)),
    end: DateTime.now(),
  );

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: selectedRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedRange = picked;
      });
    }
  }

  String _formatRangeLabel() {
    final months = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"];
    final s = selectedRange.start;
    final e = selectedRange.end;
    final startMonth = months[s.month - 1];
    final endMonth = months[e.month - 1];
    if (s.month == e.month && s.year == e.year) {
      return "${s.day} - ${e.day} $startMonth ${e.year}";
    }
    return "${s.day} $startMonth - ${e.day} $endMonth ${e.year}";
  }

  bool _isInRange(DateTime date) {
    final start = DateTime(selectedRange.start.year, selectedRange.start.month, selectedRange.start.day);
    final end = DateTime(selectedRange.end.year, selectedRange.end.month, selectedRange.end.day);
    final d = DateTime(date.year, date.month, date.day);
    return (d.isAtSameMomentAs(start) || d.isAfter(start)) &&
           (d.isAtSameMomentAs(end) || d.isBefore(end));
  }

  @override
  Widget build(BuildContext context) {
    final reportService = ref.watch(reportServiceProvider);
    final repo = ref.watch(healthRepositoryProvider);
    final report = reportService.getReportForDate(selectedRange.start);

    // Tracker data for selected period
    final moods = repo.getAllMoods().where((m) => _isInRange(m.date)).toList();
    final sleeps = repo.getAllSleep().where((s) => _isInRange(s.date)).toList();
    final vitals = repo.getLatestVitals();
    final nutritionToday = repo.getDailyNutrition(DateTime.now());
    final totalCalToday = nutritionToday.fold(0, (sum, n) => sum + n.calories);

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
                    // Dynamic date range button
                    InkWell(
                      onTap: _selectDateRange,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              _formatRangeLabel(),
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (report == null)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.0),
                          child: Text(
                            "Tidak ada laporan untuk periode ini.\nSilakan pilih tanggal lain.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      )
                    else ...[
                      // Main Insight Card
                      _buildInsightCard(report),
                      const SizedBox(height: 24),

                      // Sleep Quality Card
                      _buildSleepQualityCard(report),
                      const SizedBox(height: 24),

                      // Mood & Activity summary
                      Row(
                        children: [
                          _buildSummaryCard(Icons.sentiment_satisfied_alt, report.moodImprovement, 'Mood', report.moodStatus, Colors.orange, [1, 1, 1, 0.4]),
                          const SizedBox(width: 16),
                          _buildSummaryCard(Icons.directions_run, report.activityChange, 'Aktivitas', report.activityStatus, Colors.teal, [1, 1, 0.4, 0.4]),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Heart rate & Hydration
                      _buildDetailItem(Icons.favorite, 'Detak Jantung Rata-rata', report.avgHeartRate, Colors.redAccent),
                      const SizedBox(height: 12),
                      _buildDetailItem(Icons.opacity, 'Hidrasi Harian', report.dailyHydration, Colors.blueAccent),
                    ],

                    // ── TRACKER RECAP SECTION ────────────────────────────────
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Rekap Tracker',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _formatRangeLabel(),
                            style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Mood Recap
                    _buildTrackerRecapCard(
                      icon: Icons.sentiment_satisfied_alt,
                      label: 'Suasana Hati',
                      color: Colors.orange,
                      content: moods.isEmpty
                          ? null
                          : _buildMoodRecap(moods),
                      emptyLabel: 'Belum ada data mood pada periode ini.',
                    ),
                    const SizedBox(height: 12),

                    // Sleep Recap
                    _buildTrackerRecapCard(
                      icon: Icons.bedtime_outlined,
                      label: 'Tidur',
                      color: Colors.indigo,
                      content: sleeps.isEmpty
                          ? null
                          : _buildSleepRecap(sleeps),
                      emptyLabel: 'Belum ada data tidur pada periode ini.',
                    ),
                    const SizedBox(height: 12),

                    // Vitals Recap
                    _buildTrackerRecapCard(
                      icon: Icons.monitor_heart_outlined,
                      label: 'Vital Terkini',
                      color: Colors.redAccent,
                      content: vitals == null
                          ? null
                          : _buildVitalsRecap(vitals),
                      emptyLabel: 'Belum ada data vital yang tersimpan.',
                    ),
                    const SizedBox(height: 12),

                    // Nutrition Recap
                    _buildTrackerRecapCard(
                      icon: Icons.restaurant_menu,
                      label: 'Nutrisi Hari Ini',
                      color: Colors.green,
                      content: nutritionToday.isEmpty
                          ? null
                          : _buildNutritionRecap(totalCalToday, nutritionToday),
                      emptyLabel: 'Belum ada data nutrisi hari ini.',
                    ),
                    const SizedBox(height: 32),
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

  // ── TRACKER RECAP BUILDERS ─────────────────────────────────────────────────

  Widget _buildTrackerRecapCard({
    required IconData icon,
    required String label,
    required Color color,
    required Widget? content,
    required String emptyLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          content ??
              Text(
                emptyLabel,
                style: const TextStyle(color: Colors.black38, fontSize: 13),
              ),
        ],
      ),
    );
  }

  Widget _buildMoodRecap(List<MoodRecord> moods) {
    // Count per mood
    final count = <String, int>{};
    for (final m in moods) {
      count[m.mood] = (count[m.mood] ?? 0) + 1;
    }
    final moodEmojis = {'Angry': '😠', 'Sad': '😔', 'Neutral': '😐', 'Happy': '😊', 'Great': '🤩'};
    final dominant = count.entries.reduce((a, b) => a.value >= b.value ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              moodEmojis[dominant.key] ?? '😐',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dominan: ${dominant.key}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Total ${moods.length} catatan',
                  style: const TextStyle(color: Colors.black38, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: count.entries.map((e) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${moodEmojis[e.key] ?? ''} ${e.key} (${e.value}x)', style: const TextStyle(fontSize: 11)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSleepRecap(List<SleepRecord> sleeps) {
    final avgHours = sleeps.fold(0.0, (sum, s) => sum + s.hours) / sleeps.length;
    final avgHoursInt = avgHours.floor();
    final avgMins = ((avgHours - avgHoursInt) * 60).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${avgHoursInt}j ${avgMins}m',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text('rata-rata / malam', style: TextStyle(color: Colors.black38, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: sleeps.take(7).map((s) {
            final barHeight = (s.hours / 10).clamp(0.1, 1.0);
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Column(
                children: [
                  Container(
                    height: 40 * barHeight,
                    width: 20,
                    decoration: BoxDecoration(
                      color: Colors.indigo.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${s.hours.toStringAsFixed(0)}j', style: const TextStyle(fontSize: 9, color: Colors.black38)),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text('${sleeps.length} catatan pada periode ini', style: const TextStyle(color: Colors.black38, fontSize: 12)),
      ],
    );
  }

  Widget _buildVitalsRecap(VitalsRecord vitals) {
    return Row(
      children: [
        _buildVitalChip(Icons.favorite, '${vitals.heartRate} BPM', 'Detak Jantung', Colors.redAccent),
        const SizedBox(width: 10),
        _buildVitalChip(Icons.directions_walk, '${vitals.steps}', 'Langkah', Colors.teal),
        if (vitals.weight > 0) ...[
          const SizedBox(width: 10),
          _buildVitalChip(Icons.scale_outlined, '${vitals.weight} kg', 'Berat', Colors.purple),
        ],
      ],
    );
  }

  Widget _buildVitalChip(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
            Text(label, style: const TextStyle(color: Colors.black38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRecap(int totalCal, List<NutritionRecord> records) {
    final totalProtein = records.fold(0, (s, n) => s + n.protein);
    final totalCarbs = records.fold(0, (s, n) => s + n.carbs);
    final totalFat = records.fold(0, (s, n) => s + n.fat);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$totalCal',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(width: 6),
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text('kkal hari ini', style: TextStyle(color: Colors.black38, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMacroChip('Protein', totalProtein, Colors.redAccent),
            const SizedBox(width: 8),
            _buildMacroChip('Karbo', totalCarbs, Colors.orange),
            const SizedBox(width: 8),
            _buildMacroChip('Lemak', totalFat, Colors.blueAccent),
          ],
        ),
        const SizedBox(height: 8),
        Text('${records.length} entri makanan hari ini', style: const TextStyle(color: Colors.black38, fontSize: 12)),
      ],
    );
  }

  Widget _buildMacroChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: ${value}g',
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ── EXISTING REPORT WIDGETS ────────────────────────────────────────────────

  Widget _buildInsightCard(WeeklyReportModel report) {
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
          Text(
            'Tidur Anda ${report.sleepImprovement.startsWith('-') ? 'menurun' : 'meningkat'} ${report.sleepImprovement.replaceAll('+', '').replaceAll('-', '')} minggu ini',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kualitas istirahat Anda bervariasi. Pertahankan jadwal tidur yang teratur.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepQualityCard(WeeklyReportModel report) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kualitas Tidur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('Rata-rata ${report.sleepQuality}', style: const TextStyle(color: Colors.black26, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Color(0xFFE0F7F9), shape: BoxShape.circle),
                child: const Icon(Icons.nightlight_round, color: Color(0xFF20B2AA), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar('SN', report.sleepData.isNotEmpty ? report.sleepData[0] : 0.4),
              _buildBar('SL', report.sleepData.length > 1 ? report.sleepData[1] : 0.6),
              _buildBar('RB', report.sleepData.length > 2 ? report.sleepData[2] : 1.0, isSelected: true),
              _buildBar('KM', report.sleepData.length > 3 ? report.sleepData[3] : 0.5),
              _buildBar('JM', report.sleepData.length > 4 ? report.sleepData[4] : 0.4),
              _buildBar('SB', report.sleepData.length > 5 ? report.sleepData[5] : 0.3),
              _buildBar('MG', report.sleepData.length > 6 ? report.sleepData[6] : 0.7),
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

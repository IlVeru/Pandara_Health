import 'package:hive/hive.dart';
import '../models/hive_models.dart';
import '../models/weekly_report_model.dart';

/// Generates 30 days of realistic dummy data relative to [DateTime.now()].
/// Re-seeds automatically if existing data is from a different year.
class SeedDataService {
  final DateTime _today = DateTime.now();

  /// Returns [today - daysAgo] at midnight.
  DateTime _ago(int daysAgo) {
    final d = _today.subtract(Duration(days: daysAgo));
    return DateTime(d.year, d.month, d.day);
  }

  Future<void> seedAll() async {
    await _clearIfStale();
    await _seedMood();
    await _seedSleep();
    await _seedVitals();
    await _seedNutrition();
    await _seedSymptoms();
    await _seedWeeklyReports();
  }

  // Re-seed if existing mood records are from a previous year
  Future<void> _clearIfStale() async {
    final moodBox = Hive.box<MoodRecord>('mood_box');
    if (moodBox.isNotEmpty) {
      final latest = moodBox.values.first;
      if (latest.date.year != _today.year) {
        await Hive.box<MoodRecord>('mood_box').clear();
        await Hive.box<SleepRecord>('sleep_box').clear();
        await Hive.box<VitalsRecord>('vitals_box').clear();
        await Hive.box<NutritionRecord>('nutrition_box').clear();
        await Hive.box<SymptomRecord>('symptom_box').clear();
        await Hive.box<WeeklyReportModel>('weekly_reports').clear();
      }
    }
  }

  // ── MOOD: 30 days ago → today ─────────────────────────────────────────────
  Future<void> _seedMood() async {
    final box = Hive.box<MoodRecord>('mood_box');
    if (box.isNotEmpty) return;

    // day index 29 = 29 days ago, index 0 = today
    final entries = [
      ['Happy',   'Hari yang menyenangkan, pekerjaan selesai lebih cepat.'],
      ['Happy',   'Olahraga pagi, mood sangat baik.'],
      ['Neutral', 'Hari biasa, sedikit lelah.'],
      ['Sad',     'Tugas menumpuk, sedikit overwhelmed.'],
      ['Neutral', 'Istirahat cukup, mulai lebih baik.'],
      ['Great',   'Weekend! Jalan-jalan dengan keluarga.'],
      ['Great',   'Piknik di taman, sangat segar.'],
      ['Happy',   'Semangat memulai pekan baru.'],
      ['Neutral', 'Meeting panjang, agak capek.'],
      ['Happy',   'Hari libur, menikmati waktu di rumah.'],
      ['Great',   'Bersepeda pagi, energi penuh.'],
      ['Happy',   'Bertemu teman lama, very refreshing.'],
      ['Neutral', 'Agak pusing sejak siang.'],
      ['Sad',     'Kabar kurang baik dari pekerjaan.'],
      ['Angry',   'Macet parah, terlambat meeting.'],
      ['Neutral', 'Mulai pulih, makan enak malam ini.'],
      ['Happy',   'Deadline tercapai, lega sekali!'],
      ['Happy',   'Tidur 8 jam, badan terasa ringan.'],
      ['Great',   'Hiking pagi hari, pemandangan bagus.'],
      ['Happy',   'Produktif dari pagi hingga malam.'],
      ['Great',   'Berhasil masak resep baru, enak!'],
      ['Neutral', 'Sedikit kurang tidur semalam.'],
      ['Neutral', 'Cuaca mendung, mood ikut mendung.'],
      ['Happy',   'Kabar gembira dari keluarga!'],
      ['Great',   'Olahraga + meditasi 20 menit.'],
      ['Happy',   'Rileks di rumah, film favorit.'],
      ['Neutral', 'Pekan baru, semangat meski lelah.'],
      ['Happy',   'Progress project sesuai jadwal.'],
      ['Happy',   'Hari ini sangat produktif!'],
      ['Great',   'Perjalanan singkat, piknik sore.'],
    ];

    for (var i = 0; i < entries.length; i++) {
      await box.add(MoodRecord(
        date: _ago(29 - i),
        mood: entries[i][0],
        note: entries[i][1],
      ));
    }
  }

  // ── SLEEP ─────────────────────────────────────────────────────────────────
  Future<void> _seedSleep() async {
    final box = Hive.box<SleepRecord>('sleep_box');
    if (box.isNotEmpty) return;

    final List<List<dynamic>> data = [
      [7.5, 'Baik'],  [8.0, 'Baik'],  [6.5, 'Cukup'], [5.5, 'Buruk'], [7.0, 'Baik'],
      [8.0, 'Baik'],  [9.0, 'Baik'],  [7.5, 'Baik'],  [6.0, 'Cukup'], [8.0, 'Baik'],
      [7.0, 'Baik'],  [8.5, 'Baik'],  [6.0, 'Cukup'], [5.0, 'Buruk'], [6.5, 'Cukup'],
      [7.0, 'Baik'],  [7.5, 'Baik'],  [8.0, 'Baik'],  [9.0, 'Baik'],  [7.5, 'Baik'],
      [8.0, 'Baik'],  [7.0, 'Baik'],  [6.5, 'Cukup'], [7.0, 'Baik'],  [8.0, 'Baik'],
      [7.5, 'Baik'],  [8.0, 'Baik'],  [7.0, 'Baik'],  [7.5, 'Baik'],  [8.5, 'Baik'],
    ];

    for (var i = 0; i < data.length; i++) {
      await box.add(SleepRecord(
        date: _ago(29 - i),
        hours: (data[i][0] as num).toDouble(),
        quality: data[i][1] as String,
        isRefreshed: (data[i][0] as num) >= 7.0,
      ));
    }
  }

  // ── VITALS ─────────────────────────────────────────────────────────────────
  Future<void> _seedVitals() async {
    final box = Hive.box<VitalsRecord>('vitals_box');
    if (box.isNotEmpty) return;

    final List<List<dynamic>> data = [
      [72, 7200,  68.0, 98], [70, 8500,  68.0, 97], [74, 6000, 68.2, 98],
      [78, 4500,  68.3, 96], [73, 7000,  68.2, 98], [68, 9000, 68.0, 99],
      [66, 11000, 67.8, 99], [71, 7500,  67.9, 98], [75, 6200, 68.0, 97],
      [70, 8000,  67.8, 98], [72, 7600,  67.7, 98], [68, 9500, 67.5, 99],
      [74, 6500,  67.6, 97], [80, 4200,  67.8, 96], [77, 5800, 67.9, 97],
      [73, 7000,  67.8, 98], [72, 7500,  67.6, 98], [70, 8200, 67.5, 99],
      [67, 9800,  67.3, 99], [71, 7800,  67.3, 98], [70, 8000, 67.2, 98],
      [69, 8500,  67.0, 99], [73, 7000,  67.1, 98], [72, 7400, 67.2, 98],
      [70, 8000,  67.0, 99], [71, 7900,  67.0, 98], [70, 8100, 66.9, 99],
      [72, 7500,  66.8, 98], [71, 7800,  66.8, 98], [70, 8200, 66.7, 99],
    ];

    for (var i = 0; i < data.length; i++) {
      await box.add(VitalsRecord(
        date: _ago(29 - i),
        heartRate: data[i][0] as int,
        steps: data[i][1] as int,
        weight: (data[i][2] as double),
        oxygen: data[i][3] as int,
        height: 170,
      ));
    }
  }

  // ── NUTRITION: 3 meals × 30 days ──────────────────────────────────────────
  Future<void> _seedNutrition() async {
    final box = Hive.box<NutritionRecord>('nutrition_box');
    if (box.isNotEmpty) return;

    const meals = [
      ['Sarapan',     350, 12, 45, 10],
      ['Makan Siang', 650, 25, 75, 18],
      ['Makan Malam', 500, 20, 55, 15],
    ];

    for (var day = 0; day < 30; day++) {
      for (final meal in meals) {
        final v = (day % 5) - 2; // variation -2..+2
        await box.add(NutritionRecord(
          date: _ago(29 - day),
          mealType: meal[0] as String,
          calories: (meal[1] as int) + v * 20,
          protein: (meal[2] as int) + v,
          carbs: (meal[3] as int) + v * 3,
          fat: (meal[4] as int) + v,
          selectedFoods: _mealsForType(meal[0] as String),
        ));
      }
    }
  }

  List<String> _mealsForType(String type) {
    switch (type) {
      case 'Sarapan':
        return ['Oatmeal', 'Telur Rebus', 'Jus Alpukat'];
      case 'Makan Siang':
        return ['Nasi Putih', 'Ayam Goreng', 'Tempe Goreng', 'Salad Sayur'];
      default:
        return ['Nasi Putih', 'Soto Ayam'];
    }
  }

  // ── SYMPTOMS: 12 sporadic entries ─────────────────────────────────────────
  Future<void> _seedSymptoms() async {
    final box = Hive.box<SymptomRecord>('symptom_box');
    if (box.isNotEmpty) return;

    final List<List<dynamic>> entries = [
      [28, {'Sakit Kepala': 4.0, 'Kelelahan': 6.0}],
      [24, {'Kelelahan': 5.0, 'Nyeri Punggung': 3.0}],
      [21, {'Sakit Kepala': 3.0}],
      [18, {'Mual': 4.0, 'Pusing': 5.0}],
      [17, {'Demam': 6.0, 'Pilek': 5.0, 'Kelelahan': 7.0}],
      [16, {'Demam': 3.0, 'Pilek': 4.0}],
      [13, {'Nyeri Punggung': 4.0, 'Kelelahan': 3.0}],
      [10, {'Sakit Kepala': 5.0, 'Pusing': 3.0}],
      [8,  {'Kelelahan': 4.0}],
      [5,  {'Nyeri Otot': 5.0, 'Kelelahan': 4.0}],
      [3,  {'Sakit Kepala': 2.0}],
      [1,  {'Kelelahan': 3.0}],
    ];

    for (final entry in entries) {
      await box.add(SymptomRecord(
        date: _ago(entry[0] as int),
        symptoms: Map<String, double>.from(entry[1] as Map),
      ));
    }
  }

  // ── WEEKLY REPORTS: 4 minggu terakhir + minggu berjalan ───────────────────
  Future<void> _seedWeeklyReports() async {
    final box = Hive.box<WeeklyReportModel>('weekly_reports');
    if (box.isNotEmpty) return;

    // Compute week boundaries relative to today
    // week0: current week start (Monday)
    final weekdayOffset = _today.weekday - 1; // Mon=0
    final w0start = _ago(weekdayOffset);       // this Monday
    final w0end   = _ago(0);                  // today

    DateTime ws(int weeksBack) => w0start.subtract(Duration(days: weeksBack * 7));
    DateTime we(int weeksBack) => ws(weeksBack).add(const Duration(days: 6));

    final reports = [
      WeeklyReportModel(
        id: 'week_curr',
        startDate: w0start, endDate: w0end,
        sleepQuality: '7j 50m', sleepImprovement: '+3%',
        moodStatus: 'Stabil',    moodImprovement: '+2%',
        activityStatus: 'Aktif', activityChange: '+5%',
        avgHeartRate: '70 BPM', dailyHydration: '2.6 L',
        sleepData: [0.8, 0.75, 0.8, 0.85, 0.7, 0.9, 0.85],
      ),
      WeeklyReportModel(
        id: 'week_1',
        startDate: ws(1), endDate: we(1),
        sleepQuality: '8j 0m', sleepImprovement: '+15%',
        moodStatus: 'Sangat Baik', moodImprovement: '+12%',
        activityStatus: 'Sangat Aktif', activityChange: '+20%',
        avgHeartRate: '69 BPM', dailyHydration: '2.7 L',
        sleepData: [0.7, 0.8, 0.85, 0.9, 0.75, 0.95, 1.0],
      ),
      WeeklyReportModel(
        id: 'week_2',
        startDate: ws(2), endDate: we(2),
        sleepQuality: '7j 45m', sleepImprovement: '+10%',
        moodStatus: 'Baik',   moodImprovement: '+6%',
        activityStatus: 'Aktif', activityChange: '+8%',
        avgHeartRate: '70 BPM', dailyHydration: '2.5 L',
        sleepData: [0.5, 0.65, 0.55, 0.7, 0.8, 0.9, 1.0],
      ),
      WeeklyReportModel(
        id: 'week_3',
        startDate: ws(3), endDate: we(3),
        sleepQuality: '7j 0m',  sleepImprovement: '-7%',
        moodStatus: 'Cukup',    moodImprovement: '-3%',
        activityStatus: 'Cukup Aktif', activityChange: '-5%',
        avgHeartRate: '74 BPM', dailyHydration: '2.0 L',
        sleepData: [0.75, 0.7, 0.8, 0.45, 0.5, 0.65, 0.7],
      ),
      WeeklyReportModel(
        id: 'week_4',
        startDate: ws(4), endDate: we(4),
        sleepQuality: '7j 30m', sleepImprovement: '+5%',
        moodStatus: 'Baik',     moodImprovement: '+8%',
        activityStatus: 'Aktif', activityChange: '+12%',
        avgHeartRate: '71 BPM', dailyHydration: '2.2 L',
        sleepData: [0.7, 0.8, 0.65, 0.55, 0.7, 0.8, 0.9],
      ),
    ];

    for (final r in reports) {
      await box.put(r.id, r);
    }
  }
}

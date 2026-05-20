import 'package:hive_flutter/hive_flutter.dart';
import '../models/weekly_report_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportServiceProvider = Provider<ReportService>((ref) => ReportService());

class ReportService {
  static const String boxName = 'weekly_reports';

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(WeeklyReportModelAdapter());
    }
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<WeeklyReportModel>(boxName);
    }
    await _seedInitialData();
  }

  Future<void> _seedInitialData() async {
    final box = Hive.box<WeeklyReportModel>(boxName);
    if (box.isEmpty) {
      // Create a mock report for the current week if DB is empty
      final now = DateTime.now();
      final start = now.subtract(Duration(days: now.weekday - 1));
      final end = start.add(const Duration(days: 6));
      
      final mock = WeeklyReportModel(
        id: 'mock_1',
        startDate: DateTime(2024, 5, 12),
        endDate: DateTime(2024, 5, 18),
        sleepQuality: '7j 45m',
        sleepImprovement: '+10%',
        moodStatus: 'Stabil',
        moodImprovement: '+5%',
        activityStatus: 'Aktif',
        activityChange: '-2%',
        avgHeartRate: '72 BPM',
        dailyHydration: '2.4 L',
        sleepData: [0.4, 0.6, 1.0, 0.5, 0.4, 0.3, 0.7],
      );
      
      final mock2 = WeeklyReportModel(
        id: 'mock_2',
        startDate: start,
        endDate: end,
        sleepQuality: '6j 30m',
        sleepImprovement: '-5%',
        moodStatus: 'Cemas',
        moodImprovement: '-10%',
        activityStatus: 'Kurang Aktif',
        activityChange: '-15%',
        avgHeartRate: '78 BPM',
        dailyHydration: '1.8 L',
        sleepData: [0.5, 0.4, 0.3, 0.4, 0.5, 0.6, 0.8],
      );
      
      await box.put(mock.id, mock);
      await box.put(mock2.id, mock2);
    }
  }

  WeeklyReportModel? getReportForDate(DateTime date) {
    final box = Hive.box<WeeklyReportModel>(boxName);
    try {
      return box.values.firstWhere((report) =>
        date.isAfter(report.startDate.subtract(const Duration(days: 1))) && 
        date.isBefore(report.endDate.add(const Duration(days: 1)))
      );
    } catch (e) {
      return null;
    }
  }

  List<WeeklyReportModel> getAllReports() {
    final box = Hive.box<WeeklyReportModel>(boxName);
    return box.values.toList()..sort((a, b) => b.startDate.compareTo(a.startDate));
  }
}

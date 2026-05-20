import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/repositories/health_repository.dart';

final dashboardStatsProvider = Provider((ref) {
  final repository = ref.watch(healthRepositoryProvider);
  
  // Fetch data
  final totalCalories = repository.getTotalCaloriesToday();
  final latestVitals = repository.getLatestVitals();
  final sleepRecords = repository.getAllSleep();
  
  // Calculate average or latest sleep
  double lastSleepHours = sleepRecords.isNotEmpty ? sleepRecords.first.hours : 0;
  
  return DashboardStats(
    calories: totalCalories,
    steps: latestVitals?.steps ?? 0,
    heartRate: latestVitals?.heartRate ?? 0,
    sleepHours: lastSleepHours,
    weight: latestVitals?.weight ?? 0,
  );
});

class DashboardStats {
  final int calories;
  final int steps;
  final int heartRate;
  final double sleepHours;
  final double weight;

  DashboardStats({
    required this.calories,
    required this.steps,
    required this.heartRate,
    required this.sleepHours,
    required this.weight,
  });
}

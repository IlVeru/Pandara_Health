import 'package:hive/hive.dart';

part 'weekly_report_model.g.dart';

@HiveType(typeId: 6)
class WeeklyReportModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startDate;

  @HiveField(2)
  final DateTime endDate;

  @HiveField(3)
  final String sleepQuality;

  @HiveField(4)
  final String sleepImprovement;

  @HiveField(5)
  final String moodStatus;

  @HiveField(6)
  final String moodImprovement;

  @HiveField(7)
  final String activityStatus;

  @HiveField(8)
  final String activityChange;

  @HiveField(9)
  final String avgHeartRate;

  @HiveField(10)
  final String dailyHydration;
  
  @HiveField(11)
  final List<double> sleepData;

  WeeklyReportModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.sleepQuality,
    required this.sleepImprovement,
    required this.moodStatus,
    required this.moodImprovement,
    required this.activityStatus,
    required this.activityChange,
    required this.avgHeartRate,
    required this.dailyHydration,
    this.sleepData = const [0.4, 0.6, 1.0, 0.5, 0.4, 0.3, 0.7],
  });

  String get dateRangeFormatted {
    final startM = _getMonth(startDate.month);
    final endM = _getMonth(endDate.month);
    return "${startDate.day} $startM - ${endDate.day} $endM ${endDate.year}";
  }

  String _getMonth(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"];
    if (month >= 1 && month <= 12) return months[month - 1];
    return "";
  }
}

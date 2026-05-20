class WeeklyReportData {
  static const String dateRange = "12 Mei - 18 Mei 2024";
  static const String sleepQuality = "7j 45m";
  static const String sleepImprovement = "+10%";
  static const String moodStatus = "Stabil";
  static const String moodImprovement = "+5%";
  static const String activityStatus = "Aktif";
  static const String activityChange = "-2%";
  static const String avgHeartRate = "72 BPM";
  static const String dailyHydration = "2.4 L";

  static String getFormattedReportText() {
    return """
\u{1F4CA} RINGKASAN LAPORAN MINGGUAN SAYA ($dateRange):
- \u{1F6CC} Kualitas Tidur: Rata-rata $sleepQuality (Meningkat $sleepImprovement)
- \u{2764}\u{FE0F} Detak Jantung: Rata-rata $avgHeartRate
- \u{1F4A7} Hidrasi Harian: Rata-rata $dailyHydration
- \u{1F3AD} Suasana Hati (Mood): $moodStatus ($moodImprovement)
- \u{1F3C3} Tingkat Aktivitas: $activityStatus ($activityChange)""";
  }
}

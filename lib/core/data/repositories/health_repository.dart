import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/hive_models.dart';

final healthRepositoryProvider = Provider((ref) => HealthRepository());

class HealthRepository {
  // Boxes
  final _userBox = Hive.box<UserModel>('user_box');
  final _moodBox = Hive.box<MoodRecord>('mood_box');
  final _sleepBox = Hive.box<SleepRecord>('sleep_box');
  final _vitalsBox = Hive.box<VitalsRecord>('vitals_box');
  final _nutritionBox = Hive.box<NutritionRecord>('nutrition_box');
  final _symptomBox = Hive.box<SymptomRecord>('symptom_box');

  // --- USER PROFILE ---
  Future<void> saveUser(UserModel user) async {
    await _userBox.put('current_user', user);
    await _userBox.flush();
  }

  UserModel? getUser() {
    return _userBox.get('current_user');
  }

  // --- MOOD TRACKER ---
  Future<void> addMood(MoodRecord record) async {
    await _moodBox.add(record);
    await _moodBox.flush();
  }

  List<MoodRecord> getAllMoods() {
    return _moodBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  // --- SLEEP TRACKER ---
  Future<void> addSleep(SleepRecord record) async {
    await _sleepBox.add(record);
    await _sleepBox.flush();
  }

  List<SleepRecord> getAllSleep() {
    return _sleepBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  // --- VITALS TRACKER ---
  Future<void> updateVitals(VitalsRecord record) async {
    // We can store vitals per day, using date as key or just adding to history
    await _vitalsBox.add(record);
    await _vitalsBox.flush();
  }

  VitalsRecord? getLatestVitals() {
    if (_vitalsBox.isEmpty) return null;
    return _vitalsBox.values.last;
  }

  // --- NUTRITION TRACKER ---
  Future<void> addNutrition(NutritionRecord record) async {
    await _nutritionBox.add(record);
    await _nutritionBox.flush();
  }

  List<NutritionRecord> getDailyNutrition(DateTime date) {
    return _nutritionBox.values.where((rec) => 
      rec.date.year == date.year && 
      rec.date.month == date.month && 
      rec.date.day == date.day
    ).toList();
  }

  int getTotalCaloriesToday() {
    final now = DateTime.now();
    final todayRecs = getDailyNutrition(now);
    return todayRecs.fold(0, (sum, item) => sum + item.calories);
  }

  // --- SYMPTOM TRACKER ---
  Future<void> addSymptom(SymptomRecord record) async {
    await _symptomBox.add(record);
    await _symptomBox.flush();
  }
}

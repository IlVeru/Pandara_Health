import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pandara_health/core/constants/app_colors.dart';
import 'package:pandara_health/core/data/models/hive_models.dart';

class DatabaseInspectorPage extends StatelessWidget {
  const DatabaseInspectorPage({super.key});

  Future<void> _injectPreset(
    BuildContext context, {
    VitalsRecord? vitals,
    MoodRecord? mood,
    SleepRecord? sleep,
    SymptomRecord? symptom,
    List<NutritionRecord>? nutrition,
    bool clearNutrition = false,
  }) async {
    final now = DateTime.now();
    bool isToday(DateTime d) =>
        d.year == now.year && d.month == now.month && d.day == now.day;

    // Clear mood
    final moodBox = Hive.box<MoodRecord>('mood_box');
    final moodKeys = moodBox.keys.where((k) {
      final val = moodBox.get(k);
      return val != null && isToday(val.date);
    }).toList();
    for (var k in moodKeys) {
      await moodBox.delete(k);
    }

    // Clear sleep
    final sleepBox = Hive.box<SleepRecord>('sleep_box');
    final sleepKeys = sleepBox.keys.where((k) {
      final val = sleepBox.get(k);
      return val != null && isToday(val.date);
    }).toList();
    for (var k in sleepKeys) {
      await sleepBox.delete(k);
    }

    // Clear vitals
    final vitalsBox = Hive.box<VitalsRecord>('vitals_box');
    final vitalsKeys = vitalsBox.keys.where((k) {
      final val = vitalsBox.get(k);
      return val != null && isToday(val.date);
    }).toList();
    for (var k in vitalsKeys) {
      await vitalsBox.delete(k);
    }

    // Clear symptoms
    final symptomBox = Hive.box<SymptomRecord>('symptom_box');
    final symptomKeys = symptomBox.keys.where((k) {
      final val = symptomBox.get(k);
      return val != null && isToday(val.date);
    }).toList();
    for (var k in symptomKeys) {
      await symptomBox.delete(k);
    }

    // Clear nutrition
    final nutritionBox = Hive.box<NutritionRecord>('nutrition_box');
    if (clearNutrition) {
      final nutritionKeys = nutritionBox.keys.where((k) {
        final val = nutritionBox.get(k);
        return val != null && isToday(val.date);
      }).toList();
      for (var k in nutritionKeys) {
        await nutritionBox.delete(k);
      }
    }

    // Inject new records
    if (vitals != null) await vitalsBox.add(vitals);
    if (mood != null) await moodBox.add(mood);
    if (sleep != null) await sleepBox.add(sleep);
    if (symptom != null) await symptomBox.add(symptom);
    if (nutrition != null) {
      for (var n in nutrition) {
        await nutritionBox.add(n);
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preset triase berhasil disuntikkan!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Widget _buildTriageSimulatorSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.health_and_safety_outlined,
                  color: Colors.teal.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Triage Simulator / Presets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Gunakan tombol di bawah untuk menyimulasikan data kesehatan hari ini secara instan.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _injectPreset(
                    context,
                    vitals: VitalsRecord(
                      date: DateTime.now(),
                      heartRate: 72,
                      steps: 5000,
                      weight: 65,
                      height: 170,
                      oxygen: 90,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Skenario A: SpO2 90%',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _injectPreset(
                    context,
                    vitals: VitalsRecord(
                      date: DateTime.now(),
                      heartRate: 130,
                      steps: 5000,
                      weight: 65,
                      height: 170,
                      oxygen: 98,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Skenario A: Jantung 130 bpm',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _injectPreset(
                    context,
                    symptom: SymptomRecord(
                      date: DateTime.now(),
                      symptoms: {'Demam': 9.0},
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Skenario A: Gejala Parah',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _injectPreset(
                    context,
                    mood: MoodRecord(
                      date: DateTime.now(),
                      mood: 'Sad',
                      note: 'Hari yang berat',
                    ),
                    sleep: SleepRecord(
                      date: DateTime.now(),
                      hours: 3.0,
                      quality: 'Buruk',
                      isRefreshed: false,
                    ),
                    symptom: SymptomRecord(
                      date: DateTime.now(),
                      symptoms: {'Demam': 6.0, 'Pusing': 5.0},
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade400,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Skenario B: Akumulatif Mental/Tidur',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _injectPreset(
                    context,
                    mood: MoodRecord(
                      date: DateTime.now(),
                      mood: 'Angry',
                      note: 'Marah-marah',
                    ),
                    sleep: SleepRecord(
                      date: DateTime.now(),
                      hours: 5.5,
                      quality: 'Buruk',
                      isRefreshed: false,
                    ),
                    clearNutrition: true,
                    nutrition: [
                      NutritionRecord(
                        date: DateTime.now(),
                        calories: 850,
                        mealType: 'Makan Malam',
                        protein: 32,
                        carbs: 90,
                        fat: 22,
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Skenario C: Habits (Skip Breakfast & Lunch)',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _injectPreset(
                    context,
                    vitals: VitalsRecord(
                      date: DateTime.now(),
                      heartRate: 72,
                      steps: 8000,
                      weight: 65,
                      height: 170,
                      oxygen: 98,
                    ),
                    mood: MoodRecord(
                      date: DateTime.now(),
                      mood: 'Happy',
                      note: 'Sehat bugar',
                    ),
                    sleep: SleepRecord(
                      date: DateTime.now(),
                      hours: 8.0,
                      quality: 'Baik',
                      isRefreshed: true,
                    ),
                    symptom: SymptomRecord(date: DateTime.now(), symptoms: {}),
                    clearNutrition: true,
                    nutrition: [
                      NutritionRecord(
                        date: DateTime.now(),
                        calories: 500,
                        mealType: 'Sarapan',
                        protein: 25,
                        carbs: 60,
                        fat: 12,
                      ),
                      NutritionRecord(
                        date: DateTime.now(),
                        calories: 700,
                        mealType: 'Makan Siang',
                        protein: 35,
                        carbs: 80,
                        fat: 20,
                      ),
                      NutritionRecord(
                        date: DateTime.now(),
                        calories: 600,
                        mealType: 'Makan Malam',
                        protein: 30,
                        carbs: 70,
                        fat: 18,
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Skenario D: Kondisi Aman',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _injectPreset(context, clearNutrition: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Clear Hari Ini',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Inspector'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTriageSimulatorSection(context),
          const SizedBox(height: 24),
          _buildBoxSection<UserModel>('user_box', 'Daftar Pengguna (Users)'),
          const SizedBox(height: 16),
          _buildBoxSection<MoodRecord>('mood_box', 'Catatan Mood'),
          const SizedBox(height: 16),
          _buildBoxSection<SleepRecord>('sleep_box', 'Catatan Tidur'),
          const SizedBox(height: 16),
          _buildBoxSection<VitalsRecord>('vitals_box', 'Data Vital'),
          const SizedBox(height: 16),
          _buildBoxSection<NutritionRecord>('nutrition_box', 'Catatan Nutrisi'),
          const SizedBox(height: 16),
          _buildBoxSection<SymptomRecord>(
            'symptom_box',
            'Catatan Gejala (Symptoms)',
          ),
          const SizedBox(height: 16),
          _buildBoxSection('settings_box', 'Pengaturan & Sesi'),
        ],
      ),
    );
  }

  Widget _buildBoxSection<T>(String boxName, String title) {
    if (!Hive.isBoxOpen(boxName)) {
      return Card(
        child: ListTile(
          title: Text(title),
          subtitle: const Text('Box belum dibuka'),
        ),
      );
    }

    late Box box;
    try {
      box = Hive.box(boxName);
    } catch (_) {
      if (boxName == 'user_box') {
        box = Hive.box<UserModel>(boxName);
      } else if (boxName == 'mood_box') {
        box = Hive.box<MoodRecord>(boxName);
      } else if (boxName == 'sleep_box') {
        box = Hive.box<SleepRecord>(boxName);
      } else if (boxName == 'vitals_box') {
        box = Hive.box<VitalsRecord>(boxName);
      } else if (boxName == 'nutrition_box') {
        box = Hive.box<NutritionRecord>(boxName);
      } else if (boxName == 'symptom_box') {
        box = Hive.box<SymptomRecord>(boxName);
      } else {
        rethrow;
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: const Icon(Icons.storage, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${box.length} data ditemukan'),
        children: [
          if (box.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Box kosong', style: TextStyle(color: Colors.grey)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: box.length,
              separatorBuilder: (_, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final key = box.keyAt(index);
                final value = box.getAt(index);

                return ListTile(
                  title: Text(
                    'Key: $key',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      value.toString(),
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

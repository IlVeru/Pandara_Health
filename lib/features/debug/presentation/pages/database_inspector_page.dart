import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pandara_health/core/constants/app_colors.dart';
import 'package:pandara_health/core/data/models/hive_models.dart';

class DatabaseInspectorPage extends StatelessWidget {
  const DatabaseInspectorPage({super.key});

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
      // Jika gagal karena tipe mismatch, coba dengan tipe spesifik
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
                  title: Text('Key: $key', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(value.toString(), style: const TextStyle(color: Colors.black87)),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

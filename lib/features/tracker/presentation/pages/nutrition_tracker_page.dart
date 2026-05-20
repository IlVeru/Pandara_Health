import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pandara_health/core/constants/app_colors.dart';
import 'package:pandara_health/core/data/models/hive_models.dart';
import 'package:pandara_health/core/data/models/food_item.dart';
import 'package:pandara_health/core/data/repositories/health_repository.dart';
import 'package:pandara_health/core/data/services/fatsecret_service.dart';

class NutritionTrackerPage extends ConsumerStatefulWidget {
  const NutritionTrackerPage({super.key});

  @override
  ConsumerState<NutritionTrackerPage> createState() => _NutritionTrackerPageState();
}

class _NutritionTrackerPageState extends ConsumerState<NutritionTrackerPage> {
  String _selectedMealTime = 'Makan Siang';
  final List<FoodItem> _selectedFoods = [];
  
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _searchResults = [];
  bool _isLoadingSearch = false;

  final List<Map<String, dynamic>> _mealTimes = [
    {'label': 'Sarapan', 'icon': Icons.wb_sunny_outlined, 'color': const Color(0xFFFF9800)},
    {'label': 'Makan Siang', 'icon': Icons.restaurant_outlined, 'color': const Color(0xFF4CAF50)},
    {'label': 'Makan Malam', 'icon': Icons.nightlight_outlined, 'color': const Color(0xFF3F51B5)},
    {'label': 'Cemilan', 'icon': Icons.cookie_outlined, 'color': const Color(0xFFE91E63)},
  ];

  // Shortcut List Makanan Populer
  final List<FoodItem> _shortcuts = [
    FoodItem(name: '🥚 Telur Rebus', calories: 78, protein: 6, carbs: 1, fat: 5, serving: '1 Butir'),
    FoodItem(name: '🍳 Telur Dadar', calories: 93, protein: 7, carbs: 1, fat: 7, serving: '1 Butir'),
    FoodItem(name: '🍚 Nasi Putih', calories: 204, protein: 4, carbs: 45, fat: 0, serving: '1 Mangkok (150g)'),
    FoodItem(name: '🍗 Ayam Goreng', calories: 246, protein: 25, carbs: 0, fat: 16, serving: '1 Potong (100g)'),
    FoodItem(name: '🍌 Pisang', calories: 89, protein: 1, carbs: 23, fat: 0, serving: '1 Buah (100g)'),
    FoodItem(name: '🍞 Roti Tawar', calories: 74, protein: 3, carbs: 14, fat: 1, serving: '1 Lembar'),
    FoodItem(name: '☕ Kopi Hitam', calories: 2, protein: 0, carbs: 0, fat: 0, serving: '1 Cangkir'),
  ];

  @override
  void initState() {
    super.initState();
    // Preefill gizi hari ini jika sudah pernah dicatat sebelumnya
    final todayRecs = ref.read(healthRepositoryProvider).getDailyNutrition(DateTime.now());
    if (todayRecs.isNotEmpty) {
      final latest = todayRecs.last;
      _selectedMealTime = latest.mealType;
      if (latest.selectedFoods != null) {
        try {
          for (var s in latest.selectedFoods!) {
            _selectedFoods.add(FoodItem.fromJson(s));
          }
        } catch (e) {
          // Abaikan jika gagal parse
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoadingSearch = false;
      });
      return;
    }
    setState(() => _isLoadingSearch = true);
    try {
      final results = await ref.read(fatSecretServiceProvider).searchFood(query);
      setState(() {
        _searchResults = results;
      });
      if (results.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Makanan tidak ditemukan. Coba kata kunci lain.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // ignore
    } finally {
      setState(() => _isLoadingSearch = false);
    }
  }

  int get _totalCalories => _selectedFoods.fold(0, (sum, item) => sum + item.calories);
  int get _totalProtein => _selectedFoods.fold(0, (sum, item) => sum + item.protein);
  int get _totalCarbs => _selectedFoods.fold(0, (sum, item) => sum + item.carbs);
  int get _totalFat => _selectedFoods.fold(0, (sum, item) => sum + item.fat);

  Future<void> _saveNutrition() async {
    if (_selectedFoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih atau tambahkan makanan terlebih dahulu!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final repository = ref.read(healthRepositoryProvider);
    
    final record = NutritionRecord(
      date: DateTime.now(),
      calories: _totalCalories,
      mealType: _selectedMealTime,
      protein: _totalProtein,
      carbs: _totalCarbs,
      fat: _totalFat,
      selectedFoods: _selectedFoods.map((f) => f.toJson()).toList(),
    );

    await repository.addNutrition(record);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan nutrisi berhasil disimpan!'),
          backgroundColor: AppColors.primary,
        ),
      );
      context.pop();
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
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
                    // Title section
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Catat Data Nutrisi',
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.black38),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Hari ini, ${_getFormattedDate()}',
                                    style: const TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pantau kalori dan asupan makronutrisi harian Anda untuk keseimbangan energi tubuh.',
                      style: TextStyle(color: Colors.black54, height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    // Ringkasan Estimasi Total Gizi
                    _buildCalorieCard(),
                    const SizedBox(height: 28),

                    // Meal Time Selector
                    const Text('Pilih Waktu Makan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    _buildMealTimeSelector(),
                    const SizedBox(height: 28),

                    // Shortcuts Makanan Populer
                    const Text('Rekomendasi Menu Cepat', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    _buildShortcutList(),
                    const SizedBox(height: 28),

                    // Card Pencarian FatSecret & Tips
                    _buildSearchCard(),
                    const SizedBox(height: 28),

                    // Card Input Manual (Standalone)
                    _buildManualInputCard(),
                    const SizedBox(height: 28),

                    // Card Makanan Terpilih
                    _buildSelectedFoodsCard(),
                    const SizedBox(height: 40),

                    // Simpan Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF00BFA5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _saveNutrition,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Simpan Catatan Gizi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(width: 8),
                            Icon(Icons.check_circle_outline, size: 20, color: Colors.white),
                          ],
                        ),
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

  Widget _buildMealTimeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _mealTimes.map((meal) {
        final isSelected = _selectedMealTime == meal['label'];
        final color = meal['color'] as Color;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedMealTime = meal['label']),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? color : Colors.black.withValues(alpha: 0.05),
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))]
                    : null,
              ),
              child: Column(
                children: [
                  Icon(meal['icon'] as IconData, color: isSelected ? color : Colors.black38, size: 20),
                  const SizedBox(height: 6),
                  Text(
                    meal['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? color : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalorieCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF00BFA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ESTIMASI NUTRISI MASUK', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: '$_totalCalories ',
              style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold),
              children: const [
                TextSpan(text: 'kcal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroInfo('${_totalProtein}g', 'PROTEIN', _totalProtein / 100),
              const SizedBox(width: 12),
              _buildMacroInfo('${_totalCarbs}g', 'KARBOHIDRAT', _totalCarbs / 300),
              const SizedBox(width: 12),
              _buildMacroInfo('${_totalFat}g', 'LEMAK', _totalFat / 80),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroInfo(String value, String label, double progress) {
    // Clamp progress between 0.0 and 1.0 to avoid UI errors
    final double clampedProgress = progress.clamp(0.0, 1.0);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: clampedProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutList() {
    return SizedBox(
      height: 125,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _shortcuts.length,
        itemBuilder: (context, index) {
          final food = _shortcuts[index];
          final parts = food.name.split(' ');
          final emoji = parts.isNotEmpty ? parts.first : '🍛';
          final name = parts.length > 1 ? parts.sublist(1).join(' ') : food.name;

          return Container(
            width: 115,
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _showQuantityDialog(food),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.05),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.015),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${food.calories} kcal',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Cari Makanan & Minuman Anda',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Textfield Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) => _performSearch(),
                    onChanged: (value) {
                      setState(() {});
                    },
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: 'Ketik nama makanan atau minuman...',
                      hintStyle: TextStyle(color: Colors.black26, fontSize: 13, fontWeight: FontWeight.normal),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                _isLoadingSearch
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchResults = [];
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.cancel_rounded, color: Colors.black26, size: 20),
                              ),
                            ),
                          GestureDetector(
                            onTap: _performSearch,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.search_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),

          // ListView hasil pencarian (hanya muncul saat ada hasil)
          if (_searchResults.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.015),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16, color: Colors.black12),
                itemBuilder: (context, index) {
                  final food = _searchResults[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    dense: true,
                    title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('${food.serving} • ${food.calories} kcal', style: const TextStyle(color: Colors.black38, fontSize: 11)),
                    trailing: const Icon(Icons.add_circle, color: AppColors.primary, size: 20),
                    onTap: () async {
                      final nav = Navigator.of(context);
                      if (food.foodId != null) {
                        setState(() { _isLoadingSearch = true; });
                        final servings = await ref.read(fatSecretServiceProvider).getFoodServings(food.foodId!, food.name);
                        setState(() { _isLoadingSearch = false; });
                        
                        if (servings.isNotEmpty) {
                          if (!mounted) return;
                          _showServingSelectionDialog(food, servings);
                        } else {
                          _showQuantityDialog(food);
                        }
                      } else {
                        _showQuantityDialog(food);
                      }
                      
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                      });
                    },
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 20),
          // Divider tipis pembatas tips
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 16),

          // Tips / Instruction Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFBFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Colors.black45, size: 14),
                    SizedBox(width: 6),
                    Text('TIPS PENCATATAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 0.5)),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Tuliskan makanan atau minuman yang baru saja Anda konsumsi.\n\n'
                  'Contoh:\n'
                  'Roti tawar isi daging dan keju, satu buah apel, pisang, dan kopi susu\n\n'
                  'Klik pada hasil pencarian untuk menambahkan dan melihat rincian gizi.\n\n'
                  'Catatan:\n'
                  'Mendukung deskripsi pencarian hingga maksimal 1000 karakter.',
                  style: TextStyle(color: Colors.black54, fontSize: 11, height: 1.5, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualInputCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Input Makanan Secara Manual',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Jika makanan atau minuman yang Anda konsumsi tidak ditemukan di pencarian database, silakan tambahkan data gizinya secara manual di sini.',
            style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: InkWell(
              onTap: _showManualInputDialog,
              borderRadius: BorderRadius.circular(16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Tambah Makanan Kustom',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFoodsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant_menu_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Makanan & Minuman Pilihan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary.withValues(alpha: 0.9)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedFoods.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(Icons.no_meals_rounded, size: 48, color: Colors.black.withValues(alpha: 0.15)),
                    const SizedBox(height: 12),
                    const Text(
                      'Belum ada makanan yang dipilih.\nCari di database atau gunakan shortcut di atas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black38, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selectedFoods.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final food = _selectedFoods[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FBFB),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.025)),
                  ),
                  child: Row(
                    children: [
                      // Circular badge or leading icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.fastfood_rounded, color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              food.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${food.serving} • ${food.calories} kcal',
                              style: const TextStyle(color: Colors.black45, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            // Macro breakdown layout tags
                            Row(
                              children: [
                                _buildMacroTag('P: ${food.protein}g', const Color(0xFFFF8095)),
                                const SizedBox(width: 6),
                                _buildMacroTag('K: ${food.carbs}g', const Color(0xFF80B3FF)),
                                const SizedBox(width: 6),
                                _buildMacroTag('L: ${food.fat}g', const Color(0xFFFFC080)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedFoods.removeAt(index);
                          });
                        },
                        icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 20),
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(36, 36),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMacroTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showManualInputDialog() {
    final nameController = TextEditingController();
    final calController = TextEditingController();
    final protController = TextEditingController();
    final carbController = TextEditingController();
    final fatController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tambah Manual', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.black38),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDialogField('Nama Makanan / Minuman', nameController, TextInputType.text, 'Contoh: Nasi Liwet'),
                _buildDialogField('Kalori (kcal)', calController, TextInputType.number, 'Contoh: 150'),
                Row(
                  children: [
                    Expanded(child: _buildDialogField('Protein (g)', protController, TextInputType.number, '0')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDialogField('Karbo (g)', carbController, TextInputType.number, '0')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDialogField('Lemak (g)', fatController, TextInputType.number, '0')),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF00BFA5)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isEmpty || calController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nama dan Kalori harus diisi!'), backgroundColor: Colors.redAccent),
                        );
                        return;
                      }
                      final newItem = FoodItem(
                        name: nameController.text.trim(),
                        calories: int.tryParse(calController.text) ?? 0,
                        protein: int.tryParse(protController.text) ?? 0,
                        carbs: int.tryParse(carbController.text) ?? 0,
                        fat: int.tryParse(fatController.text) ?? 0,
                        serving: '1 Porsi',
                      );
                      setState(() {
                        _selectedFoods.add(newItem);
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Tambahkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller, TextInputType type, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller,
              keyboardType: type,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.black26, fontSize: 13, fontWeight: FontWeight.normal),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showServingSelectionDialog(FoodItem baseFood, List<FoodItem> servings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Takaran untuk ${baseFood.name}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: servings.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
                  itemBuilder: (context, index) {
                    final s = servings[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(s.serving, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('${s.calories} kcal • P: ${s.protein}g, K: ${s.carbs}g, L: ${s.fat}g', style: const TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
                      onTap: () {
                        Navigator.pop(context);
                        _showQuantityDialog(s);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuantityDialog(FoodItem food) {
    double quantity = 1.0;
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final totalCalories = (food.calories * quantity).round();
            final totalProtein = (food.protein * quantity).toStringAsFixed(1);
            final totalCarbs = (food.carbs * quantity).toStringAsFixed(1);
            final totalFat = (food.fat * quantity).toStringAsFixed(1);

            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header / Emoji Badge
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        food.name.split(' ').first,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      food.name.replaceFirst(food.name.split(' ').first, '').trim(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Porsi Standar: ${food.serving} (${food.calories} kcal)',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),

                    // Quantity Selector Row (- [ 1 ] +)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Minus Button
                        IconButton.filled(
                          onPressed: quantity > 0.5
                              ? () {
                                  setDialogState(() {
                                    quantity -= 0.5;
                                    quantityController.text = quantity % 1 == 0
                                        ? quantity.toInt().toString()
                                        : quantity.toString();
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.remove_rounded, color: Colors.white, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // TextField for manual entry
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: quantityController,
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (val) {
                              final parsed = double.tryParse(val);
                              if (parsed != null && parsed > 0) {
                                setDialogState(() {
                                  quantity = parsed;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Plus Button
                        IconButton.filled(
                          onPressed: () {
                            setDialogState(() {
                              quantity += 0.5;
                              quantityController.text = quantity % 1 == 0
                                  ? quantity.toInt().toString()
                                  : quantity.toString();
                            });
                          },
                          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Preview of scaled nutrition values
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Energi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
                              Text('$totalCalories kcal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                            ],
                          ),
                          const Divider(height: 16, color: Colors.black12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildDialogMacroBadge('Prot', '${totalProtein}g', const Color(0xFFFF9800)),
                              _buildDialogMacroBadge('Karb', '${totalCarbs}g', const Color(0xFF4CAF50)),
                              _buildDialogMacroBadge('Lemak', '${totalFat}g', const Color(0xFFE91E63)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actions Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              side: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
                            ),
                            child: const Text('Batal', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final finalFood = FoodItem(
                                name: food.name,
                                calories: totalCalories,
                                protein: (food.protein * quantity).round(),
                                carbs: (food.carbs * quantity).round(),
                                fat: (food.fat * quantity).round(),
                                serving: '${quantity % 1 == 0 ? quantity.toInt() : quantity}x porsi (${food.serving})',
                              );
                              setState(() {
                                _selectedFoods.add(finalFood);
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${food.name} ($quantity porsi) ditambahkan!'),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Tambahkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogMacroBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
      ],
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

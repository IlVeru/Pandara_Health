// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';

final fatSecretServiceProvider = Provider((ref) => FatSecretService());

class FatSecretService {
  // Masukkan credentials FatSecret Anda di sini jika ada
  static const String _clientId = '71d6115b3d0f4072a21cb75a07b08cfe'; 
  static const String _clientSecret = '5855d1e9823b4622bdc05758c6a5832a';

  String? _accessToken;
  DateTime? _tokenExpiry;

  // Database makanan tiruan lengkap (Indonesian & Western) untuk simulasi offline / tanpa API key
  final List<FoodItem> _mockFoods = [
    FoodItem(name: 'Nasi Putih', calories: 204, protein: 4, carbs: 45, fat: 0, serving: '1 Mangkok (150g)'),
    FoodItem(name: 'Nasi Goreng', calories: 350, protein: 10, carbs: 50, fat: 12, serving: '1 Porsi (250g)'),
    FoodItem(name: 'Telur Dadar', calories: 93, protein: 7, carbs: 1, fat: 7, serving: '1 Butir'),
    FoodItem(name: 'Telur Rebus', calories: 78, protein: 6, carbs: 1, fat: 5, serving: '1 Butir'),
    FoodItem(name: 'Ayam Goreng', calories: 246, protein: 25, carbs: 0, fat: 16, serving: '1 Potong (100g)'),
    FoodItem(name: 'Ayam Bakar', calories: 180, protein: 26, carbs: 2, fat: 8, serving: '1 Potong (100g)'),
    FoodItem(name: 'Ayam Geprek', calories: 263, protein: 19, carbs: 16, fat: 14, serving: '1 Porsi (150g)'),
    FoodItem(name: 'Sate Ayam', calories: 150, protein: 18, carbs: 5, fat: 6, serving: '5 Tusuk'),
    FoodItem(name: 'Bakso Sapi', calories: 320, protein: 15, carbs: 25, fat: 18, serving: '1 Mangkok'),
    FoodItem(name: 'Mie Goreng', calories: 380, protein: 8, carbs: 56, fat: 14, serving: '1 Porsi'),
    FoodItem(name: 'Mie Instan', calories: 380, protein: 8, carbs: 54, fat: 14, serving: '1 Bungkus (80g)'),
    FoodItem(name: 'Gado-Gado', calories: 295, protein: 12, carbs: 35, fat: 14, serving: '1 Porsi'),
    FoodItem(name: 'Kopi Susu', calories: 120, protein: 3, carbs: 15, fat: 5, serving: '1 Gelas'),
    FoodItem(name: 'Apel', calories: 52, protein: 0, carbs: 14, fat: 0, serving: '1 Buah (100g)'),
    FoodItem(name: 'Pisang', calories: 89, protein: 1, carbs: 23, fat: 0, serving: '1 Buah (100g)'),
    FoodItem(name: 'Tempe Goreng', calories: 118, protein: 7, carbs: 9, fat: 7, serving: '1 Potong'),
    FoodItem(name: 'Tahu Goreng', calories: 78, protein: 5, carbs: 2, fat: 6, serving: '1 Potong'),
    FoodItem(name: 'Susu Sapi UHT', calories: 146, protein: 8, carbs: 12, fat: 8, serving: '1 Gelas (240ml)'),
    FoodItem(name: 'Salad Sayur', calories: 65, protein: 2, carbs: 10, fat: 2, serving: '1 Mangkok'),
    FoodItem(name: 'Bubur Ayam', calories: 250, protein: 12, carbs: 38, fat: 6, serving: '1 Porsi'),
    FoodItem(name: 'Roti Tawar', calories: 74, protein: 3, carbs: 14, fat: 1, serving: '1 Lembar'),
    FoodItem(name: 'Oatmeal', calories: 150, protein: 5, carbs: 27, fat: 3, serving: '1 Mangkok'),
    FoodItem(name: 'Jus Alpukat', calories: 195, protein: 2, carbs: 22, fat: 12, serving: '1 Gelas'),
    FoodItem(name: 'Soto Ayam', calories: 312, protein: 18, carbs: 28, fat: 14, serving: '1 Mangkok'),
    FoodItem(name: 'Rendang Sapi', calories: 195, protein: 14, carbs: 3, fat: 15, serving: '1 Potong'),
    FoodItem(name: 'Martabak Manis', calories: 270, protein: 6, carbs: 37, fat: 11, serving: '1 Potong (60g)'),
    FoodItem(name: 'Nasi Uduk', calories: 260, protein: 5, carbs: 40, fat: 9, serving: '1 Porsi (150g)'),
    FoodItem(name: 'Pecel Lele', calories: 220, protein: 18, carbs: 0, fat: 15, serving: '1 Porsi (120g)'),
  ];

  Future<void> _fetchToken() async {
    if (_clientId.isEmpty || _clientSecret.isEmpty) return;

    if (_accessToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return;
    }

    try {
      print('FatSecret: Fetching access token...');
      final String credentials = base64Encode(utf8.encode('$_clientId:$_clientSecret'));
      final response = await http.post(
        Uri.parse('https://oauth.fatsecret.com/connect/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
          'scope': 'basic',
        },
      );

      print('FatSecret Token response code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        final int expiresIn = data['expires_in'] ?? 3600;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60));
        print('FatSecret Token fetched successfully!');
      } else {
        print('FatSecret Token Fetch Failed: ${response.body}');
        _accessToken = null;
      }
    } catch (e) {
      print('FatSecret Token Fetch Error: $e');
      _accessToken = null;
    }
  }

  Future<List<FoodItem>> searchFood(String query) async {
    if (query.trim().isEmpty) return [];

    final matchingMock = _mockFoods
        .where((food) => food.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Jika API Key kosong, gunakan database lokal tiruan (Offline / Mock Mode)
    if (_clientId.isEmpty || _clientSecret.isEmpty) {
      print('FatSecret: API credentials empty, falling back to Mock.');
      await Future.delayed(const Duration(milliseconds: 200));
      return matchingMock;
    }

    try {
      await _fetchToken();
      if (_accessToken == null) {
        print('FatSecret: Failed to acquire access token. Falling back to Mock.');
        return matchingMock;
      }

      print('FatSecret: Searching for "$query"...');
      final response = await http.get(
        Uri.parse('https://platform.fatsecret.com/rest/server.api').replace(
          queryParameters: {
            'method': 'foods.search',
            'search_expression': query,
            'format': 'json',
            'region': 'ID',
            'language': 'id',
          },
        ),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      print('FatSecret Search HTTP Code: ${response.statusCode}');
      List<FoodItem> apiResults = [];
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('FatSecret Search Response: $data');
        
        if (data is Map && data['error'] != null) {
          print('FatSecret Search API returned error: ${data['error']}. Falling back to mock data.');
          return matchingMock;
        }
        
        final foodsData = data['foods']?['food'];
        if (foodsData != null) {
          List<dynamic> foodList = [];
          if (foodsData is List) {
            foodList = foodsData;
          } else if (foodsData is Map) {
            foodList = [foodsData];
          }

          apiResults = foodList.map((item) {
            final String name = item['food_name'] ?? '';
            final String desc = item['food_description'] ?? '';

            // Use correct single-backslash raw string patterns for regex
            final double rawCalories = _parseDouble(desc, r'Calories:\s*([\d\.,]+)kcal');
            final double rawProtein  = _parseDouble(desc, r'Protein:\s*([\d\.]+)g');
            final double rawCarbs    = _parseDouble(desc, r'Carbs:\s*([\d\.]+)g');
            final double rawFat      = _parseDouble(desc, r'Fat:\s*([\d\.]+)g');
            final double rawGrams    = _parseServingGrams(desc);
            final String rawServing  = _parseServing(desc);

            final String foodId = item['food_id']?.toString() ?? '';

            // Normalize to per-100g if serving size is unreasonably large (>500g)
            final double scale = rawGrams > 500 ? (100.0 / rawGrams) : 1.0;
            final String serving = rawGrams > 500 ? 'per 100g' : rawServing;

            return FoodItem(
              foodId: foodId.isNotEmpty ? foodId : null,
              name: name,
              calories: (rawCalories * scale).round(),
              protein:  (rawProtein  * scale).round(),
              carbs:    (rawCarbs    * scale).round(),
              fat:      (rawFat      * scale).round(),
              serving:  serving,
            );
          }).toList();
        }
      } else {
        print('FatSecret Search HTTP Failed: ${response.body}');
      }

      // Combine mock results and API results, ensuring no duplicates
      final Map<String, FoodItem> combined = {};
      for (var item in matchingMock) {
        combined[item.name.toLowerCase()] = item;
      }
      for (var item in apiResults) {
        if (!combined.containsKey(item.name.toLowerCase())) {
          combined[item.name.toLowerCase()] = item;
        }
      }
      return combined.values.toList();

    } catch (e) {
      print('FatSecret Search Exception: $e');
    }

    return matchingMock;
  }

  Future<List<FoodItem>> getFoodServings(String foodId, String defaultName) async {
    try {
      await _fetchToken();
      if (_accessToken == null) return [];

      final response = await http.get(
        Uri.parse('https://platform.fatsecret.com/rest/server.api').replace(
          queryParameters: {
            'method': 'food.get',
            'food_id': foodId,
            'format': 'json',
            'region': 'ID',
            'language': 'id',
          },
        ),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final servingsData = data['food']?['servings']?['serving'];
        
        if (servingsData == null) return [];

        List<dynamic> servingList = [];
        if (servingsData is List) {
          servingList = servingsData;
        } else if (servingsData is Map) {
          servingList = [servingsData];
        }

        return servingList.map((item) {
          final String servingDesc = item['serving_description'] ?? '1 Porsi';
          final double calories = double.tryParse(item['calories']?.toString() ?? '0') ?? 0;
          final double protein = double.tryParse(item['protein']?.toString() ?? '0') ?? 0;
          final double carbs = double.tryParse(item['carbohydrate']?.toString() ?? '0') ?? 0;
          final double fat = double.tryParse(item['fat']?.toString() ?? '0') ?? 0;

          return FoodItem(
            foodId: foodId,
            name: defaultName,
            calories: calories.round(),
            protein: protein.round(),
            carbs: carbs.round(),
            fat: fat.round(),
            serving: servingDesc,
          );
        }).toList();
      }
    } catch (e) {
      print('FatSecret Get Food Exception: $e');
    }
    return [];
  }

  /// Parse a numeric value (double) from [desc] with a single capture group.
  double _parseDouble(String desc, String pattern) {
    final match = RegExp(pattern, caseSensitive: false).firstMatch(desc);
    if (match != null) {
      // Remove thousands commas: "4,500" → "4500"
      final cleaned = match.group(1)!.replaceAll(',', '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  /// Extracts gram amount from the serving description.
  /// "Per 1 cup (240g)" → 240.0 | "Per 4,500g" → 4500.0 | "Per 100g" → 100.0
  double _parseServingGrams(String desc) {
    // Try parenthesised format first: (240g)
    final bracketMatch = RegExp(r'\(([\d,\.]+)g\)', caseSensitive: false).firstMatch(desc);
    if (bracketMatch != null) {
      return double.tryParse(bracketMatch.group(1)!.replaceAll(',', '')) ?? 100.0;
    }
    // Try "Per Xg" format
    final perMatch = RegExp(r'Per\s+([\d,\.]+)\s*g', caseSensitive: false).firstMatch(desc);
    if (perMatch != null) {
      return double.tryParse(perMatch.group(1)!.replaceAll(',', '')) ?? 100.0;
    }
    return 100.0; // Default: assume 100g
  }

  String _parseServing(String desc) {
    final parts = desc.split(' - ');
    if (parts.isNotEmpty && parts[0].trim().isNotEmpty) return parts[0].trim();
    return '1 Porsi';
  }
}

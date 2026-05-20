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

    // Jika API Key kosong, gunakan database lokal tiruan (Offline / Mock Mode)
    if (_clientId.isEmpty || _clientSecret.isEmpty) {
      print('FatSecret: API credentials empty, falling back to Mock.');
      await Future.delayed(const Duration(milliseconds: 200));
      return _mockFoods
          .where((food) => food.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    try {
      await _fetchToken();
      if (_accessToken == null) {
        print('FatSecret: Failed to acquire access token. Falling back to Mock.');
        return _mockFoods
            .where((food) => food.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }

      print('FatSecret: Searching for "$query"...');
      final response = await http.get(
        Uri.parse('https://platform.fatsecret.com/rest/server.api').replace(
          queryParameters: {
            'method': 'foods.search',
            'search_expression': query,
            'format': 'json',
          },
        ),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      print('FatSecret Search HTTP Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('FatSecret Search Response: $data');
        final foodsData = data['foods']?['food'];
        if (foodsData == null) {
          print('FatSecret: No foods found under "food" key.');
          return [];
        }

        List<dynamic> foodList = [];
        if (foodsData is List) {
          foodList = foodsData;
        } else if (foodsData is Map) {
          foodList = [foodsData];
        }

        return foodList.map((item) {
          final String name = item['food_name'] ?? '';
          final String desc = item['food_description'] ?? '';

          final int calories = _parseValue(desc, r'Calories:\s*(\d+)kcal');
          final int protein = _parseValue(desc, r'Protein:\s*([\d\.]+)g');
          final int carbs = _parseValue(desc, r'Carbs:\s*([\d\.]+)g');
          final int fat = _parseValue(desc, r'Fat:\s*([\d\.]+)g');
          final String serving = _parseServing(desc);

          return FoodItem(
            name: name,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            serving: serving,
          );
        }).toList();
      } else {
        print('FatSecret Search HTTP Failed: ${response.body}');
      }
    } catch (e) {
      print('FatSecret Search Exception: $e');
    }

    // Jika terjadi kegagalan sistem, kembalikan data mock pencarian
    return _mockFoods
        .where((food) => food.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  int _parseValue(String desc, String pattern) {
    final match = RegExp(pattern, caseSensitive: false).firstMatch(desc);
    if (match != null) {
      final double? parsedVal = double.tryParse(match.group(1)!);
      if (parsedVal != null) return parsedVal.round();
    }
    return 0;
  }

  String _parseServing(String desc) {
    final parts = desc.split(' - ');
    if (parts.isNotEmpty) return parts[0];
    return '1 Porsi';
  }
}

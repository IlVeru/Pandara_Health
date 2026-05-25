// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const String clientId = '71d6115b3d0f4072a21cb75a07b08cfe'; 
  const String clientSecret = '5855d1e9823b4622bdc05758c6a5832a';
  
  print('Testing FatSecret credentials with scope basic...');
  try {
    final String credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));
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
    print('Token Status: ${response.statusCode}');
    print('Token Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['access_token'];
      print('Token acquired! Testing search for "ayam"...');
      
      final searchRes = await http.get(
        Uri.parse('https://platform.fatsecret.com/rest/server.api').replace(
          queryParameters: {
            'method': 'foods.search',
            'search_expression': 'ayam',
            'format': 'json',
          },
        ),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print('Search Status: ${searchRes.statusCode}');
      print('Search Body: ${searchRes.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

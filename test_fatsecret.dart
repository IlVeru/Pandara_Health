// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final clientId = '71d6115b3d0f4072a21cb75a07b08cfe';
  final clientSecret = '5855d1e9823b4622bdc05758c6a5832a';

  final tokenResponse = await http.post(
    Uri.parse('https://oauth.fatsecret.com/connect/token'),
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
    },
    body: {'grant_type': 'client_credentials', 'scope': 'basic'},
  );
  
  final token = json.decode(tokenResponse.body)['access_token'];
  
  final response = await http.get(
    Uri.parse('https://platform.fatsecret.com/rest/server.api?method=foods.search&search_expression=nasi%20lemak&format=json'),
    headers: { 'Authorization': 'Bearer $token' },
  );
  
  final foods = json.decode(response.body)['foods']['food'];
  final foodId = foods[0]['food_id'];
  print('First food ID: $foodId');
  
  final detailResponse = await http.get(
    Uri.parse('https://platform.fatsecret.com/rest/server.api?method=food.get&food_id=$foodId&format=json'),
    headers: { 'Authorization': 'Bearer $token' },
  );
  print(detailResponse.body);
}

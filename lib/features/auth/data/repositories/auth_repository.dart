import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/data/models/hive_models.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthRepository {
  final Box<UserModel> _userBox = Hive.box<UserModel>('user_box');
  final Box _settingsBox = Hive.box('settings_box');

  static const String _currentUserKey = 'current_user_email';

  Future<bool> register(String name, String email, String password) async {
    // Check if user already exists
    if (_userBox.containsKey(email)) {
      return false;
    }

    final user = UserModel(
      name: name,
      email: email,
      password: password,
    );

    await _userBox.put(email, user);
    await _userBox.flush(); // Memaksa penulisan ke disk
    
    // Auto-login setelah registrasi
    await _settingsBox.put(_currentUserKey, email);
    await _settingsBox.flush();
    
    return true;
  }

  Future<UserModel?> login(String email, String password) async {
    final user = _userBox.get(email);
    if (user != null && user.password == password) {
      await _settingsBox.put(_currentUserKey, email);
      await _settingsBox.flush();
      return user;
    }
    return null;
  }

  Future<void> logout() async {
    await _settingsBox.delete(_currentUserKey);
  }

  UserModel? getCurrentUser() {
    final email = _settingsBox.get(_currentUserKey);
    if (email != null) {
      return _userBox.get(email);
    }
    return null;
  }

  bool isLoggedIn() {
    return _settingsBox.containsKey(_currentUserKey);
  }
}

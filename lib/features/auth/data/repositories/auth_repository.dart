import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/data/models/hive_models.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final currentUserProvider = StateProvider<UserModel?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.getCurrentUser();
});

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
      final user = _userBox.get(email);
      if (user != null) {
        return UserModel(
          name: user.name,
          email: user.email,
          password: user.password,
          profilePic: user.profilePic,
        );
      }
    }
    return null;
  }

  Future<void> updateProfile({required String name, String? profilePic}) async {
    final email = _settingsBox.get(_currentUserKey);
    if (email != null) {
      final user = _userBox.get(email);
      if (user != null) {
        user.name = name;
        if (profilePic != null) {
          user.profilePic = profilePic;
        }
        await _userBox.put(email, user);
        await _userBox.flush();
      }
    }
  }

  Future<bool> updateEmail(String newEmail) async {
    final currentEmail = _settingsBox.get(_currentUserKey);
    if (currentEmail != null && currentEmail != newEmail) {
      if (_userBox.containsKey(newEmail)) {
        return false;
      }
      final user = _userBox.get(currentEmail);
      if (user != null) {
        final newUser = UserModel(
          name: user.name,
          email: newEmail,
          password: user.password,
          profilePic: user.profilePic,
        );
        await _userBox.put(newEmail, newUser);
        await _userBox.delete(currentEmail);
        await _settingsBox.put(_currentUserKey, newEmail);
        await _userBox.flush();
        await _settingsBox.flush();
        return true;
      }
    }
    return false;
  }

  Future<void> updatePassword(String newPassword) async {
    final email = _settingsBox.get(_currentUserKey);
    if (email != null) {
      final user = _userBox.get(email);
      if (user != null) {
        user.password = newPassword;
        await _userBox.put(email, user);
        await _userBox.flush();
      }
    }
  }

  Future<void> deleteAccount() async {
    final email = _settingsBox.get(_currentUserKey);
    if (email != null) {
      await _userBox.delete(email);
      await _settingsBox.delete(_currentUserKey);
      await _userBox.flush();
      await _settingsBox.flush();
    }
  }

  bool isLoggedIn() {
    return _settingsBox.containsKey(_currentUserKey);
  }
}

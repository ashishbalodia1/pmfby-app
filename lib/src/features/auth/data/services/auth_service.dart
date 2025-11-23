import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user_model.dart';

class AuthService {
  static const String _userKey = 'krashi_bandhu_user';
  static const String _usersListKey = 'krashi_bandhu_users';
  static const String _isLoggedInKey = 'krashi_bandhu_is_logged_in';

  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Register a new user
  Future<bool> register(User user) async {
    try {
      // Get existing users list
      final usersJson = _prefs.getStringList(_usersListKey) ?? [];
      
      // Check if user already exists
      for (var userJson in usersJson) {
        final existingUser = User.fromJson(jsonDecode(userJson));
        if (existingUser.email == user.email) {
          return false; // User already exists
        }
      }

      // Add new user to list
      usersJson.add(jsonEncode(user.toJson()));
      await _prefs.setStringList(_usersListKey, usersJson);

      // Auto-login after registration
      await _loginUser(user);
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    try {
      final usersJson = _prefs.getStringList(_usersListKey) ?? [];

      for (var userJson in usersJson) {
        final user = User.fromJson(jsonDecode(userJson));
        if (user.email == email && user.password == password) {
          await _loginUser(user);
          return true;
        }
      }
      return false; // User not found or password incorrect
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Private method to set user as logged in
  Future<void> _loginUser(User user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
    await _prefs.setBool(_isLoggedInKey, true);
  }

  // Get current logged-in user
  User? getCurrentUser() {
    try {
      final userJson = _prefs.getString(_userKey);
      if (userJson == null) return null;
      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Logout
  Future<void> logout() async {
    await _prefs.remove(_userKey);
    await _prefs.setBool(_isLoggedInKey, false);
  }

  // Get all users (for debugging)
  List<User> getAllUsers() {
    try {
      final usersJson = _prefs.getStringList(_usersListKey) ?? [];
      return usersJson
          .map((userJson) => User.fromJson(jsonDecode(userJson)))
          .toList();
    } catch (e) {
      print('Get all users error: $e');
      return [];
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(User updatedUser) async {
    try {
      // Update in users list
      final usersJson = _prefs.getStringList(_usersListKey) ?? [];
      for (int i = 0; i < usersJson.length; i++) {
        final user = User.fromJson(jsonDecode(usersJson[i]));
        if (user.userId == updatedUser.userId) {
          usersJson[i] = jsonEncode(updatedUser.toJson());
          break;
        }
      }
      await _prefs.setStringList(_usersListKey, usersJson);

      // Update current user if it's the same
      final currentUser = getCurrentUser();
      if (currentUser?.userId == updatedUser.userId) {
        await _prefs.setString(_userKey, jsonEncode(updatedUser.toJson()));
      }

      return true;
    } catch (e) {
      print('Update user error: $e');
      return false;
    }
  }

  // Clear all data (for debugging/testing)
  Future<void> clearAll() async {
    await _prefs.remove(_userKey);
    await _prefs.remove(_usersListKey);
    await _prefs.remove(_isLoggedInKey);
  }
}

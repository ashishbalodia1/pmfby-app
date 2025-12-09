import 'dart:convert';
import 'dart:developer' as developer;
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/auth/domain/models/user_model.dart';

/// Admin Authentication Service
/// Handles email/password authentication for admin users
class AdminAuthService {
  static final AdminAuthService instance = AdminAuthService._internal();
  factory AdminAuthService() => instance;
  AdminAuthService._internal();

  // In-memory storage for demo (replace with MongoDB in production)
  final Map<String, _AdminUser> _adminUsers = {};
  
  // Storage keys
  static const String _storageKeyPrefix = 'admin_';
  static const String _currentAdminKey = 'current_admin';

  /// Initialize service and load existing admins
  Future<void> initialize() async {
    await _loadAdmins();
    
    // Create default admin if none exists
    if (_adminUsers.isEmpty) {
      await _createDefaultAdmin();
    }
  }

  /// Load admins from SharedPreferences
  Future<void> _loadAdmins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_storageKeyPrefix) && key != _currentAdminKey) {
          final jsonStr = prefs.getString(key);
          if (jsonStr != null) {
            final data = jsonDecode(jsonStr);
            _adminUsers[data['email']] = _AdminUser.fromJson(data);
          }
        }
      }
      
      developer.log('✅ Loaded ${_adminUsers.length} admin users');
    } catch (e) {
      developer.log('❌ Error loading admins: $e');
    }
  }

  /// Create default admin account
  Future<void> _createDefaultAdmin() async {
    const defaultEmail = 'admin@pmfby.gov.in';
    const defaultPassword = 'admin123';
    
    await registerAdmin(
      email: defaultEmail,
      password: defaultPassword,
      name: 'System Administrator',
      phone: '9876543210',
      designation: 'Administrator',
      department: 'PMFBY',
    );
    
    developer.log('✅ Created default admin: $defaultEmail / $defaultPassword');
  }

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Register a new admin user
  Future<bool> registerAdmin({
    required String email,
    required String password,
    required String name,
    required String phone,
    String? designation,
    String? department,
    String? assignedDistrict,
  }) async {
    try {
      // Validate email
      if (!email.contains('@')) {
        developer.log('❌ Invalid email format');
        return false;
      }

      // Check if email already exists
      if (_adminUsers.containsKey(email)) {
        developer.log('❌ Email already registered');
        return false;
      }

      // Validate password strength
      if (password.length < 6) {
        developer.log('❌ Password too short (minimum 6 characters)');
        return false;
      }

      // Create admin user
      final hashedPassword = _hashPassword(password);
      final adminUser = _AdminUser(
        userId: 'admin_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        passwordHash: hashedPassword,
        name: name,
        phone: phone,
        designation: designation,
        department: department,
        assignedDistrict: assignedDistrict,
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Store in memory
      _adminUsers[email] = adminUser;

      // Persist to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_storageKeyPrefix$email',
        jsonEncode(adminUser.toJson()),
      );

      developer.log('✅ Admin registered successfully: $email');
      return true;
    } catch (e) {
      developer.log('❌ Error registering admin: $e');
      return false;
    }
  }

  /// Login admin with email and password
  Future<User?> loginAdmin(String email, String password) async {
    try {
      // Check if admin exists
      if (!_adminUsers.containsKey(email)) {
        developer.log('❌ Admin not found: $email');
        return null;
      }

      final adminUser = _adminUsers[email]!;

      // Check if account is active
      if (!adminUser.isActive) {
        developer.log('❌ Admin account deactivated: $email');
        return null;
      }

      // Verify password
      final hashedPassword = _hashPassword(password);
      if (adminUser.passwordHash != hashedPassword) {
        developer.log('❌ Invalid password for: $email');
        return null;
      }

      // Update last login
      adminUser.lastLogin = DateTime.now();
      await _updateAdmin(adminUser);

      // Save current admin
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentAdminKey, email);

      developer.log('✅ Admin logged in successfully: $email');

      // Convert to User model
      return User(
        userId: adminUser.userId,
        email: email,
        name: adminUser.name,
        phone: adminUser.phone,
        role: 'official',
        officialId: adminUser.userId,
        designation: adminUser.designation,
        department: adminUser.department,
        assignedDistrict: adminUser.assignedDistrict,
      );
    } catch (e) {
      developer.log('❌ Error during admin login: $e');
      return null;
    }
  }

  /// Update admin data
  Future<void> _updateAdmin(_AdminUser adminUser) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_storageKeyPrefix${adminUser.email}',
        jsonEncode(adminUser.toJson()),
      );
    } catch (e) {
      developer.log('❌ Error updating admin: $e');
    }
  }

  /// Get current logged-in admin
  Future<User?> getCurrentAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_currentAdminKey);
      
      if (email == null || !_adminUsers.containsKey(email)) {
        return null;
      }

      final adminUser = _adminUsers[email]!;
      
      return User(
        userId: adminUser.userId,
        email: email,
        name: adminUser.name,
        phone: adminUser.phone,
        role: 'official',
        officialId: adminUser.userId,
        designation: adminUser.designation,
        department: adminUser.department,
        assignedDistrict: adminUser.assignedDistrict,
      );
    } catch (e) {
      developer.log('❌ Error getting current admin: $e');
      return null;
    }
  }

  /// Logout current admin
  Future<void> logoutAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentAdminKey);
      developer.log('✅ Admin logged out');
    } catch (e) {
      developer.log('❌ Error during logout: $e');
    }
  }

  /// Change admin password
  Future<bool> changePassword(String email, String oldPassword, String newPassword) async {
    try {
      if (!_adminUsers.containsKey(email)) {
        return false;
      }

      final adminUser = _adminUsers[email]!;

      // Verify old password
      final oldHash = _hashPassword(oldPassword);
      if (adminUser.passwordHash != oldHash) {
        developer.log('❌ Old password incorrect');
        return false;
      }

      // Update password
      adminUser.passwordHash = _hashPassword(newPassword);
      await _updateAdmin(adminUser);

      developer.log('✅ Password changed for: $email');
      return true;
    } catch (e) {
      developer.log('❌ Error changing password: $e');
      return false;
    }
  }

  /// Get all admin users (for admin management)
  List<Map<String, dynamic>> getAllAdmins() {
    return _adminUsers.values.map((admin) => {
      'email': admin.email,
      'name': admin.name,
      'phone': admin.phone,
      'designation': admin.designation,
      'department': admin.department,
      'assignedDistrict': admin.assignedDistrict,
      'isActive': admin.isActive,
      'createdAt': admin.createdAt.toIso8601String(),
      'lastLogin': admin.lastLogin?.toIso8601String(),
    }).toList();
  }

  /// Deactivate admin account
  Future<bool> deactivateAdmin(String email) async {
    try {
      if (!_adminUsers.containsKey(email)) {
        return false;
      }

      _adminUsers[email]!.isActive = false;
      await _updateAdmin(_adminUsers[email]!);

      developer.log('✅ Admin deactivated: $email');
      return true;
    } catch (e) {
      developer.log('❌ Error deactivating admin: $e');
      return false;
    }
  }

  /// Reactivate admin account
  Future<bool> reactivateAdmin(String email) async {
    try {
      if (!_adminUsers.containsKey(email)) {
        return false;
      }

      _adminUsers[email]!.isActive = true;
      await _updateAdmin(_adminUsers[email]!);

      developer.log('✅ Admin reactivated: $email');
      return true;
    } catch (e) {
      developer.log('❌ Error reactivating admin: $e');
      return false;
    }
  }
}

/// Internal class for admin user data
class _AdminUser {
  final String userId;
  final String email;
  String passwordHash;
  final String name;
  final String phone;
  final String? designation;
  final String? department;
  final String? assignedDistrict;
  final DateTime createdAt;
  DateTime? lastLogin;
  bool isActive;

  _AdminUser({
    required this.userId,
    required this.email,
    required this.passwordHash,
    required this.name,
    required this.phone,
    this.designation,
    this.department,
    this.assignedDistrict,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'passwordHash': passwordHash,
    'name': name,
    'phone': phone,
    'designation': designation,
    'department': department,
    'assignedDistrict': assignedDistrict,
    'createdAt': createdAt.toIso8601String(),
    'lastLogin': lastLogin?.toIso8601String(),
    'isActive': isActive,
  };

  factory _AdminUser.fromJson(Map<String, dynamic> json) => _AdminUser(
    userId: json['userId'],
    email: json['email'],
    passwordHash: json['passwordHash'],
    name: json['name'],
    phone: json['phone'],
    designation: json['designation'],
    department: json['department'],
    assignedDistrict: json['assignedDistrict'],
    createdAt: DateTime.parse(json['createdAt']),
    lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    isActive: json['isActive'] ?? true,
  );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/services/auth_service.dart';
import 'providers/auth_provider.dart';
import '../../../services/firebase_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
// ---------------------------
// CONTROLLERS
// ---------------------------
final _emailController = TextEditingController();
final _passwordController = TextEditingController();

final _phoneController = TextEditingController();
final _otpController = TextEditingController();

// ---------------------------
// STATE
// ---------------------------
bool _isLoading = false;
bool _showPassword = false;
bool _otpSent = false;

@override
void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
  _phoneController.dispose();
  _otpController.dispose();
  super.dispose();
}

// ---------------------------
// COMMON SNACKBAR HELPERS
// ---------------------------
void _showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.red),
  );
}

void _showSuccess(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.green),
  );
}

// =====================================================
// EMAIL + PASSWORD LOGIN (LOCAL AUTH SERVICE)
// =====================================================
Future<void> _handleEmailLogin(bool isFarmer) async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  if (email.isEmpty) {
    _showError('Please enter your email');
    return;
  }
  if (password.isEmpty) {
    _showError('Please enter your password');
    return;
  }

  setState(() => _isLoading = true);

  try {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(email, password);

    if (success) {
      final user = authProvider.currentUser;
      if (user != null &&
          ((isFarmer && user.role == 'farmer') ||
              (!isFarmer && user.role == 'official'))) {
        if (mounted) context.go('/dashboard');
      } else {
        await authProvider.logout();
        _showError('Invalid role. Please login with correct account type.');
      }
    } else {
      _showError('Invalid email or password');
    }
  } catch (e) {
    _showError('Login failed: $e');
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

// =====================================================
// PHONE + OTP LOGIN (FIREBASE AUTH)
// =====================================================
Future<void> _sendOTP() async {
  if (_phoneController.text.length != 10) {
    _showError('कृपया सही मोबाइल नंबर दर्ज करें (Please enter valid mobile number)');
    return;
  }

  setState(() => _isLoading = true);

  final phoneNumber = '+91${_phoneController.text}';
  final authService = context.read<FirebaseAuthService>();

  await authService.sendOTP(
    phoneNumber,
    (msg) {
      setState(() {
        _otpSent = true;
        _isLoading = false;
      });
      _showSuccess('OTP भेजा गया (OTP sent)');
    },
    (error) {
      setState(() => _isLoading = false);
      _showError(error);
    },
  );
}

Future<void> _verifyOTP() async {
  if (_otpController.text.length != 6) {
    _showError('कृपया 6 अंकों का OTP दर्ज करें (Please enter 6-digit OTP)');
    return;
  }

  setState(() => _isLoading = true);

  try {
    final authService = context.read<FirebaseAuthService>();
    await authService.verifyOTP(_otpController.text);

    if (mounted) context.go('/dashboard');
  } catch (e) {
    setState(() => _isLoading = false);
    _showError('गलत OTP (Invalid OTP)');
  }
}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
body: Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.green.shade700,
        Colors.green.shade400,
        Colors.lightGreen.shade200,
      ],
    ),
  ),
  child: SafeArea(
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // LOGO
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.agriculture,
                size: 80,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 30),

            // APP NAME
            Text(
              'Krisi Bandhu',
              style: GoogleFonts.poppins(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Making Crop Insurance Faster and Fairer',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 50),

            // TABS: OTP / EMAIL LOGIN
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: const [
                      Tab(text: 'Phone Login'),
                      Tab(text: 'Email Login'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 330,
                      child: TabBarView(
                        children: [
                          // ---------------------------
                          // PHONE LOGIN (OTP)
                          // ---------------------------
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _otpSent ? 'Enter OTP' : 'Login',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                              const SizedBox(height: 24),

                              if (!_otpSent) ...[
                                TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  decoration: InputDecoration(
                                    labelText: 'Mobile Number',
                                    prefixIcon: const Icon(Icons.phone),
                                    prefixText: '+91 ',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    counterText: '',
                                  ),
                                ),
                                const SizedBox(height: 20),

                                ElevatedButton(
                                  onPressed: _isLoading ? null : _sendOTP,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        )
                                      : Text(
                                          'Send OTP',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ] else ...[
                                TextField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    labelText: 'OTP',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    counterText: '',
                                  ),
                                ),
                                const SizedBox(height: 20),

                                ElevatedButton(
                                  onPressed: _isLoading ? null : _verifyOTP,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        )
                                      : Text(
                                          'Verify',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),

                                TextButton(
                                  onPressed: _isLoading ? null : _sendOTP,
                                  child: Text(
                                    'Resend OTP',
                                    style: TextStyle(color: Colors.green.shade700),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          // ---------------------------
                          // EMAIL LOGIN
                          // ---------------------------
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email Address',
                                  prefixIcon: const Icon(Icons.email),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              TextField(
                                controller: _passwordController,
                                obscureText: !_showPassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () =>
                                        setState(() => _showPassword = !_showPassword),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              ElevatedButton(
                                onPressed: _isLoading ? null : () => _handleEmailLogin(true),
                                child: const Text('Login as Farmer'),
                              ),
                              const SizedBox(height: 10),

                              OutlinedButton(
                                onPressed: _isLoading ? null : () => _handleEmailLogin(false),
                                child: const Text('Login as Official'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Text(
              'PMFBY - Pradhan Mantri Fasal Bima Yojana',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }
}

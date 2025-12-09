import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import '../domain/models/user_model.dart';
import '../../../services/sms_service.dart';
import '../../../services/admin_auth_service.dart';

class NewLoginScreen extends StatefulWidget {
  const NewLoginScreen({super.key});

  @override
  State<NewLoginScreen> createState() => _NewLoginScreenState();
}

class _NewLoginScreenState extends State<NewLoginScreen> with SingleTickerProviderStateMixin {
  // Controllers
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _designationController = TextEditingController();
  final _departmentController = TextEditingController();

  // State
  bool _isLoading = false;
  bool _otpSent = false;
  bool _isAdminMode = false;
  bool _isSignupMode = false;
  bool _obscurePassword = true;
  bool _showOptionalFields = false;

  // Tab Controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isAdminMode = _tabController.index == 1;
        _resetForm();
      });
    });
    
    // Initialize admin service
    AdminAuthService.instance.initialize();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _designationController.dispose();
    _departmentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _otpSent = false;
    _isSignupMode = false;
    _showOptionalFields = false;
    _phoneController.clear();
    _otpController.clear();
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _designationController.clear();
    _departmentController.clear();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =====================================================
  // FARMER LOGIN - PHONE OTP
  // =====================================================
  Future<void> _sendOTPToFarmer() async {
    final phone = _phoneController.text.trim();
    
    if (phone.length != 10) {
      _showError('कृपया 10 अंकों का मोबाइल नंबर दर्ज करें');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final smsService = SmsService.instance;
      final success = await smsService.sendOTP(phone);

      if (success) {
        setState(() {
          _otpSent = true;
          _isLoading = false;
        });
        _showSuccess('OTP भेजा गया है। कृपया अपना मोबाइल चेक करें।');
      } else {
        setState(() => _isLoading = false);
        _showError('OTP भेजने में विफल। कृपया पुनः प्रयास करें।');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('त्रुटि: $e');
    }
  }

  Future<void> _verifyOTPAndLogin() async {
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      _showError('कृपया 6 अंकों का OTP दर्ज करें');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final smsService = SmsService.instance;
      final verified = await smsService.verifyOTP(phone, otp);

      if (verified) {
        // Create farmer user
        final authProvider = context.read<AuthProvider>();
        final farmerUser = User(
          userId: 'farmer_$phone',
          name: _nameController.text.trim().isEmpty 
              ? 'किसान $phone' 
              : _nameController.text.trim(),
          phone: '+91$phone',
          email: '$phone@pmfby.farmer',
          role: 'farmer',
        );

        authProvider.setDemoUser(farmerUser);

        if (mounted) {
          _showSuccess('लॉगिन सफल!');
          context.go('/dashboard');
        }
      } else {
        setState(() => _isLoading = false);
        _showError('गलत OTP। कृपया पुनः प्रयास करें।');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('त्रुटि: $e');
    }
  }

  Future<void> _resendOTP() async {
    final phone = _phoneController.text.trim();
    setState(() => _isLoading = true);

    try {
      final smsService = SmsService.instance;
      final success = await smsService.resendOTP(phone);

      setState(() => _isLoading = false);

      if (success) {
        _showSuccess('OTP दोबारा भेजा गया है।');
      } else {
        _showError('OTP भेजने में विफल।');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('त्रुटि: $e');
    }
  }

  // =====================================================
  // ADMIN LOGIN/SIGNUP - EMAIL & PASSWORD
  // =====================================================
  Future<void> _adminLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('कृपया ईमेल और पासवर्ड दर्ज करें');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final adminService = AdminAuthService.instance;
      final user = await adminService.loginAdmin(email, password);

      if (user != null) {
        final authProvider = context.read<AuthProvider>();
        authProvider.setDemoUser(user);

        if (mounted) {
          _showSuccess('Admin login successful!');
          context.go('/officer-dashboard');
        }
      } else {
        setState(() => _isLoading = false);
        _showError('Invalid email or password');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error: $e');
    }
  }

  Future<void> _adminSignup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty || phone.isEmpty) {
      _showError('कृपया सभी आवश्यक फील्ड भरें');
      return;
    }

    if (phone.length != 10) {
      _showError('कृपया 10 अंकों का मोबाइल नंबर दर्ज करें');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final adminService = AdminAuthService.instance;
      final success = await adminService.registerAdmin(
        email: email,
        password: password,
        name: name,
        phone: phone,
        designation: _designationController.text.trim().isEmpty 
            ? null 
            : _designationController.text.trim(),
        department: _departmentController.text.trim().isEmpty 
            ? null 
            : _departmentController.text.trim(),
      );

      if (success) {
        setState(() {
          _isLoading = false;
          _isSignupMode = false;
        });
        _showSuccess('Admin registered successfully! Please login.');
        _emailController.clear();
        _passwordController.clear();
        _nameController.clear();
        _phoneController.clear();
        _designationController.clear();
        _departmentController.clear();
      } else {
        setState(() => _isLoading = false);
        _showError('Registration failed. Email may already exist.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade700,
              Colors.green.shade500,
              Colors.lightGreen.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.agriculture,
                        size: 32,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bandhu',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'किसान लॉगिन | Farmer Login',
                            style: GoogleFonts.notoSansDevanagari(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.green.shade700,
                  unselectedLabelColor: Colors.white,
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: '👨‍🌾 Farmer'),
                    Tab(text: '👨‍💼 Admin'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Main Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFarmerLogin(),
                    _buildAdminLogin(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFarmerLogin() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Login करें',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'मोबाइल नंबर से लॉगिन करें',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // Phone Number Field
            Text(
              'मोबाइल नंबर | Mobile Number',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              enabled: !_otpSent,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.phone, color: Colors.green.shade700),
                hintText: '9589191560',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                ),
                filled: true,
                fillColor: _otpSent ? Colors.grey.shade100 : Colors.white,
              ),
            ),

            if (_showOptionalFields) ...[
              const SizedBox(height: 16),
              Text(
                'नाम (वैकल्पिक)',
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.green.shade700),
                  hintText: 'अपना नाम दर्ज करें',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],

            if (_otpSent) ...[
              const SizedBox(height: 16),
              Text(
                'OTP',
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Colors.green.shade700),
                  hintText: '6-digit OTP',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'OTP received?',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _resendOTP,
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (!_otpSent && !_showOptionalFields)
              TextButton(
                onPressed: () => setState(() => _showOptionalFields = true),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'अधिक जानकारी | Add Details (Optional)',
                      style: TextStyle(color: Colors.green.shade700),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : (_otpSent ? _verifyOTPAndLogin : _sendOTPToFarmer),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _otpSent ? 'Verify OTP' : 'OTP भेजें | Send OTP',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminLogin() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isSignupMode ? 'Admin Signup' : 'Admin Login',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isSignupMode ? 'Create admin account' : 'Email & Password',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // Email Field
            Text(
              'Email',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email, color: Colors.green.shade700),
                hintText: 'admin@pmfby.gov.in',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Password Field
            Text(
              'Password',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock, color: Colors.green.shade700),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                hintText: '••••••••',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                ),
              ),
            ),

            if (_isSignupMode) ...[
              const SizedBox(height: 16),
              Text(
                'Full Name *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.green.shade700),
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Phone Number *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone, color: Colors.green.shade700),
                  hintText: '9876543210',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Designation (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _designationController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.work, color: Colors.green.shade700),
                  hintText: 'e.g., District Officer',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Department (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _departmentController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.business, color: Colors.green.shade700),
                  hintText: 'e.g., Agriculture',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : (_isSignupMode ? _adminSignup : _adminLogin),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isSignupMode ? 'Create Account' : 'Login',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Toggle between login and signup
            Center(
              child: TextButton(
                onPressed: () => setState(() {
                  _isSignupMode = !_isSignupMode;
                  _emailController.clear();
                  _passwordController.clear();
                  _nameController.clear();
                  _phoneController.clear();
                  _designationController.clear();
                  _departmentController.clear();
                }),
                child: Text(
                  _isSignupMode 
                      ? 'Already have an account? Login' 
                      : 'New admin? Create account',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Default admin credentials info
            if (!_isSignupMode)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Default Admin Credentials',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Email: admin@pmfby.gov.in\nPassword: admin123',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade900,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

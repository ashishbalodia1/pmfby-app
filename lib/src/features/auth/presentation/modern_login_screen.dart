import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import '../domain/models/user_model.dart';
import '../../../services/twilio_sms_service.dart';
import '../../../services/admin_auth_service.dart';
import '../../../providers/theme_provider.dart';

class ModernLoginScreen extends StatefulWidget {
  const ModernLoginScreen({super.key});

  @override
  State<ModernLoginScreen> createState() => _ModernLoginScreenState();
}

class _ModernLoginScreenState extends State<ModernLoginScreen> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isLoading = false;
  bool _otpSent = false;
  bool _isAdminMode = false;
  bool _obscurePassword = true;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _isAdminMode = _tabController.index == 1;
          _resetForm();
        });
      }
    });
    AdminAuthService.instance.initialize();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _otpSent = false;
    _phoneController.clear();
    _otpController.clear();
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();
    
    if (phone.length != 10) {
      _showMessage('कृपया 10 अंकों का मोबाइल नंबर दर्ज करें', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await TwilioSmsService.instance.sendOTP(phone);

      setState(() {
        _isLoading = false;
        if (success) {
          _otpSent = true;
          _showMessage('OTP आपके मोबाइल पर भेजा गया है! 📱');
        } else {
          _showMessage('OTP भेजने में विफल। कृपया पुनः प्रयास करें।', isError: true);
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('त्रुटि: $e', isError: true);
    }
  }

  Future<void> _verifyOTP() async {
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      _showMessage('कृपया 6 अंकों का OTP दर्ज करें', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final verified = TwilioSmsService.instance.verifyOTP(phone, otp);

      if (verified) {
        final authProvider = context.read<AuthProvider>();
        final farmerUser = User(
          userId: 'farmer_$phone',
          name: _nameController.text.trim().isEmpty ? 'किसान $phone' : _nameController.text.trim(),
          phone: '+91$phone',
          email: '$phone@pmfby.farmer',
          role: 'farmer',
        );

        authProvider.setDemoUser(farmerUser);

        if (mounted) {
          _showMessage('लॉगिन सफल!');
          Future.delayed(const Duration(milliseconds: 500), () {
            context.go('/dashboard');
          });
        }
      } else {
        setState(() => _isLoading = false);
        _showMessage('गलत OTP। पुनः प्रयास करें।', isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('त्रुटि: $e', isError: true);
    }
  }

  Future<void> _adminLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('कृपया ईमेल और पासवर्ड दर्ज करें', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await AdminAuthService.instance.loginAdmin(email, password);

      if (user != null) {
        final authProvider = context.read<AuthProvider>();
        authProvider.setDemoUser(user);

        if (mounted) {
          _showMessage('Admin login successful!');
          Future.delayed(const Duration(milliseconds: 500), () {
            context.go('/officer-dashboard');
          });
        }
      } else {
        setState(() => _isLoading = false);
        _showMessage('Invalid email or password', isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Error: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4CAF50),
              Color(0xFF81C784),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Title
                  _buildHeader(),
                  const SizedBox(height: 40),
                  
                  // Main Card
                  Container(
                    constraints: BoxConstraints(maxWidth: size.width > 600 ? 500 : double.infinity),
                    child: Card(
                      elevation: 12,
                      shadowColor: Colors.black45,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTabBar(),
                          SizedBox(
                            height: _otpSent ? 450 : 380,
                            child: TabBarView(
                              controller: _tabController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildFarmerTab(),
                                _buildAdminTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.agriculture_rounded,
            size: 64,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Krishi Bandhu',
          style: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'प्रधानमंत्री फसल बीमा योजना',
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 16,
            color: Colors.white.withOpacity(0.95),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.green.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade700,
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            icon: Icon(Icons.person),
            text: 'Farmer',
          ),
          Tab(
            icon: Icon(Icons.admin_panel_settings),
            text: 'Admin',
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'किसान लॉगिन',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Phone Input
          _buildTextField(
            controller: _phoneController,
            label: 'मोबाइल नंबर',
            hint: '9876543210',
            icon: Icons.phone_android,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            enabled: !_otpSent,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          
          if (!_otpSent) ...[
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'नाम (वैकल्पिक)',
              hint: 'अपना नाम दर्ज करें',
              icon: Icons.person_outline,
            ),
          ],
          
          // OTP Input (shown after OTP sent)
          if (_otpSent) ...[
            const SizedBox(height: 20),
            _buildTextField(
              controller: _otpController,
              label: 'OTP',
              hint: '6-digit code',
              icon: Icons.lock_outline,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'कोड नहीं मिला?',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                TextButton(
                  onPressed: _isLoading ? null : _sendOTP,
                  child: Text(
                    'दोबारा भेजें',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Action Button
          _buildActionButton(
            onPressed: _isLoading ? null : (_otpSent ? _verifyOTP : _sendOTP),
            text: _otpSent ? 'Verify OTP' : 'OTP भेजें',
            icon: _otpSent ? Icons.verified_user : Icons.send,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Admin Login',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'admin@pmfby.gov.in',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          
          const SizedBox(height: 20),
          
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade600,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          
          const SizedBox(height: 32),
          
          _buildActionButton(
            onPressed: _isLoading ? null : _adminLogin,
            text: 'Login',
            icon: Icons.login,
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Default Credentials',
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
                  'admin@pmfby.gov.in / admin123',
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    int? maxLength,
    bool enabled = true,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.green.shade700),
            suffixIcon: suffixIcon,
            counterText: '',
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required String text,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Icon(icon, size: 20),
      label: Text(
        _isLoading ? 'Processing...' : text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        shadowColor: Colors.green.shade700.withOpacity(0.5),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Secured by Government of India',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '© 2025 PMFBY - All Rights Reserved',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

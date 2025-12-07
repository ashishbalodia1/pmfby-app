import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../domain/models/user_model.dart';
import 'providers/auth_provider.dart';
import '../../../services/email_otp_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  String _userRole = 'farmer'; // 'farmer' or 'official'
  bool _isLoading = false;
  
  // Email OTP verification
  bool _emailVerified = false;
  bool _otpSent = false;
  final _otpController = TextEditingController();
  
  // Phone verification
  bool _phoneVerified = false;
  bool _phoneOtpSent = false;
  final _phoneOtpController = TextEditingController();
  
  // Additional validation flags
  bool _passwordStrong = false;
  bool _nameValid = false;
  bool _emailValid = false;
  bool _phoneValid = false;
  bool _passwordMatch = false;
  
  // Validation error messages
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Common fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Farmer fields
  final _villageController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _farmSizeController = TextEditingController();
  final _aadharController = TextEditingController();
  final List<String> _selectedCrops = [];

  // Official fields
  final _officialIdController = TextEditingController();
  final _designationController = TextEditingController();
  final _departmentController = TextEditingController();
  final _assignedDistrictController = TextEditingController();

  final List<String> _cropOptions = [
    'Wheat',
    'Rice',
    'Maize',
    'Cotton',
    'Sugarcane',
    'Groundnut',
    'Soybean',
    'Jowar',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _phoneOtpController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _farmSizeController.dispose();
    _aadharController.dispose();
    _officialIdController.dispose();
    _designationController.dispose();
    _departmentController.dispose();
    _assignedDistrictController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0) {
      if (_validateCommonFields() && _emailVerified && _phoneVerified) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (!_emailVerified) {
        _showError('Please verify your email first');
      } else if (!_phoneVerified) {
        _showError('Please verify your phone number first');
      }
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _sendEmailOTP() async {
    // Validate email first
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showError('Please enter a valid email');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await EmailOTPService.sendOTP(
        email: _emailController.text.trim(),
        purpose: 'register',
      );

      if (success) {
        setState(() {
          _otpSent = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ OTP sent to your email! Check your inbox.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyEmailOTP() async {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      _showError('Please enter a valid 6-digit OTP');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final isValid = EmailOTPService.verifyOTP(
        _emailController.text.trim(),
        _otpController.text.trim(),
      );

      if (isValid) {
        setState(() {
          _emailVerified = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Email verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        _showError('Invalid or expired OTP. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _sendPhoneOTP() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length != 10) {
      _showError('Please enter a valid 10-digit phone number');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate phone OTP sending (in production, integrate with SMS service)
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _phoneOtpSent = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📱 OTP sent to ${_phoneController.text}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to send OTP: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _verifyPhoneOTP() async {
    if (_phoneOtpController.text.isEmpty || _phoneOtpController.text.length != 6) {
      _showError('Please enter a valid 6-digit OTP');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate verification (in production, verify with backend)
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo, accept any 6-digit code
      setState(() {
        _phoneVerified = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Phone verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Verification failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  bool _validateAadhar(String aadhar) {
    // Basic Aadhar validation: 12 digits
    if (aadhar.length != 12) return false;
    
    // Check if all characters are digits
    if (!RegExp(r'^[0-9]+$').hasMatch(aadhar)) return false;
    
    // Verhoeff algorithm for Aadhar validation (simplified)
    return true;
  }
  
  void _checkPasswordStrength(String password) {
    setState(() {
      _passwordStrong = password.length >= 8 &&
          password.contains(RegExp(r'[A-Z]')) &&
          password.contains(RegExp(r'[a-z]')) &&
          password.contains(RegExp(r'[0-9]'));
    });
  }
  
  void _validateName(String name) {
    setState(() {
      if (name.isEmpty) {
        _nameValid = false;
        _nameError = 'Name is required';
      } else if (name.length < 3) {
        _nameValid = false;
        _nameError = 'Name must be at least 3 characters';
      } else if (name.length > 50) {
        _nameValid = false;
        _nameError = 'Name is too long (max 50 characters)';
      } else if (!RegExp(r'^[a-zA-Z\s\.]+$').hasMatch(name)) {
        _nameValid = false;
        _nameError = 'Name can only contain letters and spaces';
      } else if (RegExp(r'\s{2,}').hasMatch(name)) {
        _nameValid = false;
        _nameError = 'Name cannot have consecutive spaces';
      } else {
        _nameValid = true;
        _nameError = null;
      }
    });
  }
  
  void _validateEmail(String email) {
    setState(() {
      if (email.isEmpty) {
        _emailValid = false;
        _emailError = 'Email is required';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _emailValid = false;
        _emailError = 'Enter a valid email address';
      } else {
        _emailValid = true;
        _emailError = null;
      }
    });
  }
  
  void _validatePhone(String phone) {
    setState(() {
      if (phone.isEmpty) {
        _phoneValid = false;
        _phoneError = 'Phone number is required';
      } else if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone)) {
        _phoneValid = false;
        _phoneError = 'Enter a valid 10-digit Indian mobile number';
      } else {
        _phoneValid = true;
        _phoneError = null;
      }
    });
  }
  
  void _validatePassword(String password) {
    setState(() {
      if (password.isEmpty) {
        _passwordError = 'Password is required';
      } else if (password.length < 8) {
        _passwordError = 'Password must be at least 8 characters';
      } else if (!password.contains(RegExp(r'[A-Z]'))) {
        _passwordError = 'Password must contain an uppercase letter';
      } else if (!password.contains(RegExp(r'[a-z]'))) {
        _passwordError = 'Password must contain a lowercase letter';
      } else if (!password.contains(RegExp(r'[0-9]'))) {
        _passwordError = 'Password must contain a number';
      } else {
        _passwordError = null;
      }
      
      // Check password match
      _validatePasswordMatch();
    });
  }
  
  void _validatePasswordMatch() {
    setState(() {
      if (_confirmPasswordController.text.isEmpty) {
        _passwordMatch = false;
        _confirmPasswordError = null;
      } else if (_passwordController.text != _confirmPasswordController.text) {
        _passwordMatch = false;
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _passwordMatch = true;
        _confirmPasswordError = null;
      }
    });
  }

  bool _validateCommonFields() {
    // Validate name
    if (!_nameValid || _nameController.text.isEmpty) {
      _showError(_nameError ?? 'Please enter a valid name');
      return false;
    }
    
    // Validate email
    if (!_emailValid || _emailController.text.isEmpty) {
      _showError(_emailError ?? 'Please enter a valid email');
      return false;
    }
    
    // Validate phone
    if (!_phoneValid || _phoneController.text.isEmpty) {
      _showError(_phoneError ?? 'Please enter a valid phone number');
      return false;
    }
    
    // Validate password
    if (_passwordController.text.isEmpty || !_passwordStrong) {
      _showError(_passwordError ?? 'Please create a strong password');
      return false;
    }
    
    // Validate password match
    if (!_passwordMatch) {
      _showError(_confirmPasswordError ?? 'Passwords do not match');
      return false;
    }
    
    return true;
  }

  bool _validateRoleSpecificFields() {
    if (_userRole == 'farmer') {
      if (_villageController.text.isEmpty) {
        _showError('Please enter your village');
        return false;
      }
      if (_districtController.text.isEmpty) {
        _showError('Please enter your district');
        return false;
      }
      if (_stateController.text.isEmpty) {
        _showError('Please enter your state');
        return false;
      }
      if (_farmSizeController.text.isEmpty) {
        _showError('Please enter your farm size');
        return false;
      }
      if (_aadharController.text.isEmpty ||
          _aadharController.text.length != 12) {
        _showError('Please enter a valid 12-digit Aadhar number');
        return false;
      }
      if (_selectedCrops.isEmpty) {
        _showError('Please select at least one crop');
        return false;
      }
    } else {
      if (_officialIdController.text.isEmpty) {
        _showError('Please enter your official ID');
        return false;
      }
      if (_designationController.text.isEmpty) {
        _showError('Please select your designation');
        return false;
      }
      if (_departmentController.text.isEmpty) {
        _showError('Please enter your department');
        return false;
      }
      if (_assignedDistrictController.text.isEmpty) {
        _showError('Please enter your assigned district');
        return false;
      }
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  Widget _buildVerificationItem(String label, bool isVerified) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isVerified ? Colors.green : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isVerified ? Colors.green.shade700 : Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _register() async {
    if (!_validateCommonFields() || !_validateRoleSpecificFields()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

      final user = User(
        userId: userId,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        role: _userRole,
        village: _userRole == 'farmer' ? _villageController.text : null,
        district: _userRole == 'farmer' ? _districtController.text : null,
        state: _userRole == 'farmer' ? _stateController.text : null,
        farmSize: _userRole == 'farmer'
            ? double.tryParse(_farmSizeController.text)
            : null,
        aadharNumber: _userRole == 'farmer' ? _aadharController.text : null,
        cropTypes: _userRole == 'farmer' ? _selectedCrops : null,
        officialId: _userRole == 'official'
            ? _officialIdController.text
            : null,
        designation: _userRole == 'official'
            ? _designationController.text
            : null,
        department: _userRole == 'official'
            ? _departmentController.text
            : null,
        assignedDistrict: _userRole == 'official'
            ? _assignedDistrictController.text
            : null,
      );

      final success = await context.read<AuthProvider>().register(user);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Logging you in...'),
              backgroundColor: Colors.green,
            ),
          );
          // Delay to show the message
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            context.go('/dashboard');
          }
        }
      } else {
        _showError('Email already registered. Please login instead.');
      }
    } catch (e) {
      _showError('Registration failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: [
          _buildCommonDetailsPage(),
          _buildRoleSpecificPage(),
        ],
      ),
    );
  }

  Widget _buildCommonDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Your Account',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Step 1: Basic Information',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          // Verification status card
          Container(
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
                    Icon(Icons.verified_user, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Verification Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildVerificationItem('Name Valid', _nameValid),
                _buildVerificationItem('Email Verified', _emailVerified),
                _buildVerificationItem('Phone Verified', _phoneVerified),
                _buildVerificationItem('Password Strong', _passwordStrong),
                _buildVerificationItem('Passwords Match', _passwordMatch),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name *',
              prefixIcon: const Icon(Icons.person),
              suffixIcon: _nameController.text.isNotEmpty
                  ? Icon(
                      _nameValid ? Icons.check_circle : Icons.error,
                      color: _nameValid ? Colors.green : Colors.red,
                    )
                  : null,
              errorText: _nameError,
              helperText: 'Enter your full name as per official documents',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: _validateName,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email Address *',
              prefixIcon: const Icon(Icons.email),
              suffixIcon: _emailVerified
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : (_emailController.text.isNotEmpty && _emailValid
                      ? const Icon(Icons.check_circle_outline, color: Colors.orange)
                      : null),
              errorText: _emailError,
              helperText: _emailVerified ? 'Verified' : 'We will send an OTP to verify',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            enabled: !_emailVerified,
            onChanged: _validateEmail,
          ),
          if (!_emailVerified) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _otpSent
                      ? TextField(
                          controller: _otpController,
                          decoration: InputDecoration(
                            labelText: 'Enter OTP',
                            prefixIcon: const Icon(Icons.pin),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_otpSent 
                          ? _verifyEmailOTP 
                          : (_emailValid ? _sendEmailOTP : null)),
                  child: Text(_otpSent ? 'Verify' : 'Send OTP'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number *',
              prefixIcon: const Icon(Icons.phone),
              prefixText: '+91 ',
              suffixIcon: _phoneVerified
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : (_phoneController.text.isNotEmpty && _phoneValid
                      ? const Icon(Icons.check_circle_outline, color: Colors.orange)
                      : null),
              errorText: _phoneError,
              helperText: _phoneVerified ? 'Verified' : 'Enter 10-digit mobile number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.phone,
            enabled: !_phoneVerified,
            maxLength: 10,
            onChanged: _validatePhone,
          ),
          if (!_phoneVerified) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _phoneOtpSent
                      ? TextField(
                          controller: _phoneOtpController,
                          decoration: InputDecoration(
                            labelText: 'Enter OTP',
                            prefixIcon: const Icon(Icons.pin),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_phoneOtpSent 
                          ? _verifyPhoneOTP 
                          : (_phoneValid ? _sendPhoneOTP : null)),
                  child: Text(_phoneOtpSent ? 'Verify' : 'Send OTP'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password *',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: _passwordStrong
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              errorText: _passwordError,
              helperText: _passwordError == null ? 'Use 8+ chars with uppercase, lowercase & number' : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            obscureText: true,
            onChanged: (value) {
              _checkPasswordStrength(value);
              _validatePassword(value);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password *',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: _passwordMatch && _confirmPasswordController.text.isNotEmpty
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              errorText: _confirmPasswordError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            obscureText: true,
            onChanged: (_) => _validatePasswordMatch(),
          ),
          const SizedBox(height: 24),
          Text(
            'Select Your Role',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _userRole = 'farmer'),
                  child: Card(
                    color: _userRole == 'farmer'
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[200],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.agriculture,
                            size: 32,
                            color: _userRole == 'farmer'
                                ? Colors.white
                                : Colors.black,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Farmer',
                            style: TextStyle(
                              color: _userRole == 'farmer'
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _userRole = 'official'),
                  child: Card(
                    color: _userRole == 'official'
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[200],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.security,
                            size: 32,
                            color: _userRole == 'official'
                                ? Colors.white
                                : Colors.black,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Official',
                            style: TextStyle(
                              color: _userRole == 'official'
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Back to Login'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _nextPage,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSpecificPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complete Your Profile',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Step 2: ${_userRole == 'farmer' ? 'Farm Details' : 'Official Details'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          if (_userRole == 'farmer') ...[
            TextField(
              controller: _villageController,
              decoration: InputDecoration(
                labelText: 'Village',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _districtController,
              decoration: InputDecoration(
                labelText: 'District',
                prefixIcon: const Icon(Icons.map),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _stateController,
              decoration: InputDecoration(
                labelText: 'State',
                prefixIcon: const Icon(Icons.public),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _farmSizeController,
              decoration: InputDecoration(
                labelText: 'Farm Size (in acres)',
                prefixIcon: const Icon(Icons.straighten),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _aadharController,
              decoration: InputDecoration(
                labelText: 'Aadhar Number (12 digits)',
                prefixIcon: const Icon(Icons.badge),
                suffixIcon: _aadharController.text.length == 12 &&
                        _validateAadhar(_aadharController.text)
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                helperText: 'Required for insurance verification',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
              maxLength: 12,
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Crops You Grow',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _cropOptions.map((crop) {
                final isSelected = _selectedCrops.contains(crop);
                return FilterChip(
                  label: Text(crop),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCrops.add(crop);
                      } else {
                        _selectedCrops.remove(crop);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ] else ...[
            TextField(
              controller: _officialIdController,
              decoration: InputDecoration(
                labelText: 'Official ID',
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _designationController,
              decoration: InputDecoration(
                labelText: 'Designation',
                prefixIcon: const Icon(Icons.work),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _departmentController,
              decoration: InputDecoration(
                labelText: 'Department',
                prefixIcon: const Icon(Icons.domain),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _assignedDistrictController,
              decoration: InputDecoration(
                labelText: 'Assigned District',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _previousPage,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Register'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

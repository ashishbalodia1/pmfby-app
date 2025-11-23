import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../domain/models/user_model.dart';
import '../data/services/auth_service.dart';
import 'providers/auth_provider.dart';

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
  List<String> _selectedCrops = [];

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
      if (_validateCommonFields()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validateCommonFields() {
    if (_nameController.text.isEmpty) {
      _showError('Please enter your name');
      return false;
    }
    if (_emailController.text.isEmpty ||
        !_emailController.text.contains('@')) {
      _showError('Please enter a valid email');
      return false;
    }
    if (_phoneController.text.isEmpty ||
        _phoneController.text.length != 10) {
      _showError('Please enter a valid 10-digit phone number');
      return false;
    }
    if (_passwordController.text.isEmpty ||
        _passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return false;
    }
    if (_passwordController.text !=
        _confirmPasswordController.text) {
      _showError('Passwords do not match');
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
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email Address',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number (10 digits)',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            obscureText: true,
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
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

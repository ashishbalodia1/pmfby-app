import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  // Sample user data
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _aadharController;
  late TextEditingController _farmSizeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _aadharController = TextEditingController();
    _farmSizeController = TextEditingController();
  }

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    setState(() {
      _isEditing = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _aadharController.dispose();
    _farmSizeController.dispose();
    super.dispose();
  }

  void _populateControllers(user) {
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      if (user.role == 'farmer') {
        _addressController.text = '${user.village}, ${user.district}, ${user.state}';
        _aadharController.text = user.aadharNumber != null ? '****-****-${user.aadharNumber.substring(8)}' : 'Not provided';
        _farmSizeController.text = user.farmSize != null ? '${user.farmSize} acres' : 'Not specified';
      } else {
        _addressController.text = '${user.department}, ${user.assignedDistrict}';
        _aadharController.text = user.officialId ?? 'Not provided';
        _farmSizeController.text = user.designation ?? 'Not specified';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        // Populate controllers when user data is available
        if (user != null && _nameController.text.isEmpty) {
          _populateControllers(user);
        }
        
        return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  _nameController.text.isNotEmpty
                      ? _nameController.text.split(' ').map((e) => e[0]).join()
                      : 'RK',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 48,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // Personal Information Section
            _buildSectionHeader('Personal Information'),
            _buildProfileField(
              label: 'Full Name',
              controller: _nameController,
              icon: Icons.person,
              enabled: _isEditing,
            ),
            _buildProfileField(
              label: 'Email Address',
              controller: _emailController,
              icon: Icons.email,
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildProfileField(
              label: 'Phone Number',
              controller: _phoneController,
              icon: Icons.phone,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24.0),

            // Address Information Section
            _buildSectionHeader('Address Information'),
            _buildProfileField(
              label: 'Address',
              controller: _addressController,
              icon: Icons.location_on,
              enabled: _isEditing,
              maxLines: 2,
            ),
            const SizedBox(height: 24.0),

            // Identification & Farm Section
            _buildSectionHeader('Identification & Farm Details'),
            _buildProfileField(
              label: 'Aadhar Number',
              controller: _aadharController,
              icon: Icons.badge,
              enabled: false,
            ),
            _buildProfileField(
              label: 'Farm Size',
              controller: _farmSizeController,
              icon: Icons.agriculture,
              enabled: _isEditing,
            ),
            const SizedBox(height: 32.0),

            // Action Buttons
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _isEditing = false);
                        // Reset to original values
                        _nameController.text = 'Raj Kumar';
                        _emailController.text = 'raj.kumar@example.com';
                        _phoneController.text = '+91 98765 43210';
                        _addressController.text =
                            'Village Name, District, State - 123456';
                        _farmSizeController.text = '2.5 acres';
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saveProfile,
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                ),
              ),

            const SizedBox(height: 16.0),

            // Additional Options
            if (!_isEditing) ...[
              const Divider(height: 32.0),
              _buildOptionTile(
                icon: Icons.security,
                title: 'Change Password',
                subtitle: 'Update your security settings',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feature coming soon!')),
                  );
                },
              ),
              _buildOptionTile(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feature coming soon!')),
                  );
                },
              ),
              _buildOptionTile(
                icon: Icons.help,
                title: 'Help & Support',
                subtitle: 'Get help and contact support',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feature coming soon!')),
                  );
                },
              ),
              _buildOptionTile(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out from your account',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text(
                            'Are you sure you want to logout from your account?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await context.read<AuthProvider>().logout();
                              if (context.mounted) {
                                context.go('/');
                              }
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      );
                    },
                  );
                },
                isDestructive: true,
              ),
            ],
          ],
        ),
      ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          filled: !enabled,
          fillColor: !enabled ? Colors.grey.withOpacity(0.1) : null,
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive
              ? Colors.red
              : Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDestructive
              ? Colors.red
              : Theme.of(context).colorScheme.primary,
        ),
        onTap: onTap,
      ),
    );
  }
}

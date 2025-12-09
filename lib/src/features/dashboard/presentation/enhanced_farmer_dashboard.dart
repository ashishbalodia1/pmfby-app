import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/language_provider.dart';

class EnhancedFarmerDashboard extends StatefulWidget {
  const EnhancedFarmerDashboard({super.key});

  @override
  State<EnhancedFarmerDashboard> createState() => _EnhancedFarmerDashboardState();
}

class _EnhancedFarmerDashboardState extends State<EnhancedFarmerDashboard> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home, label: 'Home', labelHi: 'होम'),
    _NavItem(icon: Icons.assignment, label: 'Claims', labelHi: 'दावे'),
    _NavItem(icon: Icons.policy, label: 'Schemes', labelHi: 'योजनाएं'),
    _NavItem(icon: Icons.person, label: 'Profile', labelHi: 'प्रोफ़ाइल'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langProvider = context.watch<LanguageProvider>();
    final isHindi = langProvider.currentLanguage == 'hi';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Krishi Bandhu',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          // Theme selector
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: isHindi ? 'थीम बदलें' : 'Change Theme',
            onPressed: () {
              context.push('/theme-selector');
            },
          ),
          // Language toggle
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: isHindi ? 'भाषा बदलें' : 'Change Language',
            onPressed: () async {
              final newLang = isHindi ? 'en' : 'hi';
              await langProvider.setLanguage(newLang);
            },
          ),
          // Notifications
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeScreen(context),
          _buildPlaceholder('Claims', Icons.assignment),
          _buildPlaceholder('Schemes', Icons.policy),
          _buildPlaceholder('Profile', Icons.person),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: _navItems
            .map((item) => NavigationDestination(
                  icon: Icon(item.icon),
                  label: isHindi ? item.labelHi : item.label,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildHomeScreen(BuildContext context) {
    final theme = Theme.of(context);
    final langProvider = context.watch<LanguageProvider>();
    final isHindi = langProvider.currentLanguage == 'hi';
    final userName = 'Farmer';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      userName[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi ? 'नमस्ते, $userName' : 'Welcome, $userName',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isHindi ? 'आपकी फसल सुरक्षा हमारी जिम्मेदारी' : 'Your crop protection partner',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions Section
          Text(
            isHindi ? 'त्वरित कार्य' : 'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildQuickActionCard(
                  context,
                  icon: Icons.camera_alt,
                  label: isHindi ? 'फोटो खींचें' : 'Capture',
                  color: Colors.blue,
                  onTap: () => context.push('/camera'),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.upload_file,
                  label: isHindi ? 'अपलोड करें' : 'Upload',
                  color: Colors.green,
                  onTap: () => context.push('/upload'),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.satellite_alt,
                  label: isHindi ? 'सैटेलाइट' : 'Satellite',
                  color: Colors.purple,
                  onTap: () => context.push('/satellite'),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.help_outline,
                  label: isHindi ? 'सहायता' : 'Help',
                  color: Colors.orange,
                  onTap: () {
                    // TODO: Show help
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Services Section
          Text(
            isHindi ? 'सेवाएं' : 'Services',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildServiceCard(
                context,
                icon: Icons.report_problem,
                title: isHindi ? 'फसल क्षति' : 'Crop Loss',
                subtitle: isHindi ? 'नुकसान दर्ज करें' : 'Report damage',
                onTap: () => context.push('/crop-loss-intimation'),
              ),
              _buildServiceCard(
                context,
                icon: Icons.calculate,
                title: isHindi ? 'प्रीमियम' : 'Premium',
                subtitle: isHindi ? 'गणना करें' : 'Calculate',
                onTap: () => context.push('/premium-calculator'),
              ),
              _buildServiceCard(
                context,
                icon: Icons.policy,
                title: isHindi ? 'योजनाएं' : 'Schemes',
                subtitle: isHindi ? 'देखें' : 'View all',
                onTap: () => context.push('/schemes'),
              ),
              _buildServiceCard(
                context,
                icon: Icons.assignment,
                title: isHindi ? 'दावे' : 'Claims',
                subtitle: isHindi ? 'ट्रैक करें' : 'Track status',
                onTap: () => context.push('/claims'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Weather Info Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wb_sunny, color: Colors.orange.shade400),
                      const SizedBox(width: 8),
                      Text(
                        isHindi ? 'मौसम की जानकारी' : 'Weather Information',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildWeatherInfo(Icons.thermostat, '28°C', isHindi ? 'तापमान' : 'Temp'),
                      _buildWeatherInfo(Icons.water_drop, '65%', isHindi ? 'आर्द्रता' : 'Humidity'),
                      _buildWeatherInfo(Icons.air, '12 km/h', isHindi ? 'हवा' : 'Wind'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tips Card
          Card(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isHindi ? 'आज की सलाह' : 'Today\'s Tip',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isHindi
                        ? 'नई फसल बोने से पहले PMFBY बीमा अवश्य कराएं। यह आपकी फसल को प्राकृतिक आपदाओं से बचाता है।'
                        : 'Ensure PMFBY insurance before sowing new crops. It protects your crops from natural calamities.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            '$title Screen',
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon...',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String labelHi;

  _NavItem({required this.icon, required this.label, required this.labelHi});
}

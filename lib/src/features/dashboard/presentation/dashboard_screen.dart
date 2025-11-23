import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../services/firebase_auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../models/user_profile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final authService = context.read<FirebaseAuthService>();
    final firestoreService = FirestoreService();
    
    if (authService.currentUser != null) {
      final profile = await firestoreService.getUserProfile(
        authService.currentUser!.uid,
      );
      
      // If profile doesn't exist, create a default one with Anshika's details
      if (profile == null) {
        final newProfile = UserProfile(
          uid: authService.currentUser!.uid,
          name: 'Anshika',
          phoneNumber: authService.currentUser!.phoneNumber ?? '',
          email: 'anshika@cropic.in',
          village: 'Jaitpur',
          district: 'Barabanki',
          state: 'Uttar Pradesh',
          crops: ['धान (Rice)', 'गेहूं (Wheat)', 'गन्ना (Sugarcane)'],
          landAreaAcres: 5.0,
        );
        await firestoreService.createUserProfile(newProfile);
        setState(() {
          _userProfile = newProfile;
          _isLoading = false;
        });
      } else {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeScreen(),
      _buildClaimsScreen(),
      _buildSchemesScreen(),
      _buildProfileScreen(),
    ];

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'होम (Home)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'दावे (Claims)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.policy),
            label: 'योजना (Schemes)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'प्रोफाइल (Profile)',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green.shade50,
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: Colors.green.shade700,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'CROPIC',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.green.shade700,
                        Colors.green.shade500,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Icon(
                          Icons.agriculture,
                          size: 200,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'नमस्ते, ${_userProfile?.name ?? "किसान"} 🙏',
                              style: GoogleFonts.notoSans(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'आज का मौसम: धूप ☀️',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Quick Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '5.0 एकड़',
                        'कुल भूमि',
                        Icons.landscape,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '3',
                        'फसलें',
                        Icons.eco,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '2',
                        'सक्रिय दावे',
                        Icons.pending_actions,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Action Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade600, Colors.green.shade800],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.push('/capture-image'),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'फसल की फोटो लें',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Capture Crop Image with GPS',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Quick Actions Grid
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildListDelegate([
                  _buildActionCard(
                    'नया दावा दर्ज करें',
                    'File New Claim',
                    Icons.add_circle_outline,
                    Colors.blue,
                    () => context.push('/file-claim'),
                  ),
                  _buildActionCard(
                    'मेरे दावे',
                    'My Claims',
                    Icons.history,
                    Colors.orange,
                    () => setState(() => _selectedIndex = 1),
                  ),
                  _buildActionCard(
                    'बीमा योजनाएं',
                    'Insurance Schemes',
                    Icons.policy,
                    Colors.purple,
                    () => setState(() => _selectedIndex = 2),
                  ),
                  _buildActionCard(
                    'मदद केंद्र',
                    'Help Center',
                    Icons.help_outline,
                    Colors.teal,
                    () => _showHelpDialog(),
                  ),
                ]),
              ),
            ),

            // Recent Activity
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'हाल की गतिविधि (Recent Activity)',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActivityTile(
                      'फोटो अपलोड की गई',
                      '2 घंटे पहले',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildActivityTile(
                      'AI विश्लेषण पूर्ण',
                      '3 घंटे पहले',
                      Icons.analytics,
                      Colors.blue,
                    ),
                    _buildActivityTile(
                      'दावा स्वीकृत',
                      '1 दिन पहले',
                      Icons.verified,
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String titleHindi,
    String titleEnglish,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                titleHindi,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                titleEnglish,
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTile(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/camera'),
        label: const Text('Capture Crop Image'),
        icon: const Icon(Icons.camera_alt_rounded),
    );
  }

  Widget _buildClaimsScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'मेरे दावे (My Claims)',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Claims screen - Will show list of insurance claims'),
      ),
    );
  }

  Widget _buildSchemesScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'बीमा योजनाएं (Insurance Schemes)',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Schemes screen - Will show PMFBY and other schemes'),
      ),
    );
  }

  Widget _buildProfileScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'प्रोफाइल (Profile)',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<FirebaseAuthService>().signOut();
              if (mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: _userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.green.shade100,
                    child: Text(
                      _userProfile!.name[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userProfile!.name,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _userProfile!.phoneNumber,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          if (title == 'My Profile') {
            context.push('/profile');
          } else if (title == 'My Complaints') {
            context.push('/complaints');
          }
          // Add navigation for other cards as needed
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 50.0,
              color: Theme.of(context).colorScheme.primary,
                  // Profile Details
                  _buildProfileDetail('गांव (Village)', _userProfile!.village ?? 'N/A'),
                  _buildProfileDetail('जिला (District)', _userProfile!.district ?? 'N/A'),
                  _buildProfileDetail('राज्य (State)', _userProfile!.state ?? 'N/A'),
                  _buildProfileDetail(
                    'भूमि क्षेत्र (Land Area)',
                    '${_userProfile!.landAreaAcres ?? 0} एकड़',
                  ),
                  _buildProfileDetail(
                    'फसलें (Crops)',
                    _userProfile!.crops.join(', '),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileDetail(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'मदद केंद्र (Help Center)',
          style: GoogleFonts.poppins(),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('हेल्पलाइन: 1800-XXX-XXXX'),
            const SizedBox(height: 8),
            Text('Email: support@cropic.gov.in'),
            const SizedBox(height: 8),
            Text('समय: सोमवार-शुक्रवार, 9 AM - 6 PM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('बंद करें (Close)'),
          ),
        ],
      ),
    );
  }
}

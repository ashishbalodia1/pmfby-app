import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

/// WORLD'S BEST FARMER-FRIENDLY DASHBOARD
/// Simple, Beautiful, Easy to Use - Perfect for farmers who can't read/write
class SimpleFarmerDashboard extends StatefulWidget {
  final String farmerName;
  final String village;

  const SimpleFarmerDashboard({
    super.key,
    required this.farmerName,
    required this.village,
  });

  @override
  State<SimpleFarmerDashboard> createState() => _SimpleFarmerDashboardState();
}

class _SimpleFarmerDashboardState extends State<SimpleFarmerDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    await Permission.microphone.request();
    await _speech.initialize();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Call helpline
  void _makeCall(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  // WhatsApp support
  void _openWhatsApp() async {
    final url = Uri.parse('https://wa.me/918800000000?text=मुझे%20मदद%20चाहिए');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1B5E20),
            const Color(0xFF2E7D32),
            const Color(0xFF43A047),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with farmer name
            _buildHeader(),
            
            // Main content - scrollable
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      
                      // Big, clear action buttons
                      _buildBigActionButton(
                        icon: Icons.camera_alt_rounded,
                        title: 'फोटो खींचें',
                        subtitle: 'फसल की तस्वीर',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                        ),
                        onTap: () => context.push('/file-crop-loss'),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      _buildBigActionButton(
                        icon: Icons.report_problem_rounded,
                        title: 'नुकसान बताएं',
                        subtitle: 'फसल खराब हो गई',
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFE63946)],
                        ),
                        onTap: () => context.push('/crop-loss-intimation'),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      _buildBigActionButton(
                        icon: Icons.assignment_rounded,
                        title: 'अपना दावा देखें',
                        subtitle: 'स्थिति जानें',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                        ),
                        onTap: () => context.push('/claims'),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      _buildBigActionButton(
                        icon: Icons.calculate_rounded,
                        title: 'प्रीमियम देखें',
                        subtitle: 'कितना पैसा',
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                        ),
                        onTap: () => context.push('/premium-calculator'),
                      ),
                      
                      const SizedBox(height: 25),
                      
                      // Help section
                      _buildHelpSection(),
                      
                      const SizedBox(height: 20),
                      
                      // Weather info card
                      _buildWeatherCard(),
                      
                      const SizedBox(height: 20),
                      
                      // Tips card
                      _buildTipsCard(),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Farmer icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: const Icon(
                  Icons.agriculture_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'नमस्ते',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.farmerName,
                      style: GoogleFonts.notoSans(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      '📍 ${widget.village}',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBigActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return FadeTransition(
      opacity: _animationController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        )),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 18),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.notoSans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.8),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.support_agent_rounded, color: Colors.blue.shade700, size: 28),
              const SizedBox(width: 10),
              Text(
                'मदद चाहिए?',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          // Phone call button
          _buildHelpButton(
            icon: Icons.phone,
            label: 'फोन करें',
            color: Colors.green,
            onTap: () => _makeCall('1800-180-1551'),
          ),
          
          const SizedBox(height: 10),
          
          // WhatsApp button
          _buildHelpButton(
            icon: Icons.chat,
            label: 'WhatsApp पर बात करें',
            color: const Color(0xFF25D366),
            onTap: _openWhatsApp,
          ),
        ],
      ),
    );
  }

  Widget _buildHelpButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.deepOrange.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Text(
                'आज का मौसम',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherItem('28°C', 'तापमान', Icons.thermostat),
              _buildWeatherItem('65%', 'नमी', Icons.water_drop),
              _buildWeatherItem('10%', 'बारिश', Icons.umbrella),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade100,
            Colors.green.shade200,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade300, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: Colors.green.shade700, size: 28),
              const SizedBox(width: 10),
              Text(
                'आज की सलाह',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '🌾 आपकी फसल स्वस्थ है। पानी और खाद का ध्यान रखें।\n\n☀️ अगले 3 दिन धूप रहेगी। सिंचाई करें।',
            style: GoogleFonts.notoSans(
              fontSize: 15,
              color: Colors.green.shade900,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/language_provider.dart';
import '../../../localization/app_localizations.dart';
import '../../../services/sentinel_hub_service.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class PremiumFarmerDashboard extends StatefulWidget {
  final String farmerName;
  final String village;
  final List<String> crops;
  final double landArea;

  const PremiumFarmerDashboard({
    super.key,
    required this.farmerName,
    required this.village,
    required this.crops,
    required this.landArea,
  });

  @override
  State<PremiumFarmerDashboard> createState() => _PremiumFarmerDashboardState();
}

class _PremiumFarmerDashboardState extends State<PremiumFarmerDashboard> with SingleTickerProviderStateMixin {
  final SentinelHubService _satelliteService = SentinelHubService();
  late AnimationController _animationController;
  bool _isLoading = true;
  
  // Satellite data (demo mode for now)
  double _ndvi = 0.75; // Vegetation health index
  double _ndwi = 0.42; // Water stress index
  double _soilMoisture = 68.0;
  String _cropHealthStatus = 'Good';
  Color _healthColor = Colors.green;
  
  // Weather data
  double _temperature = 28.0;
  double _humidity = 65.0;
  double _rainfall = 2.5;
  String _weatherCondition = 'Partly Cloudy';
  IconData _weatherIcon = Icons.wb_cloudy;
  
  // Alerts
  List<Map<String, dynamic>> _alerts = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.forward();
    _loadSatelliteData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSatelliteData() async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulate satellite data analysis
    final random = math.Random();
    setState(() {
      _ndvi = 0.65 + random.nextDouble() * 0.25; // 0.65-0.90
      _ndwi = 0.30 + random.nextDouble() * 0.30; // 0.30-0.60
      _soilMoisture = 55.0 + random.nextDouble() * 30; // 55-85%
      
      // Determine health status
      if (_ndvi >= 0.80) {
        _cropHealthStatus = 'Excellent';
        _healthColor = const Color(0xFF00C853);
      } else if (_ndvi >= 0.70) {
        _cropHealthStatus = 'Good';
        _healthColor = const Color(0xFF64DD17);
      } else if (_ndvi >= 0.60) {
        _cropHealthStatus = 'Fair';
        _healthColor = const Color(0xFFFF9800);
      } else {
        _cropHealthStatus = 'Poor';
        _healthColor = const Color(0xFFFF5252);
      }
      
      // Generate alerts based on data
      _alerts = [];
      if (_soilMoisture < 60) {
        _alerts.add({
          'type': 'warning',
          'title': 'Low Soil Moisture',
          'message': 'Consider irrigation soon',
          'icon': Icons.water_drop,
          'color': Colors.orange,
        });
      }
      if (_ndvi < 0.65) {
        _alerts.add({
          'type': 'alert',
          'title': 'Crop Stress Detected',
          'message': 'Check for pests or nutrient deficiency',
          'icon': Icons.warning,
          'color': Colors.red,
        });
      }
      
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final lang = languageProvider.currentLanguage;
        
        return RefreshIndicator(
          onRefresh: _loadSatelliteData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header with Gradient
                _buildWelcomeHeader(lang),
                
                const SizedBox(height: 16),
                
                // Quick Stats Cards
                _buildQuickStats(lang),
                
                const SizedBox(height: 20),
                
                // Crop Health Card (Satellite Data)
                _buildCropHealthCard(lang),
                
                const SizedBox(height: 16),
                
                // Weather Card
                _buildWeatherCard(lang),
                
                const SizedBox(height: 16),
                
                // Alerts Section
                if (_alerts.isNotEmpty) ...[
                  _buildAlertsSection(lang),
                  const SizedBox(height: 16),
                ],
                
                // Quick Actions
                _buildQuickActions(lang),
                
                const SizedBox(height: 16),
                
                // Tips & Advice
                _buildTipsCard(lang),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeHeader(String lang) {
    final greeting = _getGreeting(lang);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2E7D32),
            const Color(0xFF388E3C),
            const Color(0xFF43A047),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.agriculture,
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
                      greeting,
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.farmerName,
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // Settings
                },
                icon: const Icon(Icons.settings, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  widget.village,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.eco,
              label: lang == 'hi' ? 'फसलें' : 'Crops',
              value: widget.crops.length.toString(),
              color: const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.landscape,
              label: lang == 'hi' ? 'क्षेत्र' : 'Land',
              value: '${widget.landArea} ac',
              color: const Color(0xFF8BC34A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.satellite_alt,
              label: lang == 'hi' ? 'स्वास्थ्य' : 'Health',
              value: '${(_ndvi * 100).toInt()}%',
              color: _healthColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropHealthCard(String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _healthColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _healthColor.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_healthColor, _healthColor.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _healthColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.satellite_alt, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang == 'hi' ? '🌾 फसल स्वास्थ्य' : '🌾 Crop Health',
                          style: GoogleFonts.notoSansDevanagari(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lang == 'hi' ? 'सैटेलाइट डेटा से' : 'From Satellite Data',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _healthColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _cropHealthStatus,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  _buildHealthIndicator(
                    label: lang == 'hi' ? 'वनस्पति सूचकांक (NDVI)' : 'Vegetation Index (NDVI)',
                    value: _ndvi,
                    color: _healthColor,
                    icon: Icons.grass,
                  ),
                  const SizedBox(height: 16),
                  _buildHealthIndicator(
                    label: lang == 'hi' ? 'जल तनाव सूचकांक (NDWI)' : 'Water Stress Index (NDWI)',
                    value: _ndwi,
                    color: Colors.blue,
                    icon: Icons.water_drop,
                  ),
                  const SizedBox(height: 16),
                  _buildHealthIndicator(
                    label: lang == 'hi' ? 'मिट्टी की नमी' : 'Soil Moisture',
                    value: _soilMoisture / 100,
                    color: Colors.brown,
                    icon: Icons.terrain,
                    isPercentage: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator({
    required String label,
    required double value,
    required Color color,
    required IconData icon,
    bool isPercentage = false,
  }) {
    final displayValue = isPercentage ? '${(value * 100).toInt()}%' : value.toStringAsFixed(2);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              displayValue,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherCard(String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF42A5F5),
              Color(0xFF1E88E5),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E88E5).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_weatherIcon, color: Colors.white, size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _weatherCondition,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMM d').format(DateTime.now()),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${_temperature.toInt()}°C',
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(
                  icon: Icons.water_drop,
                  label: lang == 'hi' ? 'आर्द्रता' : 'Humidity',
                  value: '${_humidity.toInt()}%',
                ),
                _buildWeatherDetail(
                  icon: Icons.water,
                  label: lang == 'hi' ? 'वर्षा' : 'Rainfall',
                  value: '${_rainfall}mm',
                ),
                _buildWeatherDetail(
                  icon: Icons.air,
                  label: lang == 'hi' ? 'हवा' : 'Wind',
                  value: '12 km/h',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertsSection(String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang == 'hi' ? '⚠️ सूचनाएं' : '⚠️ Alerts',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          ..._alerts.map((alert) => _buildAlertCard(alert)).toList(),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alert['color'].withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: alert['color'].withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: alert['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(alert['icon'], color: alert['color'], size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert['message'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildQuickActions(String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang == 'hi' ? '⚡ त्वरित कार्य' : '⚡ Quick Actions',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.report_problem,
                  label: lang == 'hi' ? 'नुकसान रिपोर्ट' : 'Report Loss',
                  color: Colors.red,
                  onTap: () => context.go('/crop-loss'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.map,
                  label: lang == 'hi' ? 'सैटेलाइट मैप' : 'Satellite Map',
                  color: Colors.blue,
                  onTap: () {
                    // Navigate to satellite screen
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.phone,
                  label: lang == 'hi' ? 'सहायता' : 'Support',
                  color: Colors.green,
                  onTap: () => context.go('/pmfby-info'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.calculate,
                  label: lang == 'hi' ? 'प्रीमियम' : 'Premium',
                  color: Colors.orange,
                  onTap: () => context.go('/premium-calculator'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard(String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.shade50,
              Colors.orange.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.lightbulb, color: Colors.orange, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang == 'hi' ? '💡 आज की सलाह' : '💡 Today\'s Tip',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lang == 'hi' 
                        ? 'मिट्टी की नमी कम है। आज शाम सिंचाई करें।'
                        : 'Soil moisture is low. Irrigate this evening.',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 13,
                      color: Colors.grey.shade600,
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

  String _getGreeting(String lang) {
    final hour = DateTime.now().hour;
    if (lang == 'hi') {
      if (hour < 12) return 'सुप्रभात';
      if (hour < 17) return 'नमस्ते';
      return 'शुभ संध्या';
    } else {
      if (hour < 12) return 'Good Morning';
      if (hour < 17) return 'Good Afternoon';
      return 'Good Evening';
    }
  }
}

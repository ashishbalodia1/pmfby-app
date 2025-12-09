import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/language_provider.dart';
import '../../../services/sentinel_hub_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class PremiumOfficerDashboard extends StatefulWidget {
  final String officerName;
  final String designation;
  final String region;

  const PremiumOfficerDashboard({
    super.key,
    required this.officerName,
    required this.designation,
    required this.region,
  });

  @override
  State<PremiumOfficerDashboard> createState() => _PremiumOfficerDashboardState();
}

class _PremiumOfficerDashboardState extends State<PremiumOfficerDashboard> with SingleTickerProviderStateMixin {
  final SentinelHubService _satelliteService = SentinelHubService();
  late AnimationController _animationController;
  int _selectedTab = 0;
  
  // Analytics data
  final int _totalFarmers = 1247;
  final int _activeClaims = 23;
  final int _pendingReviews = 8;
  final double _totalAreaMonitored = 5234.5; // acres
  final int _alertsToday = 5;
  
  // Regional health data
  List<Map<String, dynamic>> _regionData = [];
  List<Map<String, dynamic>> _recentClaims = [];
  List<Map<String, dynamic>> _criticalAlerts = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.forward();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    await Future.delayed(const Duration(seconds: 1));
    
    final random = math.Random();
    setState(() {
      // Generate regional data
      _regionData = [
        {
          'name': 'North Zone',
          'farmers': 312,
          'avgHealth': 0.78,
          'alerts': 2,
          'color': Colors.blue,
        },
        {
          'name': 'South Zone',
          'farmers': 428,
          'avgHealth': 0.82,
          'alerts': 1,
          'color': Colors.green,
        },
        {
          'name': 'East Zone',
          'farmers': 256,
          'avgHealth': 0.65,
          'alerts': 3,
          'color': Colors.orange,
        },
        {
          'name': 'West Zone',
          'farmers': 251,
          'avgHealth': 0.72,
          'alerts': 1,
          'color': Colors.purple,
        },
      ];
      
      // Generate recent claims
      _recentClaims = [
        {
          'farmer': 'Rajesh Kumar',
          'crop': 'Wheat',
          'loss': 45,
          'date': '2025-12-08',
          'status': 'Pending',
          'amount': '₹45,000',
        },
        {
          'farmer': 'Suresh Patel',
          'crop': 'Cotton',
          'loss': 65,
          'date': '2025-12-07',
          'status': 'Under Review',
          'amount': '₹78,000',
        },
        {
          'farmer': 'Lakshmi Devi',
          'crop': 'Rice',
          'loss': 30,
          'date': '2025-12-06',
          'status': 'Approved',
          'amount': '₹32,000',
        },
      ];
      
      // Generate critical alerts
      _criticalAlerts = [
        {
          'type': 'Drought Risk',
          'zone': 'East Zone',
          'affected': 45,
          'severity': 'High',
          'color': Colors.red,
        },
        {
          'type': 'Pest Outbreak',
          'zone': 'North Zone',
          'affected': 23,
          'severity': 'Medium',
          'color': Colors.orange,
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Officer Header
            _buildOfficerHeader(),
            
            const SizedBox(height: 20),
            
            // Analytics Overview
            _buildAnalyticsOverview(),
            
            const SizedBox(height: 20),
            
            // Tab Navigation
            _buildTabNavigation(),
            
            const SizedBox(height: 20),
            
            // Tab Content
            if (_selectedTab == 0) ...[
              _buildOverviewTab(),
            ] else if (_selectedTab == 1) ...[
              _buildRegionalAnalysisTab(),
            ] else ...[
              _buildClaimsManagementTab(),
            ],
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1565C0),
            const Color(0xFF1976D2),
            const Color(0xFF1E88E5),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
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
                      widget.designation,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.officerName,
                      style: GoogleFonts.poppins(
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
                  // Notifications
                },
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications, color: Colors.white, size: 28),
                    if (_alertsToday > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$_alertsToday',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
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
                const Icon(Icons.location_city, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  widget.region,
                  style: GoogleFonts.poppins(
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

  Widget _buildAnalyticsOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Analytics Overview',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  icon: Icons.people,
                  label: 'Total Farmers',
                  value: _totalFarmers.toString(),
                  color: const Color(0xFF4CAF50),
                  trend: '+12%',
                  trendUp: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  icon: Icons.description,
                  label: 'Active Claims',
                  value: _activeClaims.toString(),
                  color: const Color(0xFF2196F3),
                  trend: '-5%',
                  trendUp: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  icon: Icons.pending_actions,
                  label: 'Pending Reviews',
                  value: _pendingReviews.toString(),
                  color: const Color(0xFFFF9800),
                  trend: '0%',
                  trendUp: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  icon: Icons.landscape,
                  label: 'Area (Acres)',
                  value: '${(_totalAreaMonitored / 1000).toStringAsFixed(1)}K',
                  color: const Color(0xFF9C27B0),
                  trend: '+8%',
                  trendUp: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required String trend,
    required bool trendUp,
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
            color: color.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendUp ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendUp ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: trendUp ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: trendUp ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildTab('Overview', 0),
            _buildTab('Regional', 1),
            _buildTab('Claims', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Critical Alerts
          Text(
            '🚨 Critical Alerts',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          ..._criticalAlerts.map((alert) => _buildCriticalAlertCard(alert)).toList(),
          
          const SizedBox(height: 24),
          
          // Crop Health Distribution
          Text(
            '📈 Crop Health Distribution',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          _buildHealthDistributionChart(),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          Text(
            '⚡ Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickActionsGrid(),
        ],
      ),
    );
  }

  Widget _buildCriticalAlertCard(Map<String, dynamic> alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            alert['color'].withOpacity(0.1),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alert['color'].withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: alert['color'].withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [alert['color'], alert['color'].withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.warning, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['type'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${alert['zone']} • ${alert['affected']} farmers affected',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: alert['color'],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              alert['severity'],
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthDistributionChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: 45,
              title: '45%',
              color: const Color(0xFF4CAF50),
              radius: 80,
              titleStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: 30,
              title: '30%',
              color: const Color(0xFF8BC34A),
              radius: 75,
              titleStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: 15,
              title: '15%',
              color: const Color(0xFFFF9800),
              radius: 70,
              titleStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: 10,
              title: '10%',
              color: const Color(0xFFFF5252),
              radius: 65,
              titleStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 0,
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildQuickActionCard(
          icon: Icons.map,
          label: 'Satellite View',
          color: Colors.blue,
          onTap: () {
            // Navigate to satellite
          },
        ),
        _buildQuickActionCard(
          icon: Icons.analytics,
          label: 'Analytics',
          color: Colors.purple,
          onTap: () {},
        ),
        _buildQuickActionCard(
          icon: Icons.download,
          label: 'Export Reports',
          color: Colors.green,
          onTap: () {},
        ),
        _buildQuickActionCard(
          icon: Icons.settings,
          label: 'Settings',
          color: Colors.orange,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
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

  Widget _buildRegionalAnalysisTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🗺️ Regional Analysis',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          ..._regionData.map((region) => _buildRegionCard(region)).toList(),
        ],
      ),
    );
  }

  Widget _buildRegionCard(Map<String, dynamic> region) {
    final healthPercent = (region['avgHealth'] * 100).toInt();
    final healthColor = region['avgHealth'] >= 0.75
        ? Colors.green
        : region['avgHealth'] >= 0.65
            ? Colors.orange
            : Colors.red;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            region['color'].withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: region['color'].withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [region['color'], region['color'].withOpacity(0.5)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      region['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      '${region['farmers']} farmers registered',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (region['alerts'] > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, size: 14, color: Colors.red.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${region['alerts']}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Avg. Crop Health',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: region['avgHealth'],
                              minHeight: 8,
                              backgroundColor: healthColor.withOpacity(0.2),
                              color: healthColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$healthPercent%',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: healthColor,
                          ),
                        ),
                      ],
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

  Widget _buildClaimsManagementTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 Recent Claims',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          ..._recentClaims.map((claim) => _buildClaimCard(claim)).toList(),
        ],
      ),
    );
  }

  Widget _buildClaimCard(Map<String, dynamic> claim) {
    Color statusColor;
    IconData statusIcon;
    
    switch (claim['status']) {
      case 'Approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Under Review':
        statusColor = Colors.blue;
        statusIcon = Icons.schedule;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      claim['farmer'],
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${claim['crop']} • ${claim['loss']}% loss',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      claim['status'],
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    claim['date'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Text(
                claim['amount'],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

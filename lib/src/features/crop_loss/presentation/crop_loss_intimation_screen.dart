import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/crop_loss_report.dart';
import 'package:intl/intl.dart';
import '../../../providers/language_provider.dart';
import '../../../localization/app_localizations.dart';

class CropLossIntimationScreen extends StatefulWidget {
  const CropLossIntimationScreen({super.key});

  @override
  State<CropLossIntimationScreen> createState() => _CropLossIntimationScreenState();
}

class _CropLossIntimationScreenState extends State<CropLossIntimationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Demo data
  final List<CropLossReport> _reports = [
    CropLossReport(
      id: 'CLR001',
      farmerId: 'F12345',
      farmerName: 'Ram Singh',
      cropType: 'Wheat',
      season: 'Rabi 2024-25',
      affectedArea: 2.5,
      lossType: 'Hailstorm',
      lossPercentage: '60-70%',
      incidentDate: DateTime(2024, 11, 15),
      reportedDate: DateTime(2024, 11, 16),
      district: 'Ludhiana',
      village: 'Dhandari',
      latitude: 30.9010,
      longitude: 75.8573,
      description: 'Heavy hailstorm damaged wheat crop in early growth stage',
      imagePaths: ['image1.jpg', 'image2.jpg'],
      status: 'under_review',
      claimNumber: 'CLM2024001',
    ),
    CropLossReport(
      id: 'CLR002',
      farmerId: 'F12345',
      farmerName: 'Ram Singh',
      cropType: 'Rice',
      season: 'Kharif 2024',
      affectedArea: 3.0,
      lossType: 'Flood',
      lossPercentage: '80-90%',
      incidentDate: DateTime(2024, 8, 20),
      reportedDate: DateTime(2024, 8, 21),
      district: 'Ludhiana',
      village: 'Dhandari',
      latitude: 30.9010,
      longitude: 75.8573,
      description: 'Flood water submerged the entire paddy field',
      imagePaths: ['image3.jpg', 'image4.jpg', 'image5.jpg'],
      status: 'approved',
      assessorComments: 'Assessed and approved for compensation',
      assessmentDate: DateTime(2024, 9, 5),
      claimNumber: 'CLM2024002',
    ),
    CropLossReport(
      id: 'CLR003',
      farmerId: 'F12345',
      farmerName: 'Ram Singh',
      cropType: 'Cotton',
      season: 'Kharif 2024',
      affectedArea: 1.5,
      lossType: 'Pest Attack',
      lossPercentage: '40-50%',
      incidentDate: DateTime(2024, 7, 10),
      reportedDate: DateTime(2024, 7, 12),
      district: 'Ludhiana',
      village: 'Dhandari',
      latitude: 30.9010,
      longitude: 75.8573,
      description: 'Pink bollworm infestation in cotton crop',
      imagePaths: ['image6.jpg'],
      status: 'pending_documents',
      assessorComments: 'Please submit pesticide purchase receipts',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final lang = languageProvider.currentLanguage;
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: Colors.red.shade600,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: Text(
              AppStrings.get('cropLoss', 'crop_loss_intimation', lang),
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.support_agent, color: Colors.white),
                onPressed: () => _showCustomerCareDialog(lang),
              ),
            ],
          ),
          body: Column(
            children: [
              // Top Alert Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade600, Colors.red.shade700],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Report within 72 hours of incident',
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Tab Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey.shade700,
                    labelStyle: GoogleFonts.notoSansDevanagari(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: GoogleFonts.notoSansDevanagari(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(text: AppStrings.get('cropLoss', 'new_report', lang)),
                      Tab(text: AppStrings.get('cropLoss', 'my_reports', lang)),
                    ],
                  ),
                ),
              ),
              
              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNewReportTab(lang),
                    _buildMyReportsTab(lang),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNewReportTab(String lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          
          // How to Report Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.blue.shade100, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.help_outline, color: Colors.blue.shade700, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'How to File Report',
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInstructionStep('1', 'Take clear photos', 'Capture damage from multiple angles'),
                  _buildInstructionStep('2', 'Fill in all required details', 'Crop type, area, loss percentage'),
                  _buildInstructionStep('3', 'Submit within 72 hours of incident', 'Quick reporting ensures faster processing'),
                  _buildInstructionStep('4', 'Track status in "My Reports"', 'Get updates on your claim'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.alarm, color: Colors.red.shade700, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Important: Report within 72 hours of incident',
                            style: GoogleFonts.notoSansDevanagari(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _buildModernActionCard(
                  'Take Photos',
                  Icons.camera_alt_rounded,
                  Colors.green.shade400,
                  () => context.push('/camera'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernActionCard(
                  'Call Support',
                  Icons.phone_rounded,
                  Colors.blue.shade400,
                  () => _showCustomerCareDialog(lang),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // File New Report Button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.red.shade600, Colors.red.shade700],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade300.withOpacity(0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/file-crop-loss'),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_circle, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'File New Report',
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Common Loss Types
          Text(
            'Common Loss Types',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Quick reference for reporting',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildPremiumLossCard('Flood', Icons.water_drop, Colors.blue.shade500, Colors.blue.shade50)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildPremiumLossCard('Drought', Icons.wb_sunny, Colors.orange.shade500, Colors.orange.shade50)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildPremiumLossCard('Hailstorm', Icons.ac_unit, Colors.cyan.shade500, Colors.cyan.shade50)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildPremiumLossCard('Pest Attack', Icons.bug_report, Colors.green.shade500, Colors.green.shade50)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildPremiumLossCard('Disease', Icons.coronavirus, Colors.purple.shade500, Colors.purple.shade50)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildPremiumLossCard('Fire', Icons.local_fire_department, Colors.red.shade500, Colors.red.shade50)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Emergency Contact Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade50, Colors.amber.shade50],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade200, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.phone_in_talk, color: Colors.orange.shade700, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Support',
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'For urgent crop loss, call 14447 immediately',
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMyReportsTab(String lang) {
    final pendingReports = _reports.where((r) => 
      r.status == 'submitted' || r.status == 'under_review' || r.status == 'pending_documents'
    ).toList();
    
    final completedReports = _reports.where((r) => 
      r.status == 'approved' || r.status == 'rejected'
    ).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  AppStrings.get('cropLoss', 'total_reports', lang),
                  _reports.length.toString(),
                  Icons.description,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  AppStrings.get('cropLoss', 'pending', lang),
                  pendingReports.length.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  AppStrings.get('cropLoss', 'approved', lang),
                  completedReports.where((r) => r.status == 'approved').length.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Pending Reports
          if (pendingReports.isNotEmpty) ...[
            Text(
              AppStrings.get('cropLoss', 'pending_reports', lang),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            ...pendingReports.map((report) => _buildReportCard(report, lang)),
            const SizedBox(height: 24),
          ],

          // Completed Reports
          if (completedReports.isNotEmpty) ...[
            Text(
              AppStrings.get('cropLoss', 'completed_reports', lang),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            ...completedReports.map((report) => _buildReportCard(report, lang)),
          ],

          if (_reports.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.description, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.get('cropLoss', 'no_reports_filed', lang),
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade500, Colors.blue.shade700],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.notoSansDevanagari(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.08), color.withOpacity(0.15)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumLossCard(String label, IconData icon, Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, bgColor.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
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
                colors: [iconColor.withOpacity(0.9), iconColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
        ],
      ),
    );
  }



  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 10,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(CropLossReport report, String lang) {
    Color statusColor;
    switch (report.status) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      case 'under_review':
        statusColor = Colors.orange;
        break;
      case 'pending_documents':
        statusColor = Colors.amber;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showReportDetails(report, lang),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      report.getStatusLabel(),
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'ID: ${report.id}',
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.eco, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    report.cropType,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${report.season})',
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.warning, 'Loss Type:', report.lossType),
              _buildInfoRow(Icons.percent, 'Loss:', report.lossPercentage),
              _buildInfoRow(Icons.square_foot, 'Affected Area:', '${report.affectedArea} hectares'),
              _buildInfoRow(Icons.calendar_today, 'Incident Date:', 
                DateFormat('dd MMM yyyy').format(report.incidentDate)),
              if (report.claimNumber != null)
                _buildInfoRow(Icons.receipt, 'Claim #:', report.claimNumber!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDetails(CropLossReport report, String lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.get('cropLoss', 'report_details', lang),
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Report ID', report.id),
              _buildDetailRow('Crop Type', report.cropType),
              _buildDetailRow('Season', report.season),
              _buildDetailRow('Loss Type', report.lossType),
              _buildDetailRow('Loss Percentage', report.lossPercentage),
              _buildDetailRow('Affected Area', '${report.affectedArea} hectares'),
              _buildDetailRow('District', report.district),
              _buildDetailRow('Village', report.village),
              _buildDetailRow('Incident Date', DateFormat('dd MMM yyyy').format(report.incidentDate)),
              _buildDetailRow('Reported Date', DateFormat('dd MMM yyyy').format(report.reportedDate)),
              if (report.claimNumber != null)
                _buildDetailRow('Claim Number', report.claimNumber!),
              const SizedBox(height: 16),
              Text(
                '${AppStrings.get('cropLoss', 'description', lang)}:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                report.description,
                style: GoogleFonts.roboto(fontSize: 14),
              ),
              if (report.assessorComments != null) ...[
                const SizedBox(height: 16),
                Text(
                  '${AppStrings.get('cropLoss', 'assessor_comments', lang)}:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    report.assessorComments!,
                    style: GoogleFonts.roboto(fontSize: 13),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black87,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(AppStrings.get('common', 'close', lang)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomerCareDialog(String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.support_agent, color: Colors.green.shade700, size: 28),
            const SizedBox(width: 12),
            Text(AppStrings.get('common', 'customer_support', lang)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.get('cropLoss', 'for_support', lang),
              style: GoogleFonts.roboto(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: const Text('Call 14447'),
              subtitle: Text(AppStrings.get('cropLoss', 'toll_free_helpline', lang)),
              onTap: () {
                Navigator.pop(context);
                // Launch phone
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text('WhatsApp: 7065514447'),
              subtitle: Text(AppStrings.get('cropLoss', 'chat_support', lang)),
              onTap: () {
                Navigator.pop(context);
                // Launch WhatsApp
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get('common', 'close', lang)),
          ),
        ],
      ),
    );
  }
}

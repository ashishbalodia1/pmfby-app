import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../localization/app_localizations.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // Helper method for Hindi text with proper Devanagari font
  TextStyle hindiTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.notoSansDevanagari(
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? Colors.black87,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Helper for English text
  TextStyle englishTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? Colors.black87,
      height: height,
    );
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

      return WillPopScope(
        onWillPop: () async {
          // Navigate back to dashboard instead of exiting app
          Navigator.of(context).pop();
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
          title: Text(
            AppStrings.get('schemes', 'insurance_schemes', lang),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            tabs: [
              Tab(text: AppStrings.get('schemes', 'all_schemes', lang)),
              Tab(text: AppStrings.get('schemes', 'eligibility_check', lang)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSchemesTab(lang),
            _buildEligibilityTab(lang),
          ],
        ),
        ),
      );
    },
  );
}


  Widget _buildSchemesTab(String lang) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // PMFBY Main Card - Featured
        _buildFeaturedSchemeCard(lang),
        
        const SizedBox(height: 24),
        
        Text(
          AppStrings.get('schemes', 'other_schemes', lang),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        
        const SizedBox(height: 16),

        // Weather Based Crop Insurance
        _buildSchemeCard(
          title: 'मौसम आधारित फसल बीमा योजना',
          subtitle: 'Weather Based Crop Insurance Scheme (WBCIS)',
          description: 'मौसम मापदंडों (वर्षा, तापमान, आर्द्रता, हवा की गति) के आधार पर बीमा',
          premium: '2-5% बीमित राशि का',
          coverage: 'मौसम पैरामीटर के आधार पर स्वचालित भुगतान',
          icon: Icons.cloud,
          color: Colors.blue,
          benefits: [
            'त्वरित दावा निपटान',
            'कोई फसल नुकसान सर्वेक्षण की आवश्यकता नहीं',
            'स्वचालित भुगतान',
          ],
        ),

        const SizedBox(height: 16),

        // Modified NAIS
        _buildSchemeCard(
          title: 'संशोधित राष्ट्रीय कृषि बीमा योजना',
          subtitle: 'Modified National Agricultural Insurance Scheme',
          description: 'सूखा, बाढ़, कीट, रोग और प्राकृतिक आपदाओं से व्यापक सुरक्षा',
          premium: 'अधिसूचित फसलों के लिए निर्धारित दर',
          coverage: 'बीमित राशि का 80-100%',
          icon: Icons.shield,
          color: Colors.orange,
          benefits: [
            'सभी खाद्यान्न और तिलहन फसलें शामिल',
            'बुवाई से कटाई तक कवरेज',
            'युद्धोत्तर नुकसान सुरक्षा',
          ],
        ),

        const SizedBox(height: 16),

        // Coconut Palm Insurance
        _buildSchemeCard(
          title: 'नारियल पाम बीमा योजना',
          subtitle: 'Coconut Palm Insurance Scheme (CPIS)',
          description: 'नारियल उत्पादक किसानों के लिए विशेष योजना',
          premium: '₹9 प्रति पेड़ प्रति वर्ष',
          coverage: '₹900 - ₹1,350 प्रति पेड़',
          icon: Icons.park,
          color: Colors.brown,
          benefits: [
            '4-60 वर्ष पुराने पेड़ों के लिए',
            'प्राकृतिक आपदा से नुकसान',
            'आग और बिजली से सुरक्षा',
          ],
        ),

        const SizedBox(height: 16),

        // Pilot Unified Package Insurance
        _buildSchemeCard(
          title: 'पायलट एकीकृत पैकेज बीमा योजना',
          subtitle: 'Pilot Unified Package Insurance Scheme',
          description: 'संपत्ति, जीवन और फसल का संयुक्त बीमा',
          premium: 'पैकेज के आधार पर',
          coverage: 'व्यापक कवरेज',
          icon: Icons.card_travel,
          color: Colors.teal,
          benefits: [
            'जीवन, घर और फसल सुरक्षा',
            'छात्र सुरक्षा शामिल',
            'व्यक्तिगत दुर्घटना कवर',
          ],
        ),

        const SizedBox(height: 24),

        // Key Features Section
        _buildKeyFeaturesCard(),

        const SizedBox(height: 24),

        // How to Apply Section
        _buildHowToApplyCard(),

        const SizedBox(height: 24),

        // Contact & Support
        _buildContactCard(),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFeaturedSchemeCard(String lang) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade600,
            Colors.green.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPMFBYDetails(),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.yellow.shade700,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '⭐ Featured',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'प्रधानमंत्री फसल बीमा योजना',
                  style: hindiTextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
                  style: englishTextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'फसल को बुवाई से कटाई तक होने वाले नुकसान के खिलाफ व्यापक जोखिम कवरेज',
                  style: hindiTextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.95),
                    height: 1.6,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildInfoChip('खरीफ: 2%', Icons.percent),
                    _buildInfoChip('रबी: 1.5%', Icons.percent),
                    _buildInfoChip('बागवानी: 5%', Icons.local_florist),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Launch Date: 18 February 2016',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        'और जानें →',
                        style: hindiTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
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
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: hindiTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyFeaturesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.blue.shade700, size: 28),
              const SizedBox(width: 12),
              Text(
                'प्रमुख विशेषताएं',
                style: hindiTextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFeatureItem('✓', 'कम प्रीमियम, उच्च कवरेज'),
          _buildFeatureItem('✓', 'सभी प्रकार की फसलों के लिए'),
          _buildFeatureItem('✓', 'त्वरित दावा निपटान'),
          _buildFeatureItem('✓', 'प्राकृतिक आपदा सुरक्षा'),
          _buildFeatureItem('✓', 'मोबाइल ऐप के माध्यम से आवेदन'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String bullet, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bullet,
            style: englishTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: hindiTextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToApplyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.purple.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: Colors.purple.shade700, size: 28),
              const SizedBox(width: 12),
              Text(
                'आवेदन कैसे करें?',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStep('1', 'नजदीकी बैंक/कृषि कार्यालय जाएं'),
          _buildStep('2', 'आधार, भूमि रिकॉर्ड दस्तावेज़ जमा करें'),
          _buildStep('3', 'फसल बोने के 7 दिनों के भीतर आवेदन करें'),
          _buildStep('4', 'प्रीमियम राशि जमा करें'),
          _buildStep('5', 'बीमा पॉलिसी प्राप्त करें'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'आवश्यक दस्तावेज़:',
                  style: hindiTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple.shade900,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDocItem('• आधार कार्ड'),
                _buildDocItem('• बैंक खाता विवरण'),
                _buildDocItem('• भूमि रिकॉर्ड (खसरा/खतौनी)'),
                _buildDocItem('• फसल बोने का प्रमाण'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: hindiTextStyle(
          fontSize: 13,
          color: Colors.grey.shade700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.support_agent, color: Colors.green.shade700, size: 28),
              const SizedBox(width: 12),
              Text(
                'सहायता एवं संपर्क',
                style: hindiTextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            Icons.phone,
            'हेल्पलाइन',
            '011-23382012',
            () => _launchUrl('tel:01123382012'),
          ),
          _buildContactItem(
            Icons.email,
            'ईमेल',
            'pmfby-helpdesk@gov.in',
            () => _launchUrl('mailto:pmfby-helpdesk@gov.in'),
          ),
          _buildContactItem(
            Icons.language,
            'वेबसाइट',
            'www.pmfby.gov.in',
            () => _launchUrl('https://pmfby.gov.in'),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'अन्य महत्वपूर्ण लिंक',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            Icons.home_work,
            'कृषि मंत्रालय',
            'agricoop.gov.in',
            () => _launchUrl('https://agricoop.gov.in'),
          ),
          _buildContactItem(
            Icons.app_registration,
            'PMFBY रजिस्ट्रेशन',
            'pmfby.gov.in/farmerRegistration',
            () => _launchUrl('https://pmfby.gov.in/farmerRegistration'),
          ),
          _buildContactItem(
            Icons.track_changes,
            'क्लेम ट्रैकिंग',
            'pmfby.gov.in/claimStatus',
            () => _launchUrl('https://pmfby.gov.in/claimStatus'),
          ),
          _buildContactItem(
            Icons.question_answer,
            'FAQ',
            'pmfby.gov.in/faq',
            () => _launchUrl('https://pmfby.gov.in/faq'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.green.shade700, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: hindiTextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildEligibilityTab(String lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'पात्रता मानदंड',
            style: hindiTextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Eligibility Criteria for PMFBY',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildEligibilityCard(
            'किसान पात्रता',
            [
              'सभी भारतीय किसान (मालिक/किरायेदार)',
              'अधिसूचित क्षेत्र में फसल उगाने वाले',
              'ऋणी और गैर-ऋणी दोनों किसान',
              'छोटे और सीमांत किसान',
              'बटाईदार और किरायेदार किसान',
            ],
            Icons.person_outline,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildEligibilityCard(
            'फसल पात्रता',
            [
              'खाद्य फसलें (अनाज, दालें)',
              'तिलहन फसलें',
              'वार्षिक वाणिज्यिक/बागवानी फसलें',
              'बारहमासी फसलें (5 वर्ष बाद)',
            ],
            Icons.eco,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildEligibilityCard(
            'कवरेज जोखिम',
            [
              'बुवाई/रोपण जोखिम',
              'खड़ी फसल (बुवाई से कटाई)',
              'कटाई उपरांत नुकसान (14 दिन तक)',
              'स्थानीय आपदाएं (ओलावृष्टि, भूस्खलन)',
            ],
            Icons.security,
            Colors.blue,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade50, Colors.amber.shade100],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.amber.shade800, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'महत्वपूर्ण नोट',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• ऋणी किसानों के लिए बीमा अनिवार्य है\n'
                  '• गैर-ऋणी किसान स्वैच्छिक रूप से शामिल हो सकते हैं\n'
                  '• बुवाई के 7 दिनों के भीतर पंजीकरण आवश्यक\n'
                  '• बैंक खाते से सीधे प्रीमियम काट लिया जाएगा',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityCard(String title, List<String> items, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSchemeCard({
    required String title,
    required String subtitle,
    required String description,
    required String premium,
    required String coverage,
    required IconData icon,
    required Color color,
    List<String>? benefits,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSchemeDetails(title),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: hindiTextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: hindiTextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'प्रीमियम',
                                  style: hindiTextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  premium,
                                  style: hindiTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'कवरेज',
                                  style: hindiTextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  coverage,
                                  style: hindiTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (benefits != null && benefits.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...benefits.map((benefit) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: color, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            benefit,
                            style: hindiTextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.purple.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: englishTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: hindiTextStyle(
                fontSize: 15,
                color: Colors.black87,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSchemeDetails(String schemeName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: controller,
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
                schemeName,
                style: hindiTextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'यह योजना के विस्तृत विवरण के लिए एक प्लेसहोल्डर है। पूर्ण जानकारी जल्द ही जोड़ी जाएगी।',
                style: hindiTextStyle(
                  fontSize: 15,
                  letterSpacing: 0.3,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('बंद करें'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPMFBYDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'प्रधानमंत्री फसल बीमा योजना',
                style: hindiTextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
                style: englishTextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'योजना का उद्देश्य:',
                style: hindiTextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'पीएमएफबीवाई का उद्देश्य कृषि क्षेत्र में स्थायी उत्पादन का समर्थन करना है। यह योजना किसानों की आय को स्थिरता प्रदान करने और उन्हें नवीन कृषि पद्धतियों को अपनाने के लिए प्रोत्साहित करने का लक्ष्य रखती है।',
                style: hindiTextStyle(fontSize: 15, height: 1.6, letterSpacing: 0.3),
              ),
              const SizedBox(height: 20),
              Text(
                'मुख्य विशेषताएं:',
                style: hindiTextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),
              _buildDetailItem('🌾', 'सभी खाद्य और तिलहनी फसलों के लिए'),
              _buildDetailItem('💰', 'बहुत कम प्रीमियम दर'),
              _buildDetailItem('📱', 'मोबाइल ऐप के माध्यम से आसान पंजीकरण'),
              _buildDetailItem('⚡', 'त्वरित दावा निपटान प्रक्रिया'),
              _buildDetailItem('🛡️', 'व्यापक जोखिम कवरेज'),
              const SizedBox(height: 20),
              Text(
                'प्रीमियम दरें:',
                style: hindiTextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPremiumRow('खरीफ फसलें', '2%'),
                    const Divider(height: 16),
                    _buildPremiumRow('रबी फसलें', '1.5%'),
                    const Divider(height: 16),
                    _buildPremiumRow('वार्षिक बागवानी फसलें', '5%'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('बंद करें'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: hindiTextStyle(fontSize: 15, height: 1.5, letterSpacing: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumRow(String crop, String rate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          crop,
          style: hindiTextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        Text(
          rate,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('लिंक नहीं खुल सका: $url'),
            backgroundColor: Colors.red.shade600,
            action: SnackBarAction(
              label: 'ठीक है',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }
}

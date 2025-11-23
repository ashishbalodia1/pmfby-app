import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SchemesScreen extends StatelessWidget {
  const SchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'बीमा योजनाएं',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // PMFBY Card
          _buildSchemeCard(
            context,
            title: 'PMFBY - प्रधानमंत्री फसल बीमा योजना',
            subtitle: 'Pradhan Mantri Fasal Bima Yojana',
            description:
                'किसानों को प्राकृतिक आपदाओं से होने वाले नुकसान के लिए व्यापक बीमा कवरेज प्रदान करता है।',
            premium: '2% (खरीफ), 1.5% (रबी)',
            coverage: '₹50,000 - ₹2,00,000 प्रति एकड़',
            icon: Icons.agriculture,
            color: Colors.green,
          ),

          const SizedBox(height: 16),

          // Weather Based Crop Insurance
          _buildSchemeCard(
            context,
            title: 'मौसम आधारित बीमा योजना',
            subtitle: 'Weather Based Crop Insurance Scheme',
            description:
                'मौसम की स्थिति (बारिश, तापमान) के आधार पर फसल नुकसान का बीमा।',
            premium: '3-5% फसल मूल्य का',
            coverage: 'मौसम पैरामीटर के आधार पर',
            icon: Icons.cloud,
            color: Colors.blue,
          ),

          const SizedBox(height: 16),

          // Modified NAIS
          _buildSchemeCard(
            context,
            title: 'संशोधित राष्ट्रीय कृषि बीमा योजना',
            subtitle: 'Modified National Agricultural Insurance Scheme',
            description: 'सूखा, बाढ़, कीट और रोग से सुरक्षा प्रदान करता है।',
            premium: 'अलग-अलग फसलों के लिए अलग',
            coverage: 'फसल मूल्य का 100% तक',
            icon: Icons.shield,
            color: Colors.orange,
          ),

          const SizedBox(height: 16),

          // Coconut Palm Insurance
          _buildSchemeCard(
            context,
            title: 'नारियल पाम बीमा योजना',
            subtitle: 'Coconut Palm Insurance Scheme',
            description: 'नारियल के पेड़ों के लिए विशेष बीमा योजना।',
            premium: '₹9 प्रति पेड़ प्रति वर्ष',
            coverage: '₹900 - ₹1,350 प्रति पेड़',
            icon: Icons.park,
            color: Colors.brown,
          ),

          const SizedBox(height: 24),

          // How to Apply Section
          Container(
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStep('1', 'नजदीकी बैंक/कृषि कार्यालय जाएं'),
                _buildStep('2', 'आवश्यक दस्तावेज़ जमा करें'),
                _buildStep('3', 'प्रीमियम जमा करें'),
                _buildStep('4', 'पॉलिसी प्राप्त करें'),
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
                        '📄 आवश्यक दस्तावेज़:',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• आधार कार्ड\n'
                        '• बैंक खाता विवरण\n'
                        '• भूमि दस्तावेज़\n'
                        '• किसान क्रेडिट कार्ड (यदि उपलब्ध हो)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Contact Information
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.phone_in_talk, color: Colors.green.shade700, size: 40),
                const SizedBox(height: 12),
                Text(
                  'सहायता के लिए संपर्क करें',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '📞 टोल फ्री: 1800-180-1551\n'
                  '📧 Email: help.pmfby@gov.in\n'
                  '🌐 Website: pmfby.gov.in',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green.shade900,
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

  Widget _buildSchemeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required String premium,
    required String coverage,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
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
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          subtitle,
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
              const SizedBox(height: 16),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.currency_rupee, size: 18, color: color),
                        const SizedBox(width: 8),
                        Text(
                          'प्रीमियम: ',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            premium,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      children: [
                        Icon(Icons.verified_user, size: 18, color: color),
                        const SizedBox(width: 8),
                        Text(
                          'कवरेज: ',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            coverage,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showSchemeDetails(context, title);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'अधिक जानें (Learn More)',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
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
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  void _showSchemeDetails(BuildContext context, String schemeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          schemeName,
          style: GoogleFonts.poppins(fontSize: 16),
        ),
        content: const Text(
          'योजना के बारे में अधिक जानकारी के लिए कृपया अपने नजदीकी कृषि कार्यालय से संपर्क करें या pmfby.gov.in पर जाएं।',
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

class PMFBYInfoScreen extends StatefulWidget {
  const PMFBYInfoScreen({super.key});

  @override
  State<PMFBYInfoScreen> createState() => _PMFBYInfoScreenState();
}

class _PMFBYInfoScreenState extends State<PMFBYInfoScreen> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() => _showFront = !_showFront);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PMFBY जानकारी',
          style: GoogleFonts.notoSansDevanagari(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF138808),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Government of India Header - Centered with flip animation
            Center(child: _buildGovernmentHeader()),
            const SizedBox(height: 24),
            
            // About PMFBY
            _buildSectionCard(
              'योजना के बारे में',
              'About the Scheme',
              Icons.info_outline,
              _buildAboutContent(),
            ),
            const SizedBox(height: 16),
            
            // Key Features
            _buildSectionCard(
              'मुख्य विशेषताएं',
              'Key Features',
              Icons.star_outline,
              _buildFeaturesContent(),
            ),
            const SizedBox(height: 16),
            
            // Premium Rates
            _buildSectionCard(
              'प्रीमियम दरें',
              'Premium Rates',
              Icons.currency_rupee,
              _buildPremiumContent(),
            ),
            const SizedBox(height: 16),
            
            // Helpline Numbers
            _buildSectionCard(
              'हेल्पलाइन नंबर',
              'Helpline Numbers',
              Icons.phone,
              _buildHelplineContent(),
            ),
            const SizedBox(height: 16),
            
            // Agriculture Ministry Contact
            _buildSectionCard(
              'कृषि मंत्रालय संपर्क',
              'Agriculture Ministry Contact',
              Icons.account_balance,
              _buildMinistryContact(),
            ),
            const SizedBox(height: 16),
            
            // Official Links
            _buildSectionCard(
              'आधिकारिक लिंक',
              'Official Links',
              Icons.link,
              _buildLinksContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGovernmentHeader() {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, child) {
          final angle = _flipController.value * math.pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: angle < math.pi / 2 ? _buildFrontCard() : _buildBackCard(),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.green.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade700],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              size: 45,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'भारत सरकार',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Government of India',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 2,
            width: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade300, Colors.green.shade600],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final uri = Uri.parse('https://agricoop.nic.in');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Column(
              children: [
                Text(
                  'कृषि एवं किसान कल्याण मंत्रालय',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ministry of Agriculture & Farmers Welfare',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.language, size: 12, color: Colors.blue.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'agricoop.nic.in',
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 10,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app, size: 16, color: Colors.green.shade600),
              const SizedBox(width: 6),
              Text(
                'Tap to see more',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return Transform(
      transform: Matrix4.identity()..rotateY(math.pi),
      alignment: Alignment.center,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade700, Colors.green.shade900],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 3,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 40, color: Colors.white.withOpacity(0.9)),
            const SizedBox(height: 16),
            Text(
              'PMFBY - Empowering Farmers',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.calendar_today, 'Launched: 2016'),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.people, '36 Crore+ Farmers'),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.currency_rupee, '₹1,35,000+ Cr Claims'),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.phone, 'Helpline: 18001801551'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app, size: 16, color: Colors.white.withOpacity(0.8)),
                const SizedBox(width: 6),
                Text(
                  'Tap to flip back',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.9)),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white.withOpacity(0.95),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String hindiTitle, String englishTitle, IconData icon, Widget content) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF138808), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hindiTitle,
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        englishTitle,
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildAboutContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBulletPoint(
          'प्रधानमंत्री फसल बीमा योजना (PMFBY) भारत सरकार की महत्वाकांक्षी योजना है।',
          'Pradhan Mantri Fasal Bima Yojana (PMFBY) is an ambitious scheme by the Government of India.',
        ),
        const SizedBox(height: 12),
        _buildBulletPoint(
          'इसका उद्देश्य किसानों को प्राकृतिक आपदाओं से सुरक्षा प्रदान करना है।',
          'It aims to provide protection to farmers against natural calamities.',
        ),
        const SizedBox(height: 12),
        _buildBulletPoint(
          'वर्ष 2016 में शुरू की गई यह योजना सभी राज्यों में लागू है।',
          'Launched in 2016, this scheme is implemented in all states.',
        ),
      ],
    );
  }

  Widget _buildFeaturesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeature('✓', 'सभी खाद्य और तिलहन फसलों के लिए बीमा', 'Insurance for all food and oilseed crops'),
        _buildFeature('✓', 'बुवाई से कटाई तक सुरक्षा', 'Protection from sowing to harvesting'),
        _buildFeature('✓', 'कम प्रीमियम, अधिकतम कवर', 'Low premium, maximum cover'),
        _buildFeature('✓', 'तकनीकी आधारित दावा निपटान', 'Technology-based claim settlement'),
        _buildFeature('✓', 'स्मार्टफोन से दावा दर्ज करें', 'File claims via smartphone'),
      ],
    );
  }

  Widget _buildPremiumContent() {
    return Column(
      children: [
        _buildPremiumRow('खरीफ फसलें / Kharif', '2%', 'धान, कपास, सोयाबीन'),
        const Divider(),
        _buildPremiumRow('रबी फसलें / Rabi', '1.5%', 'गेहूं, चना, सरसों'),
        const Divider(),
        _buildPremiumRow('बागवानी / Horticulture', '5%', 'फल, सब्जियां'),
      ],
    );
  }

  Widget _buildHelplineContent() {
    return Column(
      children: [
        _buildHelplineRow('राष्ट्रीय हेल्पलाइन', 'National Helpline', '📞 18001801551', true, false),
        const SizedBox(height: 12),
        _buildHelplineRow('किसान कॉल सेंटर', 'Kisan Call Center', '📞 18001801551', true, false),
        const SizedBox(height: 12),
        _buildHelplineRow('ईमेल सहायता', 'Email Support', '📧 pmfby-dac@gov.in', false, true),
      ],
    );
  }

  Widget _buildMinistryContact() {
    return Column(
      children: [
        _buildHelplineRow('कृषि भवन हेल्पलाइन', 'Krishi Bhavan Helpline', '📞 01123382012', true, false),
        const SizedBox(height: 12),
        _buildHelplineRow('कृषि मंत्री कार्यालय', 'Agriculture Minister Office', '📞 01123070004', true, false),
        const SizedBox(height: 12),
        _buildHelplineRow('ईमेल संपर्क', 'Email Contact', '📧 agricoop@nic.in', false, true),
        const SizedBox(height: 12),
        _buildHelplineRow('वेबसाइट', 'Ministry Website', '🌐 agricoop.nic.in', false, false),
      ],
    );
  }

  Widget _buildLinksContent() {
    return Column(
      children: [
        _buildLinkButton('PMFBY पोर्टल', 'https://pmfby.gov.in', Icons.language),
        const SizedBox(height: 8),
        _buildLinkButton('किसान मोबाइल ऐप', 'https://play.google.com/store/apps/details?id=in.nic.pmfby.mobile', Icons.android),
        const SizedBox(height: 8),
        _buildLinkButton('कृषि मंत्रालय', 'https://agricoop.nic.in', Icons.account_balance),
      ],
    );
  }

  Widget _buildBulletPoint(String hindi, String english) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hindi,
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          english,
          style: GoogleFonts.notoSans(
            fontSize: 13,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFeature(String bullet, String hindi, String english) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bullet,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF138808),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hindi,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  english,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
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

  Widget _buildPremiumRow(String crop, String rate, String examples) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  examples,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF138808).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              rate,
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF138808),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelplineRow(String hindiLabel, String englishLabel, String contact, bool isPhone, bool isEmail) {
    return InkWell(
      onTap: () async {
        try {
          if (isPhone) {
            final cleanNumber = contact.replaceAll(RegExp(r'[^\d]'), '');
            final uri = Uri.parse('tel:$cleanNumber');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          } else if (isEmail) {
            final emailAddress = contact.replaceAll(RegExp(r'[^\w@.\-]'), '');
            final uri = Uri.parse('mailto:$emailAddress');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          } else {
            // Website or other link
            final cleanUrl = contact.replaceAll(RegExp(r'[^\w.:/\-]'), '');
            final uri = Uri.parse(cleanUrl.startsWith('http') ? cleanUrl : 'https://$cleanUrl');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'लिंक खोलने में समस्या / Error opening link',
                  style: GoogleFonts.notoSansDevanagari(),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hindiLabel,
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    englishLabel,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              contact,
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkButton(String label, String url, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'लिंक खोलने में असमर्थ / Unable to open link',
                  style: GoogleFonts.notoSansDevanagari(),
                ),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        }
      },
      icon: Icon(icon),
      label: Text(
        label,
        style: GoogleFonts.notoSansDevanagari(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF138808),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

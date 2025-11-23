import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../services/firebase_auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../models/insurance_claim.dart';

class FileClaimScreen extends StatefulWidget {
  const FileClaimScreen({super.key});

  @override
  State<FileClaimScreen> createState() => _FileClaimScreenState();
}

class _FileClaimScreenState extends State<FileClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cropController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedLossController = TextEditingController();

  String _selectedDamageReason = 'बाढ़ (Flood)';
  DateTime _incidentDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _damageReasons = [
    'बाढ़ (Flood)',
    'सूखा (Drought)',
    'कीट/रोग (Pest/Disease)',
    'ओलावृष्टि (Hailstorm)',
    'तूफान (Storm)',
    'अन्य (Other)',
  ];

  @override
  void dispose() {
    _cropController.dispose();
    _descriptionController.dispose();
    _estimatedLossController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _incidentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _incidentDate) {
      setState(() => _incidentDate = picked);
    }
  }

  Future<void> _submitClaim() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = context.read<FirebaseAuthService>();
      final firestoreService = FirestoreService();

      if (authService.currentUser == null) {
        _showError('कृपया पहले लॉगिन करें (Please login first)');
        return;
      }

      final claim = InsuranceClaim(
        id: const Uuid().v4(),
        farmerId: authService.currentUser!.uid,
        farmerName: 'Anshika', // In real app, get from user profile
        cropType: _cropController.text,
        damageReason: _selectedDamageReason,
        description: _descriptionController.text,
        estimatedLossPercentage: double.tryParse(_estimatedLossController.text),
        status: ClaimStatus.submitted,
        incidentDate: _incidentDate,
      );

      await firestoreService.submitClaim(claim);

      if (mounted) {
        _showSuccess('दावा सफलतापूर्वक दर्ज किया गया! (Claim submitted successfully!)');
        await Future.delayed(const Duration(seconds: 1));
        context.pop();
      }
    } catch (e) {
      _showError('त्रुटि: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'नया दावा दर्ज करें',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'कृपया सभी जानकारी सही-सही भरें\nPlease fill all details correctly',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Crop Type
              Text(
                'फसल का नाम (Crop Name) *',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cropController,
                decoration: InputDecoration(
                  hintText: 'जैसे: धान, गेहूं, गन्ना (e.g., Rice, Wheat)',
                  prefixIcon: const Icon(Icons.grass),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'कृपया फसल का नाम दर्ज करें';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Damage Reason
              Text(
                'नुकसान का कारण (Damage Reason) *',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDamageReason,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    items: _damageReasons.map((String reason) {
                      return DropdownMenuItem<String>(
                        value: reason,
                        child: Text(reason),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() => _selectedDamageReason = newValue);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Incident Date
              Text(
                'घटना की तारीख (Incident Date) *',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd MMMM yyyy').format(_incidentDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Estimated Loss
              Text(
                'अनुमानित नुकसान % (Estimated Loss %)',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _estimatedLossController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'जैसे: 50 (50% नुकसान)',
                  prefixIcon: const Icon(Icons.percent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final number = double.tryParse(value);
                    if (number == null || number < 0 || number > 100) {
                      return 'कृपया 0-100 के बीच संख्या दर्ज करें';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description
              Text(
                'विवरण (Description) *',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'नुकसान का विस्तृत विवरण दें...\nProvide detailed description of damage...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'कृपया विवरण दर्ज करें';
                  }
                  if (value.length < 20) {
                    return 'कृपया कम से कम 20 अक्षर दर्ज करें';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Photo Upload Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.add_a_photo, color: Colors.green.shade700, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      'फोटो सबूत जोड़ें (Add Photo Evidence)',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/capture-image'),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('फोटो लें (Take Photo)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitClaim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'दावा जमा करें (Submit Claim)',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Help Text
              Text(
                '⚠️ दावा जमा करने के बाद, आपको 7-15 दिनों में प्रतिक्रिया मिलेगी\n'
                'After submitting, you will receive response in 7-15 days',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

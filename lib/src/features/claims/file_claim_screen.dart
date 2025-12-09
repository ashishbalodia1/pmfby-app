import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/cloud_image_service.dart';
import '../../repositories/claim_repository.dart';
import '../../models/mongodb/claim_model.dart';
import '../../providers/language_provider.dart';
import '../../localization/app_localizations.dart';

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
  final _claimRepository = ClaimRepository();
  final _cloudImageService = CloudImageService();
  final _imagePicker = ImagePicker();

  String _selectedDamageReason = 'बाढ़ (Flood)';
  DateTime _incidentDate = DateTime.now();
  bool _isLoading = false;
  List<File> _selectedImages = [];
  List<String> _uploadedImageUrls = [];

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

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages = pickedFiles.map((xFile) => File(xFile.path)).toList();
        });
      }
    } catch (e) {
      _showError('Error picking images: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      _showError('Error taking photo: $e');
    }
  }

  Future<void> _submitClaim() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      _showError('कृपया कम से कम एक फोटो जोड़ें (Please add at least one photo)');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = context.read<FirebaseAuthService>();

      if (authService.currentUser == null) {
        _showError('कृपया पहले लॉगिन करें (Please login first)');
        return;
      }

      final farmerId = authService.currentUser!.uid;

      // Step 1: Upload images to Cloudinary
      _uploadedImageUrls.clear();
      for (int i = 0; i < _selectedImages.length; i++) {
        try {
          final result = await _cloudImageService.uploadImage(
            _selectedImages[i],
            farmerId: farmerId,
            imageType: 'claim_evidence',
            metadata: {
              'crop': _cropController.text,
              'damage_reason': _selectedDamageReason,
              'incident_date': _incidentDate.toIso8601String(),
            },
          );
          _uploadedImageUrls.add(result.url);
        } catch (e) {
          debugPrint('Error uploading image ${i + 1}: $e');
        }
      }

      if (_uploadedImageUrls.isEmpty) {
        _showError('फोटो अपलोड में विफल (Failed to upload photos)');
        return;
      }

      // Step 2: Create claim model with uploaded image URLs
      final claimId = 'CLM${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();
      
      final estimatedLoss = double.tryParse(_estimatedLossController.text) ?? 0.0;

      final claim = ClaimModel(
        claimId: claimId,
        farmerId: farmerId,
        parcelId: 'PARCEL_${farmerId}_${now.year}', // Generate or link to actual parcel
        season: _getCurrentSeason(),
        submission: ClaimSubmission(
          images: _uploadedImageUrls, // Cloudinary URLs stored here
          submittedAt: now,
          submittedBy: 'farmer',
        ),
        aiAssessment: AIAssessment(
          lossPct: estimatedLoss,
          severity: _getSeverity(estimatedLoss),
          cropType: _cropController.text,
          finalDecision: estimatedLoss > 50 ? 'needs-review' : 'auto-eligible',
          reasons: [_selectedDamageReason, _descriptionController.text],
        ),
        humanReview: HumanReview(
          required: estimatedLoss > 50,
        ),
        status: 'PENDING',
        createdAt: now,
        updatedAt: now,
      );

      // Step 3: Save to MongoDB
      await _claimRepository.createClaim(claim);

      if (mounted) {
        _showSuccess('दावा सफलतापूर्वक दर्ज किया गया! (Claim submitted successfully!)');
        await Future.delayed(const Duration(seconds: 1));
        context.pop();
      }
    } catch (e) {
      _showError('त्रुटि: $e');
      debugPrint('Claim submission error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 4 && month <= 9) {
      return 'Kharif ${DateTime.now().year}';
    } else {
      return 'Rabi ${DateTime.now().year}';
    }
  }

  String _getSeverity(double lossPct) {
    if (lossPct < 30) return 'low';
    if (lossPct < 60) return 'moderate';
    return 'severe';
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
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final lang = languageProvider.currentLanguage;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppStrings.get('claims', 'file_new_claim', lang),
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
                        AppStrings.get('claims', 'fill_details_correctly', lang),
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
                AppStrings.get('claims', 'crop_name', lang),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cropController,
                decoration: InputDecoration(
                  hintText: AppStrings.get('claims', 'crop_name_hint', lang),
                  prefixIcon: const Icon(Icons.grass),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.get('claims', 'enter_crop_name', lang);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Damage Reason
              Text(
                AppStrings.get('claims', 'damage_reason', lang),
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
                AppStrings.get('claims', 'incident_date', lang),
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
                AppStrings.get('claims', 'estimated_loss', lang),
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
                  hintText: AppStrings.get('claims', 'estimated_loss_hint', lang),
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
                      return AppStrings.get('claims', 'enter_valid_percentage', lang);
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description
              Text(
                AppStrings.get('claims', 'description', lang),
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
                  hintText: AppStrings.get('claims', 'description_hint', lang),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.get('claims', 'enter_description', lang);
                  }
                  if (value.length < 20) {
                    return AppStrings.get('claims', 'min_characters', lang);
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
                      AppStrings.get('claims', 'add_photo_evidence', lang),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _takePhoto,
                          icon: const Icon(Icons.camera_alt, size: 20),
                          label: const Text('Camera'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.photo_library, size: 20),
                          label: const Text('Gallery'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (_selectedImages.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        '${_selectedImages.length} photo(s) selected',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedImages[index],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedImages.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
                        AppStrings.get('claims', 'submit_claim', lang),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Help Text
              Text(
                AppStrings.get('claims', 'response_time_info', lang),
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
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../services/local_storage_service.dart';
import '../../services/connectivity_service.dart';
import '../../providers/language_provider.dart';
import '../../localization/app_localizations.dart';

class CaptureImageScreen extends StatefulWidget {
  const CaptureImageScreen({super.key});

  @override
  State<CaptureImageScreen> createState() => _CaptureImageScreenState();
}

class _CaptureImageScreenState extends State<CaptureImageScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  List<XFile> _multipleImages = [];
  Position? _position;
  String? _locationName;
  bool _isLoading = false;
  bool _locationFetched = false;
  String _captureMode = 'single'; // 'single', 'multiple', 'comparison'
  bool _showGrid = false;
  bool _flashEnabled = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _locationFetched = false;
    });

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Allow app to work without location
          if (mounted) {
            setState(() {
              _locationFetched = true;
              _isLoading = false;
              _locationName = 'Location permission denied';
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Allow app to work without location
        if (mounted) {
          setState(() {
            _locationFetched = true;
            _isLoading = false;
            _locationName = 'Enable location in settings';
          });
        }
        return;
      }

      // Get current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      ).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          // Return a default position if timeout
          throw Exception('Location timeout');
        },
      );

      // Get location name from coordinates
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 3));

        if (mounted && placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          setState(() {
            _position = position;
            _locationName = '${place.locality ?? 'Unknown'}, ${place.administrativeArea ?? 'Unknown'}';
            _locationFetched = true;
            _isLoading = false;
          });
        }
      } catch (e) {
        // Use coordinates if geocoding fails
        if (mounted) {
          setState(() {
            _position = position;
            _locationName = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}';
            _locationFetched = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Allow app to work without location
      if (mounted) {
        setState(() {
          _locationFetched = true;
          _isLoading = false;
          _locationName = 'Location unavailable';
        });
      }
    } finally {
      // Ensure loading always stops
      if (mounted && _isLoading) {
        setState(() {
          _locationFetched = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _captureImage(ImageSource source) async {
    try {
      if (_captureMode == 'comparison') {
        // Comparison mode - capture before and after
        if (_multipleImages.length < 2) {
          final String promptText = _multipleImages.isEmpty 
            ? 'पहली फोटो लें (नुकसान से पहले)'
            : 'दूसरी फोटो लें (नुकसान के बाद)';
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(promptText, style: GoogleFonts.notoSansDevanagari()),
                backgroundColor: Colors.blue.shade700,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          
          final XFile? image = await _picker.pickImage(
            source: source,
            maxWidth: 1920,
            maxHeight: 1080,
            imageQuality: 85,
            preferredCameraDevice: CameraDevice.rear,
          );
          
          if (image != null) {
            setState(() {
              _multipleImages.add(image);
              _image = image;
            });
          }
        } else {
          if (mounted) {
            _showError('तुलना के लिए केवल 2 फोटो लें');
          }
        }
      } else if (_captureMode == 'multiple') {
        // Multiple images mode
        final List<XFile> images = await _picker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        if (images.isNotEmpty) {
          setState(() {
            _multipleImages.addAll(images);
            if (_multipleImages.isNotEmpty) {
              _image = _multipleImages.first;
            }
          });
        }
      } else {
        // Single image capture with flash support
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
          preferredCameraDevice: CameraDevice.rear,
        );
        if (image != null) {
          setState(() => _image = image);
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('फोटो लेने में त्रुटि: $e');
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      _showError('कृपया पहले फोटो लें (Please capture image first)');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final localStorageService = LocalStorageService();
      final connectivityService = context.read<ConnectivityService>();
      
      // Show crop type selection dialog
      final cropType = await _showCropTypeDialog();
      if (cropType == null || !mounted) {
        setState(() => _isLoading = false);
        return;
      }

      // Save image locally
      final uploadId = DateTime.now().millisecondsSinceEpoch.toString();
      final savedImagePath = await localStorageService.saveImageLocally(File(_image!.path), uploadId);
      
      // Create pending upload (with or without location)
      final upload = PendingUpload(
        id: uploadId,
        imagePath: savedImagePath,
        cropType: cropType,
        description: _locationName ?? 'Location unavailable',
        latitude: _position?.latitude ?? 0.0,
        longitude: _position?.longitude ?? 0.0,
        capturedAt: DateTime.now(),
        status: SyncStatus.pending,
      );

      await localStorageService.savePendingUpload(upload);

      if (mounted) {
        if (connectivityService.isOnline) {
          _showSuccess(_t('saved_syncing'));
        } else {
          _showSuccess(_t('saved_offline'));
        }
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> _showCropTypeDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _t('select_crop'),
          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'गेहूं (Wheat)',
            'धान (Rice)',
            'मक्का (Maize)',
            'बाजरा (Millet)',
            'दालें (Pulses)',
            'सोयाबीन (Soybean)',
            'कपास (Cotton)',
            'गन्ना (Sugarcane)',
            'अन्य (Other)',
          ].map((crop) => ListTile(
            title: Text(crop, style: GoogleFonts.notoSans()),
            onTap: () => Navigator.pop(context, crop.split(' ')[0]),
          )).toList(),
        ),
      ),
    );
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

  String _t(String key) {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final translations = {
      'title': {'en': 'Capture Crop Photo', 'hi': 'फसल की फोटो लें'},
      'getting_location': {'en': 'Getting location...', 'hi': 'स्थान प्राप्त कर रहे हैं...'},
      'location': {'en': 'Location', 'hi': 'स्थान'},
      'location_unavailable': {'en': 'Location unavailable', 'hi': 'स्थान उपलब्ध नहीं'},
      'capture_photo': {'en': 'Capture Photo', 'hi': 'फोटो खींचें'},
      'show_clearly': {'en': 'Show crop clearly', 'hi': 'फसल को स्पष्ट रूप से दिखाएं'},
      'include_plant': {'en': 'Include whole plant', 'hi': 'पूरे पौधे को शामिल करें'},
      'good_light': {'en': 'Good lighting', 'hi': 'अच्छी रोशनी में फोटो लें'},
      'remove': {'en': 'Remove', 'hi': 'हटाएं'},
      'take_photo': {'en': 'Take Photo', 'hi': 'कैमरा से फोटो लें'},
      'choose_gallery': {'en': 'Choose from Gallery', 'hi': 'गैलरी से चुनें'},
      'upload': {'en': 'Upload', 'hi': 'अपलोड करें'},
      'uploading': {'en': 'Uploading...', 'hi': 'अपलोड हो रहा है...'},
      'important': {'en': 'Important Instructions', 'hi': 'महत्वपूर्ण निर्देश'},
      'capture_first': {'en': 'Please capture image first', 'hi': 'कृपया पहले फोटो लें'},
      'saved_syncing': {'en': 'Image saved and syncing!', 'hi': 'फोटो सेव हुई और सिंक हो रही है!'},
      'saved_offline': {'en': 'Image saved! Will sync when online', 'hi': 'फोटो सेव हुई! ऑनलाइन होने पर सिंक होगी'},
      'select_crop': {'en': 'Select Crop Type', 'hi': 'फसल का प्रकार चुनें'},
    };
    return translations[key]?[lang] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _t('title'),
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading && !_locationFetched
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_t('getting_location')),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Location Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Text(
                                  _t('location'),
                                  style: GoogleFonts.notoSans(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  _locationName ?? _t('getting_location'),
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _getCurrentLocation,
                              color: Colors.green.shade700,
                            ),
                          ],
                        ),
                        if (_position != null) ...[
                          const Divider(),
                          Text(
                            'GPS: ${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Capture Mode Selector
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildModeChip('single', 'सिंगल', Icons.camera_alt),
                        const SizedBox(width: 8),
                        _buildModeChip('multiple', 'मल्टीपल', Icons.photo_library),
                        const SizedBox(width: 8),
                        _buildModeChip('comparison', 'तुलना', Icons.compare),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grid & Flash Toggle Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _showGrid = !_showGrid);
                        },
                        icon: Icon(_showGrid ? Icons.grid_on : Icons.grid_off),
                        label: Text(_showGrid ? 'ग्रिड चालू' : 'ग्रिड बंद'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showGrid ? Colors.green : Colors.grey.shade300,
                          foregroundColor: _showGrid ? Colors.white : Colors.black87,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _flashEnabled = !_flashEnabled);
                        },
                        icon: Icon(_flashEnabled ? Icons.flash_on : Icons.flash_off),
                        label: Text(_flashEnabled ? 'फ्लैश चालू' : 'फ्लैश बंद'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _flashEnabled ? Colors.amber : Colors.grey.shade300,
                          foregroundColor: _flashEnabled ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Image Preview or Capture Instructions
                  if (_image == null)
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          style: BorderStyle.solid,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _t('capture_photo'),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              '📸 फसल को स्पष्ट रूप से दिखाएं\n🌾 पूरे पौधे को शामिल करें\n☀️ अच्छी रोशनी में फोटो लें',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_captureMode == 'comparison' && _multipleImages.length == 2)
                    // Show before and after comparison
                    Column(
                      children: [
                        Container(
                          height: 300,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      'पहले',
                                      style: GoogleFonts.notoSansDevanagari(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.blue.shade300, width: 3),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.file(
                                            File(_multipleImages[0].path),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      'बाद में',
                                      style: GoogleFonts.notoSansDevanagari(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.red.shade300, width: 3),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.file(
                                            File(_multipleImages[1].path),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => setState(() {
                            _multipleImages.clear();
                            _image = null;
                          }),
                          icon: const Icon(Icons.delete),
                          label: Text('दोनों हटाएं'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade300, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  File(_image!.path),
                                  fit: BoxFit.cover,
                                ),
                                // Grid overlay when enabled
                                if (_showGrid)
                                  CustomPaint(
                                    painter: GridPainter(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => setState(() {
                                  _image = null;
                                  _multipleImages.clear();
                                }),
                                icon: const Icon(Icons.delete),
                                label: Text(_t('remove')),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // Capture Buttons
                  if (_image == null) ...[
                    ElevatedButton.icon(
                      onPressed: () => _captureImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: Text(
                        _t('take_photo'),
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _captureImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: Text(
                        _t('choose_gallery'),
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green.shade700,
                        side: BorderSide(color: Colors.green.shade700),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _uploadImage,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.cloud_upload),
                      label: Text(
                        _isLoading ? _t('uploading') : _t('upload'),
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Photography Tips
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade50, Colors.green.shade100],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tips_and_updates, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'फोटो लेने के टिप्स',
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTip('📸', 'फसल को स्पष्ट रूप से केंद्र में रखें'),
                        _buildTip('☀️', 'अच्छी रोशनी में फोटो लें (सुबह या शाम)'),
                        _buildTip('📏', 'फसल के पास जाएं, पूरा पौधा दिखाएं'),
                        _buildTip('🎯', 'नुकसान वाले हिस्से को फोकस करें'),
                        _buildTip('📊', 'मल्टीपल मोड से कई कोण से फोटो लें'),
                        _buildTip('⚖️', 'तुलना मोड से पहले और बाद की तस्वीर'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              _t('important'),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• AI आपकी फसल का स्वचालित विश्लेषण करेगा\n'
                          '• नुकसान का पता लगाया जाएगा\n'
                          '• GPS स्थान स्वतः सहेजा जाएगा\n'
                          '• फोटो सुरक्षित रूप से संग्रहीत की जाएगी',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade900,
                            height: 1.6,
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

  Widget _buildModeChip(String mode, String label, IconData icon) {
    final isSelected = _captureMode == mode;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.green.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.notoSansDevanagari(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.green.shade700,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _captureMode = mode);
        }
      },
      selectedColor: Colors.green.shade600,
      backgroundColor: Colors.green.shade50,
      side: BorderSide(
        color: isSelected ? Colors.green.shade600 : Colors.green.shade300,
        width: 2,
      ),
    );
  }

  Widget _buildTip(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 13,
                color: Colors.green.shade900,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Grid Painter for camera guidance overlay
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw vertical lines (rule of thirds)
    final double verticalSpacing = size.width / 3;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(verticalSpacing * i, 0),
        Offset(verticalSpacing * i, size.height),
        paint,
      );
    }

    // Draw horizontal lines (rule of thirds)
    final double horizontalSpacing = size.height / 3;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(0, horizontalSpacing * i),
        Offset(size.width, horizontalSpacing * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

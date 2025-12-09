import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import '../models/ar_camera_models.dart';

/// Service for analyzing image quality in real-time
/// Implements blur detection, exposure analysis, and backlight detection
class ImageQualityAnalyzer {
  // Thresholds
  static const double blurThreshold = 100.0;
  static const double lowLightThreshold = 50.0;
  static const double highLightThreshold = 200.0;
  static const double backlightRatioThreshold = 2.0;

  // Singleton
  static final ImageQualityAnalyzer _instance = ImageQualityAnalyzer._internal();
  factory ImageQualityAnalyzer() => _instance;
  ImageQualityAnalyzer._internal();

  // Last analysis result for caching
  ImageQualityResult? _lastResult;
  DateTime? _lastAnalysisTime;
  static const Duration _analysisInterval = Duration(milliseconds: 200);

  /// Analyze camera image for quality
  /// Returns cached result if called too frequently
  Future<ImageQualityResult> analyzeImage(CameraImage image) async {
    // Rate limiting
    if (_lastResult != null && _lastAnalysisTime != null) {
      if (DateTime.now().difference(_lastAnalysisTime!) < _analysisInterval) {
        return _lastResult!;
      }
    }

    try {
      // Convert to grayscale for analysis
      final grayscale = _convertToGrayscale(image);
      
      // Calculate metrics
      final blurScore = _calculateBlurScore(grayscale, image.width, image.height);
      final exposureMetrics = _calculateExposureMetrics(grayscale);
      final hasBacklight = _detectBacklight(grayscale, image.width, image.height);

      _lastResult = ImageQualityResult.analyze(
        blurScore: blurScore,
        exposureScore: exposureMetrics['exposure']!,
        brightnessScore: exposureMetrics['brightness']!,
        hasBacklight: hasBacklight,
      );
      _lastAnalysisTime = DateTime.now();

      return _lastResult!;
    } catch (e) {
      debugPrint('Image quality analysis error: $e');
      return const ImageQualityResult(
        blurScore: 50,
        exposureScore: 50,
        brightnessScore: 50,
        hasBacklight: false,
        overallStatus: QualityStatus.good,
        warnings: [],
      );
    }
  }

  /// Convert CameraImage to grayscale byte array
  Uint8List _convertToGrayscale(CameraImage image) {
    // For YUV420 format (most common on Android)
    if (image.format.group == ImageFormatGroup.yuv420) {
      // Y plane is already grayscale
      return image.planes[0].bytes;
    }
    
    // For BGRA8888 format (iOS)
    if (image.format.group == ImageFormatGroup.bgra8888) {
      final bytes = image.planes[0].bytes;
      final grayscale = Uint8List(image.width * image.height);
      
      for (int i = 0; i < grayscale.length; i++) {
        final pixelIndex = i * 4;
        if (pixelIndex + 2 < bytes.length) {
          final b = bytes[pixelIndex];
          final g = bytes[pixelIndex + 1];
          final r = bytes[pixelIndex + 2];
          // Luminance formula
          grayscale[i] = ((0.299 * r) + (0.587 * g) + (0.114 * b)).round().clamp(0, 255);
        }
      }
      return grayscale;
    }

    // Fallback - return Y plane or first plane
    return image.planes[0].bytes;
  }

  /// Calculate blur score using Laplacian variance
  /// Higher score = sharper image
  /// Uses optimized sampling to prevent frame blocking
  double _calculateBlurScore(Uint8List grayscale, int width, int height) {
    // Adaptive sampling based on image size for performance
    // Larger images need less dense sampling
    final totalPixels = width * height;
    final sampleStep = totalPixels > 1000000 ? 8 : (totalPixels > 500000 ? 6 : 4);
    
    double variance = 0;
    int count = 0;
    
    // Sample center region more (where subject usually is)
    final startY = height ~/ 4;
    final endY = (height * 3) ~/ 4;
    final startX = width ~/ 4;
    final endX = (width * 3) ~/ 4;

    // Laplacian kernel: [0, 1, 0], [1, -4, 1], [0, 1, 0]
    // This detects edges - high variance = sharp, low variance = blurry
    for (int y = math.max(1, startY); y < math.min(height - 1, endY); y += sampleStep) {
      for (int x = math.max(1, startX); x < math.min(width - 1, endX); x += sampleStep) {
        final idx = y * width + x;
        
        // Bounds check (paranoid safety)
        if (idx >= grayscale.length || 
            idx - width < 0 ||
            idx + width >= grayscale.length) {
          continue;
        }
        
        // Apply Laplacian operator
        final center = grayscale[idx];
        final left = grayscale[idx - 1];
        final right = grayscale[idx + 1];
        final top = grayscale[idx - width];
        final bottom = grayscale[idx + width];
        
        final laplacian = -4 * center + left + right + top + bottom;
        
        variance += laplacian * laplacian;
        count++;
      }
    }

    if (count == 0) return 50; // Safe fallback

    // Normalize variance to 0-100 score
    final normalizedVariance = variance / count;
    
    // Map to score: higher variance = sharper
    // Scale factor tuned for typical mobile cameras
    // Variance > 500 = sharp, < 100 = blurry
    final score = math.min(100.0, (normalizedVariance / 5).clamp(0.0, 100.0));
    
    return score.toDouble();
  }

  /// Calculate exposure and brightness metrics
  Map<String, double> _calculateExposureMetrics(Uint8List grayscale) {
    // Build histogram
    final histogram = List<int>.filled(256, 0);
    for (final pixel in grayscale) {
      histogram[pixel]++;
    }

    // Calculate mean brightness
    double sum = 0;
    for (int i = 0; i < 256; i++) {
      sum += i * histogram[i];
    }
    final meanBrightness = sum / grayscale.length;

    // Calculate standard deviation for contrast
    double varianceSum = 0;
    for (int i = 0; i < 256; i++) {
      varianceSum += histogram[i] * math.pow(i - meanBrightness, 2);
    }
    final stdDev = math.sqrt(varianceSum / grayscale.length);

    // Calculate exposure score (50 is ideal)
    // Too dark (< 50) or too bright (> 200) is bad
    double exposureScore;
    if (meanBrightness < 50) {
      exposureScore = (meanBrightness / 50) * 50;  // 0-50 maps to 0-50
    } else if (meanBrightness > 200) {
      exposureScore = 50 + ((255 - meanBrightness) / 55) * 50;  // 200-255 maps to 50-0
    } else {
      // Good range: 50-200
      exposureScore = 50 + (1 - (meanBrightness - 125).abs() / 75) * 50;
    }

    // Brightness score (simple percentage)
    final brightnessScore = (meanBrightness / 255) * 100;

    return {
      'exposure': exposureScore.clamp(0, 100),
      'brightness': brightnessScore.clamp(0, 100),
      'contrast': (stdDev / 128 * 100).clamp(0, 100),
    };
  }

  /// Detect backlight by comparing center vs edges brightness
  bool _detectBacklight(Uint8List grayscale, int width, int height) {
    // Calculate center region brightness
    final centerStartX = width ~/ 3;
    final centerEndX = (width * 2) ~/ 3;
    final centerStartY = height ~/ 3;
    final centerEndY = (height * 2) ~/ 3;

    double centerSum = 0;
    int centerCount = 0;
    double edgeSum = 0;
    int edgeCount = 0;

    for (int y = 0; y < height; y += 4) {
      for (int x = 0; x < width; x += 4) {
        final idx = y * width + x;
        if (idx >= grayscale.length) continue;

        final pixel = grayscale[idx];

        if (x >= centerStartX && x < centerEndX &&
            y >= centerStartY && y < centerEndY) {
          centerSum += pixel;
          centerCount++;
        } else {
          edgeSum += pixel;
          edgeCount++;
        }
      }
    }

    if (centerCount == 0 || edgeCount == 0) return false;

    final centerBrightness = centerSum / centerCount;
    final edgeBrightness = edgeSum / edgeCount;

    // Backlight: edges are much brighter than center (subject is dark silhouette)
    if (edgeBrightness > 150 && centerBrightness < 100) {
      return edgeBrightness / centerBrightness > backlightRatioThreshold;
    }

    return false;
  }

  /// Quick check for motion blur by comparing consecutive frames
  /// Returns stability score 0-100
  double checkStability(
    Uint8List currentFrame,
    Uint8List? previousFrame,
    int width,
    int height,
  ) {
    if (previousFrame == null) return 100;
    if (currentFrame.length != previousFrame.length) return 100;

    // Sample and compare
    double diffSum = 0;
    const sampleStep = 8;
    int count = 0;

    for (int i = 0; i < currentFrame.length; i += sampleStep) {
      diffSum += (currentFrame[i] - previousFrame[i]).abs();
      count++;
    }

    if (count == 0) return 100;

    final avgDiff = diffSum / count;
    
    // Map difference to stability score
    // Low difference = high stability
    final stability = math.max(0.0, 100.0 - (avgDiff * 2));
    
    return stability.toDouble();
  }

  /// Analyze a saved image file for quality (post-capture verification)
  Future<ImageQualityResult> analyzeImageFile(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found');
      }
      
      // Read image bytes
      final bytes = await file.readAsBytes();
      
      // Decode image to get pixels
      final codec = await instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      // Convert to grayscale for analysis
      final byteData = await image.toByteData(format: ImageByteFormat.rawRgba);
      if (byteData == null) {
        throw Exception('Failed to get image data');
      }
      
      final pixels = byteData.buffer.asUint8List();
      final grayscale = Uint8List(image.width * image.height);
      
      // Convert RGBA to grayscale
      for (int i = 0; i < grayscale.length; i++) {
        final pixelIndex = i * 4;
        if (pixelIndex + 2 < pixels.length) {
          final r = pixels[pixelIndex];
          final g = pixels[pixelIndex + 1];
          final b = pixels[pixelIndex + 2];
          // Luminance formula
          grayscale[i] = ((0.299 * r) + (0.587 * g) + (0.114 * b)).round().clamp(0, 255);
        }
      }
      
      // Analyze quality
      final blurScore = _calculateBlurScore(grayscale, image.width, image.height);
      final exposureMetrics = _calculateExposureMetrics(grayscale);
      final hasBacklight = _detectBacklight(grayscale, image.width, image.height);
      
      return ImageQualityResult.analyze(
        blurScore: blurScore,
        exposureScore: exposureMetrics['exposure']!,
        brightnessScore: exposureMetrics['brightness']!,
        hasBacklight: hasBacklight,
      );
    } catch (e) {
      debugPrint('Error analyzing image file: $e');
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    reset();
  }

  /// Reset cached results
  void reset() {
    _lastResult = null;
    _lastAnalysisTime = null;
  }
}

/// Stability tracker for detecting camera shake
class StabilityTracker {
  static const int bufferSize = 10;
  static const double stabilityThreshold = 80;
  
  final List<double> _accelerometerBuffer = [];
  final List<double> _gyroscopeBuffer = [];
  
  bool _isStable = false;
  DateTime? _stableStartTime;
  static const Duration requiredStableDuration = Duration(milliseconds: 500);

  /// Add accelerometer sample (x, y, z)
  void addSample(double x, double y, double z) {
    final magnitude = math.sqrt(x * x + y * y + z * z);
    updateSensorData(accelerometerMagnitude: magnitude);
  }

  /// Update with new sensor readings
  void updateSensorData({
    required double accelerometerMagnitude,
    double? gyroscopeMagnitude,
  }) {
    // Add to buffer
    _accelerometerBuffer.add(accelerometerMagnitude);
    if (_accelerometerBuffer.length > bufferSize) {
      _accelerometerBuffer.removeAt(0);
    }

    if (gyroscopeMagnitude != null) {
      _gyroscopeBuffer.add(gyroscopeMagnitude);
      if (_gyroscopeBuffer.length > bufferSize) {
        _gyroscopeBuffer.removeAt(0);
      }
    }
  }

  /// Check if camera is stable
  bool get isStable {
    if (_accelerometerBuffer.length < bufferSize ~/ 2) return false;

    // Calculate variance of accelerometer readings
    final mean = _accelerometerBuffer.reduce((a, b) => a + b) / _accelerometerBuffer.length;
    final variance = _accelerometerBuffer
        .map((x) => math.pow(x - mean, 2))
        .reduce((a, b) => a + b) / _accelerometerBuffer.length;

    // Low variance = stable
    final isCurrentlyStable = variance < 0.5;

    if (isCurrentlyStable) {
      _stableStartTime ??= DateTime.now();
      _isStable = DateTime.now().difference(_stableStartTime!) >= requiredStableDuration;
    } else {
      _stableStartTime = null;
      _isStable = false;
    }

    return _isStable;
  }

  /// Get stability percentage
  double get stabilityPercentage {
    if (_accelerometerBuffer.isEmpty) return 0;

    final mean = _accelerometerBuffer.reduce((a, b) => a + b) / _accelerometerBuffer.length;
    final variance = _accelerometerBuffer
        .map((x) => math.pow(x - mean, 2))
        .reduce((a, b) => a + b) / _accelerometerBuffer.length;

    // Map variance to percentage (inverse relationship)
    return math.max(0, math.min(100, 100 - (variance * 50)));
  }

  /// Reset tracker
  void reset() {
    _accelerometerBuffer.clear();
    _gyroscopeBuffer.clear();
    _isStable = false;
    _stableStartTime = null;
  }

  /// Dispose (alias for reset for consistency)
  void dispose() => reset();
}

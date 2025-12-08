# Quick API Reference - MongoDB Repositories

## 🌾 Crop Image Repository

### Upload & Create
```dart
import 'package:your_app/src/repositories/crop_image_repository.dart';
import 'package:your_app/src/services/cloud_image_service.dart';

final repo = CropImageRepository();
final imageService = CloudImageService();

// Upload image to cloud
final uploadResult = await imageService.uploadImage(
  imageFile,
  farmerId: 'F001',
  imageType: 'cropHealth',
);

// Save to database
final cropImage = CropImageModel(
  imageId: 'IMG_${DateTime.now().millisecondsSinceEpoch}',
  farmerId: 'F001',
  parcelId: 'P001',
  imageUrl: uploadResult.url,
  thumbnailUrl: uploadResult.thumbnailUrl,
  // ... other fields
);

await repo.createCropImage(cropImage);
```

### Query Images
```dart
// Get farmer's images
final images = await repo.getFarmerImages('F001');

// Get by status
final pending = await repo.getImagesPendingOfficerReview(limit: 50);
final flagged = await repo.getFlaggedImages();

// Get parcel images
final parcelImages = await repo.getParcelImages(
  'F001', 
  'P001',
  season: 'Kharif',
  year: 2024,
);

// Get by date range
final recentImages = await repo.getImagesByDateRange(
  DateTime.now().subtract(Duration(days: 30)),
  DateTime.now(),
  farmerId: 'F001',
);

// Get statistics
final stats = await repo.getFarmerImageStats('F001');
// Returns: {'uploaded': 10, 'approved': 5, 'pending': 5}
```

### Update Images
```dart
// Update ML verification
await repo.updateMLVerification(imageId, mlVerification);

// Update officer verification
await repo.updateOfficerVerification(
  imageId, 
  officerVerification,
  ImageStatus.approved,
);

// Update status
await repo.updateImageStatus(imageId, ImageStatus.approved);

// Delete image
await repo.deleteCropImage(imageId);
```

---

## 🌪️ Crop Loss Repository

### Create Loss Report
```dart
import 'package:your_app/src/repositories/crop_loss_repository.dart';

final repo = CropLossRepository();

final cropLoss = CropLossModel(
  lossId: 'LOSS_${DateTime.now().millisecondsSinceEpoch}',
  farmerId: 'F001',
  parcelId: 'P001',
  lossDetails: LossDetails(
    cropName: 'Wheat',
    lossCause: LossCause.drought,
    estimatedLossPercentage: 60.0,
    affectedArea: 2.5,
    lossOccurredDate: DateTime.now(),
    farmerDescription: 'Severe drought damage',
    symptoms: ['Wilted crops', 'Brown leaves', 'No water'],
  ),
  imageIds: ['IMG_001', 'IMG_002'],
  location: GeoLocation(...),
  weatherCondition: WeatherCondition(...),
  season: 'Kharif',
  year: 2024,
  status: LossStatus.reported,
  reportedAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

await repo.createCropLoss(cropLoss);
```

### Query Loss Reports
```dart
// Get farmer's losses
final losses = await repo.getFarmerCropLosses('F001');

// Get by status
final pending = await repo.getCropLossesByStatus(
  LossStatus.reported,
  limit: 100,
);

// Get pending assessments (for officers)
final toAssess = await repo.getPendingAssessments(
  district: 'Ludhiana',
  limit: 50,
);

// Get by season
final kharifLosses = await repo.getCropLossesBySeason(
  'Kharif',
  2024,
  farmerId: 'F001',
);

// Get by date range
final recentLosses = await repo.getCropLossesByDateRange(
  DateTime(2024, 1, 1),
  DateTime(2024, 12, 31),
);

// Get statistics
final stats = await repo.getCropLossStats(
  season: 'Kharif',
  year: 2024,
);

// Get by loss cause
final byCause = await repo.getCropLossesByLossCause();
// Returns: {'drought': 10, 'flood': 5, 'pestAttack': 8}
```

### Update Loss Reports
```dart
// Add officer assessment
final assessment = OfficerAssessment(
  officerId: 'OFF001',
  officerName: 'Ram Kumar',
  assessedLossPercentage: 55.0,
  isEligibleForClaim: true,
  assessmentRemarks: 'Verified through field visit',
  verifiedImageIds: ['IMG_001', 'IMG_002'],
  assessedAt: DateTime.now(),
);

await repo.addOfficerAssessment(lossId, assessment);

// Update status
await repo.updateCropLossStatus(lossId, LossStatus.assessed);

// Add more images
await repo.addImagesToCropLoss(lossId, ['IMG_003', 'IMG_004']);

// Delete loss report
await repo.deleteCropLoss(lossId);
```

---

## 📸 Cloud Image Service

### Upload Image
```dart
import 'package:your_app/src/services/cloud_image_service.dart';

final service = CloudImageService();

// Upload with metadata
final result = await service.uploadImage(
  File('path/to/image.jpg'),
  farmerId: 'F001',
  imageType: 'cropDamage',
  metadata: {
    'season': 'Kharif',
    'year': 2024,
    'crop': 'Rice',
    'parcel': 'P001',
  },
);

print('URL: ${result.url}');
print('Thumbnail: ${result.thumbnailUrl}');
print('Size: ${result.bytes} bytes');
```

### Get Optimized URLs
```dart
// Get optimized image
final optimized = service.getOptimizedUrl(
  originalUrl,
  width: 800,
  height: 600,
  quality: 'auto',
  format: 'webp',
);

// Get thumbnail
final thumbnail = service.getOptimizedUrl(
  originalUrl,
  width: 300,
  height: 300,
  quality: '80',
);
```

### Delete Image
```dart
await service.deleteImage(publicId);
```

---

## 🔄 Common Patterns

### Complete Image Upload Flow
```dart
Future<void> uploadCropImageComplete(File imageFile) async {
  try {
    // 1. Show loading
    showLoading();
    
    // 2. Upload to cloud
    final uploadResult = await CloudImageService().uploadImage(
      imageFile,
      farmerId: currentUser.farmerId,
      imageType: 'cropHealth',
      metadata: {
        'location': '${currentPosition.latitude},${currentPosition.longitude}',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    
    // 3. Create model
    final cropImage = CropImageModel(
      imageId: generateImageId(),
      farmerId: currentUser.farmerId,
      parcelId: selectedParcel.id,
      metadata: ImageMetadata(
        width: uploadResult.width,
        height: uploadResult.height,
        format: uploadResult.format,
        sizeBytes: uploadResult.bytes,
        deviceModel: await getDeviceModel(),
        appVersion: '1.0.0',
      ),
      location: GeoLocation(
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
        accuracy: currentPosition.accuracy,
        timestamp: DateTime.now(),
      ),
      imageUrl: uploadResult.url,
      thumbnailUrl: uploadResult.thumbnailUrl,
      imageType: ImageType.cropHealth,
      cropInfo: CropInfo(
        cropName: selectedCrop.name,
        cropType: selectedCrop.type,
        sowingDate: sowingDate,
      ),
      season: currentSeason,
      year: DateTime.now().year,
      status: ImageStatus.pendingMLVerification,
      capturedAt: DateTime.now(),
      uploadedAt: DateTime.now(),
    );
    
    // 4. Save to database
    await CropImageRepository().createCropImage(cropImage);
    
    // 5. Trigger ML verification (async)
    triggerMLVerification(cropImage.imageId);
    
    // 6. Show success
    hideLoading();
    showSuccess('Image uploaded successfully!');
    
  } catch (e) {
    hideLoading();
    showError('Failed to upload image: $e');
  }
}
```

### Officer Review Flow
```dart
Future<void> reviewImage(String imageId, bool approve) async {
  final repo = CropImageRepository();
  
  // 1. Get image details
  final image = await repo.getCropImageById(imageId);
  if (image == null) return;
  
  // 2. Create verification
  final verification = OfficerVerification(
    officerId: currentOfficer.id,
    officerName: currentOfficer.name,
    decision: approve 
        ? VerificationDecision.approved 
        : VerificationDecision.rejected,
    remarks: reviewRemarks,
    flags: approve ? null : selectedFlags,
    verifiedAt: DateTime.now(),
  );
  
  // 3. Update in database
  final success = await repo.updateOfficerVerification(
    imageId,
    verification,
    approve ? ImageStatus.approved : ImageStatus.rejected,
  );
  
  if (success) {
    showSuccess('Review submitted');
    loadNextImage();
  }
}
```

### Dashboard Statistics
```dart
Future<Map<String, dynamic>> getDashboardStats(String farmerId) async {
  final imageRepo = CropImageRepository();
  final lossRepo = CropLossRepository();
  
  // Get image stats
  final imageStats = await imageRepo.getFarmerImageStats(farmerId);
  
  // Get loss stats
  final lossStats = await lossRepo.getCropLossStats(
    farmerId: farmerId,
    year: DateTime.now().year,
  );
  
  // Get recent images
  final recentImages = await imageRepo.getFarmerImages(farmerId);
  
  return {
    'totalImages': imageStats.values.fold<int>(0, (sum, count) => sum + count),
    'pendingVerification': imageStats['pendingOfficerReview'] ?? 0,
    'approved': imageStats['approved'] ?? 0,
    'totalLosses': lossStats['totalReports'] ?? 0,
    'pendingAssessment': (await lossRepo.getCropLossesByStatus(
      LossStatus.reported
    )).length,
    'recentImages': recentImages.take(5).toList(),
  };
}
```

---

## 🔍 Error Handling

### Repository Pattern
```dart
try {
  final result = await repo.createCropImage(image);
  // Success
} catch (e) {
  if (e.toString().contains('duplicate key')) {
    // Handle duplicate
  } else if (e.toString().contains('connection')) {
    // Handle connection error
  } else {
    // Handle other errors
  }
}
```

### Connection Check
```dart
final mongoService = MongoDBService.instance;
if (!mongoService.isConnected) {
  await mongoService.connect();
}
```

---

## 🚀 Performance Tips

1. **Use Pagination**
```dart
final images = await repo.getImagesByStatus(
  ImageStatus.pending,
  limit: 20, // Don't load all at once
);
```

2. **Use Indexes** (Already created automatically)
```dart
// Fast queries on indexed fields:
- farmerId
- parcelId
- status
- season + year
```

3. **Cache Frequently Used Data**
```dart
// Cache farmer profile
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setString('farmerProfile', jsonEncode(profile));
```

4. **Optimize Images Before Upload**
```dart
// Image is automatically compressed in CloudImageService
// From ~5MB → ~500KB
```

---

## 📝 Notes

- All dates are stored as DateTime objects
- All coordinates use double (latitude, longitude)
- Image URLs are permanent (Cloudinary CDN)
- Indexes are created automatically on app start
- MongoDB connection is maintained throughout app lifecycle
- Offline support coming soon (local database sync)

---

For complete setup instructions, see: `MONGODB_CLOUDINARY_SETUP.md`
For TODO tracking, see: `MONGODB_IMPLEMENTATION_TODO.md`

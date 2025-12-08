# MongoDB + Cloudinary Setup Guide for PMFBY App

## 🎯 Overview

This app now uses:
- **MongoDB Atlas** - Cloud database for all farmer, officer, crop, and claim data
- **Cloudinary** - Cloud storage for crop images (ML-ready)
- **Repositories** - Clean data layer for farmers and officers
- **ML Pipeline** - Ready for image verification models

---

## 📋 Prerequisites

1. MongoDB Atlas account (free tier available)
2. Cloudinary account (free tier: 25GB storage)
3. Flutter SDK installed
4. Internet connection for initial setup

---

## 🔧 Step 1: MongoDB Atlas Setup

### 1.1 Create MongoDB Atlas Account
1. Go to https://www.mongodb.com/cloud/atlas/register
2. Sign up for free tier
3. Choose **M0 (Free)** cluster
4. Select region closest to your users (e.g., Mumbai for India)
5. Create cluster (takes 3-5 minutes)

### 1.2 Configure Database Access
1. Go to **Database Access** in left sidebar
2. Click **Add New Database User**
3. Choose **Password** authentication
4. Create username and password (save these!)
5. Database User Privileges: **Read and write to any database**
6. Add User

### 1.3 Configure Network Access
1. Go to **Network Access** in left sidebar
2. Click **Add IP Address**
3. For development: Click **Allow Access from Anywhere** (0.0.0.0/0)
4. For production: Add specific IPs
5. Confirm

### 1.4 Get Connection String
1. Go to **Database** → **Connect**
2. Choose **Connect your application**
3. Driver: **Node.js**
4. Copy connection string (looks like):
   ```
   mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```
5. Replace `<username>` and `<password>` with your credentials

### 1.5 Update App Configuration
Edit `/lib/src/config/mongodb_config.dart`:
```dart
static String get connectionString {
  return 'mongodb+srv://YOUR_USERNAME:YOUR_PASSWORD@YOUR_CLUSTER.mongodb.net/pmfby_app?retryWrites=true&w=majority';
}
```

---

## 📸 Step 2: Cloudinary Setup

### 2.1 Create Cloudinary Account
1. Go to https://cloudinary.com/users/register/free
2. Sign up for free account
3. Verify email

### 2.2 Get Credentials
1. Go to **Dashboard**
2. Note down:
   - **Cloud Name**
   - **API Key**
   - **API Secret**

### 2.3 Create Upload Preset
1. Go to **Settings** → **Upload**
2. Scroll to **Upload presets**
3. Click **Add upload preset**
4. Settings:
   - Preset name: `pmfby_preset`
   - Signing Mode: **Unsigned**
   - Folder: `pmfby_crops`
   - Access mode: **Public**
5. Save

### 2.4 Update App Configuration
Edit `/lib/src/services/cloud_image_service.dart`:
```dart
static const String cloudName = 'YOUR_CLOUD_NAME';
static const String apiKey = 'YOUR_API_KEY';
static const String apiSecret = 'YOUR_API_SECRET';
static const String uploadPreset = 'pmfby_preset';
```

---

## 🔨 Step 3: Add Required Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  # Existing dependencies...
  
  # MongoDB
  mongo_dart: ^0.9.0
  
  # Image handling
  flutter_image_compress: ^2.1.0
  
  # HTTP for Cloudinary
  http: ^1.1.0
  path: ^1.8.3
```

Run:
```bash
flutter pub get
```

---

## 🚀 Step 4: Initialize MongoDB Connection

### In your main.dart or app initialization:
```dart
import 'package:your_app/src/services/mongodb_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize MongoDB
  try {
    await MongoDBService.instance.connect();
    print('✅ MongoDB connected successfully');
  } catch (e) {
    print('❌ MongoDB connection failed: $e');
  }
  
  runApp(MyApp());
}
```

---

## 📊 Step 5: Database Collections

The app automatically creates these collections with indexes:

### Collections Created:
1. **farmers** - Farmer profiles and land parcels
2. **crop_images** - All crop images with ML metadata
3. **crop_loss_intimations** - Loss reports from farmers
4. **claims** - Insurance claims
5. **officials** - Officer accounts
6. **ai_inferences** - ML model results
7. **audit_logs** - All system actions

### Indexes Created Automatically:
- Fast farmer lookup by ID, phone, Aadhaar
- Fast image search by farmer, parcel, status
- Fast claim search by farmer, status
- Optimized for date range queries

---

## 🔄 Step 6: How Data Flows

### Farmer Uploads Crop Image:
```
1. Farmer captures image → App
2. App compresses image
3. Upload to Cloudinary → Get URL
4. Save metadata to MongoDB (CropImageModel)
5. Status: pendingMLVerification
6. ML model processes image (async)
7. Results saved to MongoDB
8. Status: mlVerified or flagged
9. Officer reviews if needed
10. Final status: approved/rejected
```

### Farmer Files Crop Loss:
```
1. Farmer reports loss → App
2. Upload supporting images → Cloudinary
3. Save CropLossModel to MongoDB
4. Status: reported
5. Officer assigned → underInvestigation
6. Officer assesses → assessed
7. If eligible → claim generated
```

---

## 🤖 Step 7: ML Model Integration (Future)

### Setup ML Endpoint:
```python
# Python Flask example for ML model
from flask import Flask, request, jsonify
import tensorflow as tf

app = Flask(__name__)
model = tf.keras.models.load_model('crop_verification_model.h5')

@app.route('/api/ml/verify-crop', methods=['POST'])
def verify_crop():
    image_url = request.json['imageUrl']
    # Download image from Cloudinary
    # Process through model
    # Return predictions
    return jsonify({
        'inferenceId': '...',
        'confidenceScore': 0.95,
        'isAuthentic': True,
        'detectedIssues': []
    })
```

### Update MongoDB with Results:
```dart
final repo = CropImageRepository();
await repo.updateMLVerification(imageId, mlVerification);
```

---

## 🧪 Step 8: Testing

### Test MongoDB Connection:
```dart
// In a test screen
final mongoService = MongoDBService.instance;
if (mongoService.isConnected) {
  print('✅ MongoDB is connected');
} else {
  print('❌ MongoDB not connected');
}
```

### Test Image Upload:
```dart
final imageService = CloudImageService();
final result = await imageService.uploadImage(
  File('path/to/image.jpg'),
  farmerId: 'test_farmer_001',
  imageType: 'cropHealth',
);
print('Image URL: ${result.url}');
```

### Test Repository:
```dart
final repo = CropImageRepository();
final images = await repo.getFarmerImages('test_farmer_001');
print('Found ${images.length} images');
```

---

## 📱 Step 9: Usage in App

### Farmer Uploads Image:
```dart
// In crop image capture screen
import 'package:your_app/src/services/cloud_image_service.dart';
import 'package:your_app/src/repositories/crop_image_repository.dart';
import 'package:your_app/src/models/mongodb/crop_image_model.dart';

Future<void> uploadCropImage(File imageFile) async {
  // 1. Upload to Cloudinary
  final uploadResult = await CloudImageService().uploadImage(
    imageFile,
    farmerId: currentFarmerId,
    imageType: 'cropHealth',
    metadata: {
      'season': 'Kharif',
      'year': 2024,
      'crop': 'Wheat',
    },
  );
  
  // 2. Create database record
  final cropImage = CropImageModel(
    imageId: 'IMG_${DateTime.now().millisecondsSinceEpoch}',
    farmerId: currentFarmerId,
    parcelId: selectedParcelId,
    imageUrl: uploadResult.url,
    thumbnailUrl: uploadResult.thumbnailUrl,
    metadata: ImageMetadata(
      width: uploadResult.width,
      height: uploadResult.height,
      format: uploadResult.format,
      sizeBytes: uploadResult.bytes,
    ),
    location: GeoLocation(
      latitude: currentPosition.latitude,
      longitude: currentPosition.longitude,
      timestamp: DateTime.now(),
    ),
    imageType: ImageType.cropHealth,
    cropInfo: CropInfo(
      cropName: 'Wheat',
      cropType: 'Rabi',
    ),
    season: 'Kharif',
    year: 2024,
    status: ImageStatus.pendingMLVerification,
    capturedAt: DateTime.now(),
    uploadedAt: DateTime.now(),
  );
  
  // 3. Save to MongoDB
  await CropImageRepository().createCropImage(cropImage);
  
  print('✅ Image uploaded and saved to database');
}
```

### Officer Views Pending Images:
```dart
// In officer dashboard
final repo = CropImageRepository();
final pendingImages = await repo.getImagesPendingOfficerReview(limit: 50);

// Display in UI
ListView.builder(
  itemCount: pendingImages.length,
  itemBuilder: (context, index) {
    final image = pendingImages[index];
    return ListTile(
      leading: Image.network(image.thumbnailUrl),
      title: Text('${image.cropInfo.cropName} - ${image.farmerId}'),
      subtitle: Text('Captured: ${image.capturedAt}'),
      trailing: MLVerificationBadge(image.mlVerification),
    );
  },
);
```

---

## 🔐 Step 10: Security Best Practices

### 1. Use Environment Variables:
```dart
// Don't hardcode credentials in code
const String mongoUser = String.fromEnvironment('MONGO_USER');
const String cloudinaryKey = String.fromEnvironment('CLOUDINARY_API_KEY');
```

### 2. Enable MongoDB Authentication:
```dart
// Add auth to connection string
mongodb+srv://username:password@cluster...
```

### 3. Cloudinary Signed Uploads:
For production, use signed uploads to prevent unauthorized access.

### 4. Implement Rate Limiting:
Prevent abuse of image upload endpoints.

---

## 🎉 You're All Set!

Your app now has:
- ✅ MongoDB database for all data
- ✅ Cloudinary for image storage
- ✅ Repositories for clean data access
- ✅ ML-ready image pipeline
- ✅ Farmer and officer workflows
- ✅ Offline-first architecture (coming soon)

---

## 📞 Troubleshooting

### MongoDB Connection Fails:
- Check internet connection
- Verify connection string
- Check IP whitelist in MongoDB Atlas
- Ensure credentials are correct

### Image Upload Fails:
- Check Cloudinary credentials
- Verify upload preset exists
- Check image file size (<10MB)
- Ensure internet connection

### Queries Are Slow:
- Indexes are created automatically
- For large datasets, add more indexes
- Consider MongoDB Atlas Search for full-text search

---

## 📚 Next Steps

1. ✅ Complete farmer image upload flow
2. ✅ Complete crop loss intimation flow
3. ⏳ Build officer review interface
4. ⏳ Integrate ML model endpoint
5. ⏳ Add offline sync
6. ⏳ Deploy to production

---

## 💡 Tips

- Use MongoDB Compass to view data: https://www.mongodb.com/products/compass
- Use Cloudinary Media Library to manage images
- Monitor MongoDB Atlas performance in dashboard
- Set up alerts for database errors
- Regular backups (MongoDB Atlas does this automatically)

---

Happy coding! 🚀

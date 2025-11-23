# CROPIC - Crop Insurance App 🌾

**Making Crop Insurance Faster and Fairer with AI**

## Overview

CROPIC (CROP Image Collection) is a comprehensive digital system for managing crop insurance claims under PMFBY (Pradhan Mantri Fasal Bima Yojana). The app uses AI/ML for automated crop damage assessment and provides a transparent, efficient claim process for farmers.

## Key Features

### ✅ Implemented Features

1. **📱 Bilingual Authentication (Hindi/English)**
   - Phone number OTP-based login
   - Secure Firebase Authentication
   - Farmer-friendly interface

2. **🏠 Agriculture-Themed Dashboard**
   - Quick stats (Land area, Crops, Active claims)
   - Beautiful green gradient design
   - Easy navigation with bottom tabs
   - Recent activity tracking
   - Weather information

3. **📸 Crop Image Capture with GPS**
   - Real-time location tracking (GPS coordinates)
   - Automatic geotag and timestamp
   - Camera and gallery support
   - Upload to Firebase Storage
   - AI-ready image validation

4. **📋 Insurance Claim Filing**
   - Easy claim submission form
   - Multiple damage types (Flood, Drought, Pest, etc.)
   - Photo evidence attachment
   - Estimated loss percentage
   - Firebase Firestore integration

5. **💡 Insurance Scheme Information**
   - PMFBY details
   - Weather-based insurance
   - Premium and coverage information
   - Application process guide
   - Contact information

6. **👤 User Profile (Anshika's Details)**
   - Name: Anshika
   - Location: Jaitpur, Barabanki, Uttar Pradesh
   - Crops: धान (Rice), गेहूं (Wheat), गन्ना (Sugarcane)
   - Land: 5.0 acres
   - Editable profile settings

## Technology Stack

- **Framework:** Flutter 3.9+
- **Backend:** Firebase
  - Firebase Authentication (Phone Auth)
  - Cloud Firestore (Database)
  - Firebase Storage (Images)
- **State Management:** Provider
- **Navigation:** go_router
- **Fonts:** Google Fonts (Poppins, Noto Sans)
- **Location:** Geolocator, Geocoding
- **Images:** Image Picker

## Project Structure

```
lib/
├── main.dart                          # App entry point with routing
├── src/
│   ├── models/                        # Data models
│   │   ├── user_profile.dart
│   │   ├── crop_image.dart
│   │   └── insurance_claim.dart
│   ├── services/                      # Firebase services
│   │   ├── firebase_auth_service.dart
│   │   └── firestore_service.dart
│   └── features/
│       ├── auth/
│       │   └── presentation/
│       │       └── login_screen.dart
│       ├── dashboard/
│       │   └── presentation/
│       │       └── dashboard_screen.dart
│       ├── crop_monitoring/
│       │   └── capture_image_screen.dart
│       ├── claims/
│       │   └── file_claim_screen.dart
│       └── schemes/
│           └── schemes_screen.dart
```

## Setup Instructions

### Prerequisites

- Flutter SDK 3.9 or higher
- Android Studio / VS Code
- Firebase account
- Android device or emulator

### 1. Clone & Install Dependencies

```bash
cd /workspaces/pmfby-app
flutter pub get
```

### 2. Firebase Setup (IMPORTANT!)

#### Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "CROPIC"
3. Enable Google Analytics (optional)

#### Add Android App

1. In Firebase Console, click "Add Android App"
2. Package name: `com.example.myapp` (or update in `android/app/build.gradle.kts`)
3. Download `google-services.json`
4. Place it in `android/app/` directory

#### Enable Firebase Services

**Authentication:**
- Go to Authentication > Sign-in method
- Enable "Phone" authentication
- Add test phone numbers if needed (for development)

**Cloud Firestore:**
- Go to Firestore Database > Create database
- Start in **test mode** (for development)
- Rules (update after testing):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /crop_images/{imageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    match /insurance_claims/{claimId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

**Firebase Storage:**
- Go to Storage > Get started
- Start in **test mode**
- Create folder structure: `crop_images/{userId}/`

#### Generate Firebase Options

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

This will create `lib/firebase_options.dart` automatically.

**Update main.dart** to use the generated options:

```dart
import 'firebase_options.dart';

// In main() function:
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 3. Android Permissions

Already configured in `AndroidManifest.xml`:
- ✅ Internet
- ✅ Camera
- ✅ Location (GPS)
- ✅ Storage (Images)

### 4. Run the App

```bash
# Check devices
flutter devices

# Run on connected device
flutter run

# Or build APK
flutter build apk --release
```

## 📱 App Flow

1. **Login Screen** → Enter phone number → Receive OTP → Verify
2. **Dashboard** → View stats, recent activity, quick actions
3. **Capture Image** → GPS location → Take/select photo → Upload
4. **File Claim** → Fill form → Add photos → Submit
5. **View Schemes** → Browse insurance options
6. **Profile** → View/edit Anshika's details

## 🔐 Required Permissions (User Must Allow)

When running the app for the first time, users will be prompted to allow:

1. **📍 Location Permission** - For GPS tagging crop photos
2. **📷 Camera Permission** - For capturing crop images
3. **🖼️ Storage Permission** - For selecting images from gallery

## 🚀 Next Steps for Production

### AI/ML Integration

Create Cloud Function in Firebase:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.analyzeCropImage = functions.firestore
  .document('crop_images/{imageId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    
    // Call AI/ML model (Google Cloud Vision, Custom Model, etc.)
    // Example: Detect crop type, health, damage
    
    const aiResult = {
      cropType: 'Rice',
      growthStage: 'Flowering',
      isHealthy: false,
      damageType: 'Pest Attack',
      confidenceScore: 0.89,
    };
    
    // Update document with AI results
    return snap.ref.update({
      status: 'completed',
      ...aiResult,
    });
  });
```

### Web Dashboard for Officials

Create a Flutter Web app for PMFBY officials to:
- View real-time map of crop images
- Monitor AI analysis results
- Approve/reject claims
- Generate reports

### Security Enhancements

1. Update Firestore rules for production
2. Implement rate limiting
3. Add data validation
4. Enable App Check
5. Setup backup strategies

## 📞 Support

- **Helpline:** 1800-XXX-XXXX
- **Email:** support@cropic.gov.in
- **Website:** pmfby.gov.in

## 👩‍💻 Developer Notes

### Testing

```bash
# Run tests
flutter test

# Widget tests
flutter test test/widget_test.dart
```

### Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# Install release APK
flutter install --release
```

### Common Issues

**Firebase not initialized:**
- Make sure `google-services.json` is in `android/app/`
- Run `flutterfire configure`

**Location not working:**
- Check permissions in AndroidManifest.xml
- Enable GPS on device
- Grant location permission when prompted

**Camera not working:**
- Grant camera permission
- Test on physical device (not all emulators support camera)

## 📄 License

This project is developed for PMFBY (Pradhan Mantri Fasal Bima Yojana) by the Ministry of Agriculture, Government of India.

---

**Built with ❤️ for Indian Farmers 🇮🇳**

# 🎯 CROPIC App - Complete Setup & Run Guide

## ✅ What Has Been Built

Your CROPIC (Crop Insurance) Flutter app is now **COMPLETE** with all requested features!

### 🌟 Implemented Features

#### 1. **Authentication System** ✅
- Bilingual UI (Hindi/English)
- Phone number + OTP login
- Firebase Authentication integration
- Beautiful green agricultural theme

#### 2. **Home Dashboard** ✅
- **User Profile**: Anshika from Jaitpur, Barabanki, UP
- **Crops**: धान (Rice), गेहूं (Wheat), गन्ना (Sugarcane)
- **Land**: 5.0 acres
- Quick stats cards
- Recent activity feed
- Bottom navigation (Home, Claims, Schemes, Profile)

#### 3. **Crop Image Capture** ✅
- GPS location tagging (automatic)
- Timestamp capture
- Camera & gallery support
- Location name display
- Upload instructions in Hindi/English
- Firebase Storage ready

#### 4. **Complaint/Claim Filing** ✅
- Detailed claim form
- Damage type selection (Flood, Drought, Pest, etc.)
- Incident date picker
- Description field
- Photo evidence support
- Firebase Firestore integration

#### 5. **Insurance Schemes** ✅
- PMFBY (Pradhan Mantri Fasal Bima Yojana)
- Weather-based insurance
- Modified NAIS
- Coconut Palm Insurance
- Application process guide
- Contact information

#### 6. **User Profile** ✅
- Display Anshika's details
- Farm information
- Crop list
- Location details
- Logout functionality

### 📱 Android Permissions (Configured)
- ✅ Internet
- ✅ Camera
- ✅ GPS Location (Fine & Coarse)
- ✅ Storage (Read/Write images)

---

## 🚀 How to Run the App

### Prerequisites
- Flutter SDK 3.9+ installed
- Android Studio or VS Code with Flutter extension
- Android emulator or physical device
- Firebase account (for full functionality)

### Step 1: Install Dependencies

```bash
cd /workspaces/pmfby-app
flutter pub get
```

### Step 2: Firebase Setup (Critical!)

#### Option A: Quick Test (Without Firebase)
The app will run but Firebase features (login, database) won't work.

```bash
flutter run
```

#### Option B: Full Setup (With Firebase - Recommended)

1. **Create Firebase Project**
   - Go to https://console.firebase.google.com/
   - Create project: "CROPIC"
   - Add Android app
   - Package name: `com.example.myapp`

2. **Download Configuration**
   - Download `google-services.json`
   - Place in: `android/app/google-services.json`

3. **Enable Services in Firebase Console**
   - **Authentication** → Enable "Phone" sign-in
   - **Cloud Firestore** → Create database (test mode)
   - **Storage** → Enable storage (test mode)

4. **Generate Firebase Options**

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Run configuration
flutterfire configure --project=cropic
```

This creates `lib/firebase_options.dart`

5. **Update main.dart** (line 13-17)

```dart
import 'firebase_options.dart';

// Replace existing Firebase.initializeApp() with:
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### Step 3: Run the App

```bash
# Check connected devices
flutter devices

# Run on device/emulator
flutter run

# For release build
flutter build apk --release
```

---

## 📱 App Navigation Flow

```
Login Screen (OTP)
    ↓
Dashboard (4 tabs)
    ├── Home Tab
    │   ├── Quick Stats
    │   ├── Capture Crop Image → Camera Screen
    │   ├── File New Claim → Claim Form
    │   └── Help Center
    ├── Claims Tab (My Claims List)
    ├── Schemes Tab (Insurance Information)
    └── Profile Tab (Anshika's Details + Logout)
```

---

## 🎨 Design Features

### Color Scheme
- **Primary**: Green (#2E7D32) - Agriculture theme
- **Secondary**: Amber (#FFA000) - Attention/Action
- **Gradients**: Green shades for natural feel

### Fonts
- **Poppins**: Headings & buttons
- **Noto Sans**: Hindi text support
- **Roboto**: Body text

### UI Elements
- Rounded corners (12px border radius)
- Gradient backgrounds
- Shadow elevations
- Icon-based navigation
- Bilingual labels

---

## 📋 File Structure Created

```
lib/
├── main.dart                                    # ✅ Updated with routing
├── src/
│   ├── models/
│   │   ├── user_profile.dart                   # ✅ Farmer profile model
│   │   ├── crop_image.dart                     # ✅ GPS-tagged image model
│   │   └── insurance_claim.dart                # ✅ Claim data model
│   ├── services/
│   │   ├── firebase_auth_service.dart          # ✅ OTP authentication
│   │   └── firestore_service.dart              # ✅ Database operations
│   └── features/
│       ├── auth/presentation/
│       │   └── login_screen.dart               # ✅ Bilingual login
│       ├── dashboard/presentation/
│       │   └── dashboard_screen.dart           # ✅ Complete dashboard
│       ├── crop_monitoring/
│       │   └── capture_image_screen.dart       # ✅ GPS + Camera
│       ├── claims/
│       │   └── file_claim_screen.dart          # ✅ Claim form
│       └── schemes/
│           └── schemes_screen.dart             # ✅ Insurance info
```

---

## 🔧 Required Extensions/Permissions

### When App Launches
Users will be asked to grant:

1. **📍 Location Permission** (Required for GPS tagging)
   - "Allow CROPIC to access this device's location?"
   - Select: "While using the app"

2. **📷 Camera Permission** (Required for crop photos)
   - "Allow CROPIC to take pictures and record video?"
   - Select: "Allow"

3. **🖼️ Storage Permission** (For saving images)
   - "Allow CROPIC to access photos and media?"
   - Select: "Allow"

### Android Settings to Enable
- **GPS/Location**: Settings → Location → ON
- **Internet**: WiFi or Mobile data
- **Storage**: Should be auto-enabled

---

## 🧪 Testing Guide

### Test Scenarios

#### 1. Login Flow
```
1. Open app → Login screen appears
2. Enter: +91 9876543210 (or your number)
3. Click "OTP भेजें"
4. Wait for OTP (SMS or Firebase test number)
5. Enter 6-digit OTP
6. Click "सत्यापित करें"
7. Should navigate to Dashboard
```

#### 2. Capture Image
```
1. From Dashboard → Click "फसल की फोटो लें"
2. Wait for GPS location to load
3. Click "कैमरा से फोटो लें"
4. Grant camera permission if asked
5. Take photo of any plant/crop
6. Review photo
7. Click "अपलोड करें"
8. Success message appears
```

#### 3. File Claim
```
1. Dashboard → Click "नया दावा दर्ज करें"
2. Fill form:
   - Crop: "गेहूं"
   - Damage: "बाढ़ (Flood)"
   - Date: Select any recent date
   - Loss: "50"
   - Description: "Heavy rain damaged wheat crop..."
3. Click "दावा जमा करें"
4. Success message appears
```

#### 4. View Schemes
```
1. Dashboard → Bottom nav → "योजना"
2. Scroll through insurance schemes
3. Click "अधिक जानें" on any scheme
4. Dialog shows details
```

#### 5. Profile
```
1. Dashboard → Bottom nav → "प्रोफाइल"
2. View Anshika's details:
   - Name, Phone, Village, District, State
   - Land area, Crops
3. Click logout icon → Returns to login
```

---

## 📦 Dependencies Added

```yaml
dependencies:
  firebase_core: ^3.6.0           # Firebase initialization
  firebase_auth: ^5.3.1           # Phone authentication
  cloud_firestore: ^5.4.4         # Database
  firebase_storage: ^12.3.4       # Image storage
  image_picker: ^1.1.2            # Camera/Gallery
  geolocator: ^13.0.2             # GPS location
  geocoding: ^3.0.0               # Address from GPS
  intl: ^0.19.0                   # Date formatting
  shared_preferences: ^2.3.3      # Local storage
  uuid: ^4.5.1                    # Unique IDs
  image: ^4.3.0                   # Image processing
  provider: ^6.1.5+1              # State management
  go_router: ^17.0.0              # Navigation
  google_fonts: ^6.3.2            # Hindi/English fonts
```

---

## 🐛 Troubleshooting

### Issue: "Firebase not initialized"
**Solution:**
1. Add `google-services.json` to `android/app/`
2. Run `flutterfire configure`
3. Update `main.dart` with Firebase options

### Issue: "Location not working"
**Solution:**
1. Enable GPS on device
2. Grant location permission when prompted
3. Use physical device (emulators may have GPS issues)

### Issue: "Camera black screen"
**Solution:**
1. Grant camera permission
2. Test on physical device
3. Check AndroidManifest.xml has camera permission

### Issue: "OTP not received"
**Solution:**
1. Use Firebase test phone numbers for development
2. Check phone number format: +91XXXXXXXXXX
3. Verify Firebase Authentication is enabled

---

## 🎯 Next Steps for Production

### 1. AI/ML Integration
- Deploy TensorFlow Lite model for crop detection
- Create Cloud Functions for automatic analysis
- Implement damage assessment AI

### 2. Web Dashboard
- Build Flutter web app for officials
- Real-time map visualization
- Claim approval workflow

### 3. Security
- Update Firestore rules
- Add data validation
- Enable Firebase App Check
- Implement rate limiting

### 4. Testing
- Add unit tests
- Widget tests
- Integration tests
- User acceptance testing

---

## 📞 Support Resources

- **Firebase Docs**: https://firebase.google.com/docs/flutter
- **Flutter Docs**: https://docs.flutter.dev/
- **PMFBY Official**: https://pmfby.gov.in/
- **Helpline**: 1800-180-1551

---

## ✨ Features Summary

| Feature | Status | Description |
|---------|--------|-------------|
| Bilingual UI | ✅ | Hindi + English throughout |
| Phone Login | ✅ | OTP-based authentication |
| GPS Tagging | ✅ | Automatic location capture |
| Camera | ✅ | Crop photo capture |
| Claims | ✅ | Full claim filing system |
| Schemes | ✅ | Insurance information |
| Profile | ✅ | Anshika's farmer profile |
| Firebase | ✅ | Auth, Firestore, Storage |
| Beautiful UI | ✅ | Green agriculture theme |
| Navigation | ✅ | Bottom nav + routing |

---

**🎉 Your CROPIC app is ready to help farmers across India! 🇮🇳**

Built with ❤️ for Indian Agriculture 🌾

# 🌾 KrisiBandhu - AI-Powered Crop Insurance Platform

![KrisiBandhu](https://img.shields.io/badge/KrisiBandhu-Crop%20Insurance-green?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.9.0-blue?style=for-the-badge&logo=flutter)
![License](https://img.shields.io/badge/License-Proprietary-red?style=for-the-badge)

**KrisiBandhu** (meaning "Friend of Farmers") is a revolutionary digital platform designed to transform the crop insurance landscape in India. Built with cutting-edge AI and cloud technology, we make insurance claims faster, more transparent, and fairer for farmers.

## 📱 Project Components

This repository contains two main components:

### 1. Mobile Application (Flutter)
A cross-platform mobile app for farmers and field officials to capture, analyze, and manage crop insurance claims.

**Key Features:**
- 📸 Geotagged & timestamped crop image capture
- 🤖 AI-powered crop health analysis
- ⚡ Quick claims filing and tracking
- 🔒 Secure authentication
- 🗺️ Location-based services
- 📊 Real-time claim status updates

### 2. Landing Website
A professional, responsive website showcasing the platform's features and benefits.

**Features:**
- 🎨 Modern, agriculture-themed design
- 📱 Fully responsive for all devices
- ⚡ Fast loading with optimized performance
- 🌐 SEO-friendly structure
- ♿ Accessible and user-friendly

## 🚀 Quick Start

### Mobile App (Flutter)

#### Prerequisites
- Flutter SDK (^3.9.0)
- Dart SDK
- Android Studio / Xcode
- Git

#### Installation
```bash
# Clone the repository
git clone https://github.com/ashishbalodia1/pmfby-app.git
cd pmfby-app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

#### Build for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Website

#### Preview Locally
```bash
# Navigate to website directory
cd website

# Start local server (Python)
python3 -m http.server 8000

# Or use PHP
php -S localhost:8000

# Or use Node.js
npx http-server -p 8000
```

Then open `http://localhost:8000` in your browser.

#### Deploy
See [website/DEPLOYMENT.md](website/DEPLOYMENT.md) for comprehensive deployment options including:
- GitHub Pages (FREE)
- Netlify (FREE)
- Vercel (FREE)
- Firebase Hosting
- And many more...

## 📁 Project Structure

```
pmfby-app/
├── android/                 # Android native code
├── ios/                     # iOS native code
├── lib/                     # Flutter application code
│   ├── main.dart           # App entry point
│   └── src/
│       └── features/       # Feature-based architecture
│           ├── auth/       # Authentication
│           └── dashboard/  # Main dashboard
├── assets/                 # Images and assets
├── website/                # Landing website
│   ├── index.html         # Main page
│   ├── css/               # Stylesheets
│   ├── js/                # JavaScript
│   ├── images/            # Website images
│   ├── README.md          # Website documentation
│   └── DEPLOYMENT.md      # Deployment guide
├── test/                   # Flutter tests
├── pubspec.yaml           # Flutter dependencies
└── README.md              # This file
```

## 🎨 Design Philosophy

**Theme:** Agriculture-inspired with green, brown, and yellow color palette
**Typography:** Clean, legible fonts (Merriweather, Open Sans, Roboto)
**UI/UX:** Icon-driven interface for users with varying tech literacy
**Layout:** Simple, card-based design for easy navigation

## 🛠️ Technology Stack

### Mobile App
- **Framework:** Flutter
- **State Management:** Provider
- **Navigation:** go_router
- **Typography:** google_fonts
- **Platform:** Cross-platform (Android & iOS)

### Website
- **HTML5:** Semantic markup
- **CSS3:** Modern styling with Grid & Flexbox
- **JavaScript:** Vanilla JS (no frameworks)
- **Fonts:** Google Fonts

### Backend (Planned)
- **Database:** Firebase Firestore
- **Storage:** Firebase Cloud Storage
- **Authentication:** Firebase Auth
- **ML/AI:** Google Cloud AI Platform
- **Functions:** Cloud Functions

## 📊 Features Overview

| Feature | Status | Description |
|---------|--------|-------------|
| User Authentication | 🟡 In Progress | Secure login/signup |
| Image Capture | 🟡 In Progress | Geotagged crop photos |
| AI Analysis | 🔴 Planned | Crop health assessment |
| Claims Management | 🔴 Planned | File and track claims |
| Dashboard | 🟢 Complete | Main app interface |
| Website | 🟢 Complete | Landing page |
| Push Notifications | 🔴 Planned | Real-time updates |
| Multi-language | 🔴 Planned | Hindi, English, Regional |

## 🌐 Website Features

✅ **Responsive Design** - Works perfectly on mobile, tablet, and desktop
✅ **Modern UI** - Clean, professional agriculture-themed design
✅ **Fast Performance** - Optimized for quick loading
✅ **SEO Optimized** - Better search engine visibility
✅ **Contact Form** - With validation and notifications
✅ **Smooth Animations** - Enhanced user experience
✅ **Newsletter** - Subscription functionality
✅ **Mobile Menu** - Hamburger navigation for mobile

## 📱 Screenshots

### Mobile App
Coming soon...

### Website
Preview the website at: `http://localhost:8000` (after running local server)

## 🤝 Contributing

This project is currently in development. For contributions:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is proprietary software. All rights reserved.

## 📧 Contact & Support

- **Email:** support@krisibandhu.in
- **Phone:** 1800-123-456 (Toll Free)
- **Address:** Agriculture Technology Park, New Delhi, India 110001

## 🙏 Acknowledgments

- Designed for Indian farmers
- Built with Flutter & modern web technologies
- Inspired by PMFBY (Pradhan Mantri Fasal Bima Yojana)
- Powered by Google Cloud AI

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Website Deployment Guide](website/DEPLOYMENT.md)
- [Blueprint Document](blueprint.md)
- [Development Notes](GEMINI.md)

---

**Built with ❤️ for Indian Farmers** 🇮🇳

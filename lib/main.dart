import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'src/features/auth/presentation/login_screen.dart';
import 'src/features/auth/presentation/registration_screen.dart';
import 'src/features/auth/data/services/auth_service.dart';
import 'src/features/auth/presentation/providers/auth_provider.dart';
import 'src/features/auth/domain/models/user_model.dart';
import 'src/features/dashboard/presentation/dashboard_screen.dart';
import 'src/features/officer/officer_dashboard_screen.dart';
import 'src/features/camera/presentation/camera_screen.dart';
import 'src/features/camera/presentation/enhanced_camera_screen.dart';
import 'src/features/camera/presentation/ar_camera_screen.dart';
import 'src/features/camera/presentation/image_preview_screen.dart';
import 'src/features/profile/presentation/profile_screen.dart';
import 'src/features/complaints/presentation/screens/complaints_screen.dart';
import 'src/features/complaints/presentation/screens/complaint_detail_screen.dart';
import 'src/features/complaints/domain/models/complaint_model.dart';

import 'src/features/crop_monitoring/capture_image_screen.dart';
import 'src/features/claims/file_claim_screen.dart';
import 'src/features/claims/claims_list_screen.dart';
import 'src/features/schemes/schemes_screen.dart';
import 'src/features/uploads/upload_status_screen.dart';
import 'src/features/premium_calculator/premium_calculator_screen.dart';
import 'src/features/crop_loss/presentation/crop_loss_intimation_screen.dart';
import 'src/features/crop_loss/presentation/file_crop_loss_screen.dart';
import 'src/features/multi_image/multi_image_capture_screen.dart';
import 'src/features/multi_image/batch_upload_progress_screen.dart';
import 'src/features/satellite/satellite_monitoring_screen.dart';
import 'src/features/satellite/enhanced_satellite_screen.dart';
import 'src/features/pmfby_info/pmfby_info_screen.dart';
import 'src/features/batch_upload/enhanced_batch_upload_screen.dart';
import 'src/features/settings/language_settings_screen.dart';
import 'src/theme/app_themes.dart';
import 'src/localization/app_localizations.dart';

import 'src/services/firebase_auth_service.dart';
import 'src/services/image_upload_service.dart';
import 'src/services/connectivity_service.dart';
import 'src/services/auto_sync_service.dart';
import 'src/providers/language_provider.dart';
import 'src/features/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const KrashiBandhuApp(),
    ),
  );
}

// Global initialization function to be called from splash screen
Future<void> initializeApp() async {
  // Firebase initialization
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization error: $e');
  }

  // Local Auth initialization (with demo user logic)
  final authService = AuthService();
  await authService.initialize();
  debugPrint('✅ Auth service initialized');

  final allUsers = authService.getAllUsers();
  debugPrint('📊 Number of users in database: ${allUsers.length}');

  if (allUsers.isEmpty) {
    debugPrint('🔧 Creating demo users...');
    await _createDemoUsers(authService);
    debugPrint('✅ Demo users created successfully');
  }

  // Initialize connectivity and auto-sync services
  debugPrint('🔄 Initializing connectivity and sync services...');
  final connectivityService = ConnectivityService();
  final autoSyncService = AutoSyncService();
  await autoSyncService.initializeNotifications();
  await autoSyncService.initializeBackgroundSync();
  debugPrint('✅ All services initialized successfully');
}

Future<void> _createDemoUsers(AuthService authService) async {
  // Demo farmer
  final farmerUser = User(
    userId: 'demo_farmer_001',
    name: 'Demo Farmer',
    email: 'farmer@demo.com',
    phone: '9876543210',
    role: 'farmer',
    password: 'demo123',
    village: 'Demo Village',
    district: 'Demo District',
    state: 'Demo State',
    farmSize: 5.0,
    aadharNumber: '123456789012',
    cropTypes: ['Wheat', 'Rice', 'Maize'],
  );
  
  // Demo official
  final officialUser = User(
    userId: 'demo_official_001',
    name: 'Demo Official',
    email: 'official@demo.com',
    phone: '9876543211',
    role: 'official',
    password: 'demo123',
    officialId: 'OFF-2025-001',
    designation: 'Insurance Officer',
    department: 'Agriculture Insurance',
    assignedDistrict: 'Demo District',
  );
  
  await authService.register(farmerUser);
  await authService.register(officialUser);
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

GoRouter _buildRouter(BuildContext context) {
  return GoRouter(
    refreshListenable: context.read<AuthProvider>(),
    initialLocation: '/login',
    redirect: (BuildContext context, GoRouterState state) {
      // You can plug in actual auth logic later.
      return null;
    },
    routes: <RouteBase>[
      // LOGIN + REGISTER
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/register/farmer',
        builder: (_, __) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/register/officer',
        builder: (_, __) => const RegistrationScreen(),
      ),

      // DASHBOARD
      GoRoute(
        path: '/dashboard',
        builder: (_, __) => const DashboardScreen(),
      ),

      // OFFICER DASHBOARD
      GoRoute(
        path: '/officer-dashboard',
        builder: (_, __) => const OfficerDashboardScreen(),
      ),

      // CAMERA
      GoRoute(
        path: '/camera',
        builder: (_, __) => const EnhancedCameraScreen(),
        routes: [
          GoRoute(
            path: 'preview',
            builder: (_, state) {
              final imagePath = state.extra as String;
              return ImagePreviewScreen(imagePath: imagePath);
            },
          ),
        ],
      ),

      // AR CAMERA (Advanced AR features)
      GoRoute(
        path: '/ar-camera',
        builder: (_, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return ARCameraScreen(
            purpose: extras?['purpose'] as String?,
            multiAngleMode: extras?['multiAngleMode'] as bool? ?? false,
            farmPlotId: extras?['farmPlotId'] as String?,
          );
        },
      ),

      // CROP MONITORING (NEW)
      GoRoute(
        path: '/capture-image',
        builder: (_, __) => const CaptureImageScreen(),
      ),

      // CLAIMS (NEW)
      GoRoute(
        path: '/claims',
        builder: (_, __) => const ClaimsListScreen(),
      ),
      GoRoute(
        path: '/file-claim',
        builder: (_, __) => const FileClaimScreen(),
      ),

      // SCHEMES (NEW)
      GoRoute(
        path: '/schemes',
        builder: (_, __) => const SchemesScreen(),
      ),

      // UPLOAD STATUS
      GoRoute(
        path: '/upload-status',
        builder: (_, __) => const UploadStatusScreen(),
      ),

      // PREMIUM CALCULATOR
      GoRoute(
        path: '/premium-calculator',
        builder: (_, __) => const PremiumCalculatorScreen(),
      ),

      // CROP LOSS INTIMATION
      GoRoute(
        path: '/crop-loss-intimation',
        builder: (_, __) => const CropLossIntimationScreen(),
      ),
      GoRoute(
        path: '/file-crop-loss',
        builder: (_, __) => const FileCropLossScreen(),
      ),

      // MULTI-IMAGE CAPTURE
      GoRoute(
        path: '/multi-image-capture',
        builder: (_, __) => const MultiImageCaptureScreen(),
      ),
      GoRoute(
        path: '/batch-upload-progress',
        builder: (_, __) => const BatchUploadProgressScreen(),
      ),

      // PROFILE
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
      ),

      // SATELLITE MONITORING
      GoRoute(
        path: '/satellite',
        builder: (_, __) => const EnhancedSatelliteScreen(),
      ),

      // PMFBY INFO
      GoRoute(
        path: '/pmfby-info',
        builder: (_, __) => const PMFBYInfoScreen(),
      ),

      // BATCH UPLOAD
      GoRoute(
        path: '/batch-upload',
        builder: (_, __) => const EnhancedBatchUploadScreen(),
      ),

      // LANGUAGE SETTINGS
      GoRoute(
        path: '/language-settings',
        builder: (_, __) => const LanguageSettingsScreen(),
      ),

      // COMPLAINTS
      GoRoute(
        path: '/complaints',
        builder: (_, __) => const ComplaintsScreen(),
        routes: [
          GoRoute(
            path: 'detail',
            builder: (_, state) {
              final complaint = state.extra as Complaint;
              return ComplaintDetailScreen(complaint: complaint);
            },
          ),
        ],
      ),
    ],
  );
}


class KrashiBandhuApp extends StatefulWidget {
  const KrashiBandhuApp({super.key});

  @override
  State<KrashiBandhuApp> createState() => _KrashiBandhuAppState();
}

class _KrashiBandhuAppState extends State<KrashiBandhuApp> {
  bool _initialized = false;
  late AuthProvider _authProvider;
  late ConnectivityService _connectivityService;
  late AutoSyncService _autoSyncService;

  Future<void> _initialize() async {
    debugPrint('🚀 Starting app initialization...');
    await initializeApp();
    
    // Initialize providers after splash
    final authService = AuthService();
    await authService.initialize();
    _authProvider = AuthProvider(authService);
    await _authProvider.initialize();
    
    _connectivityService = ConnectivityService();
    _autoSyncService = AutoSyncService();
    
    debugPrint('✅ All initialization complete');
    
    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Color(0xFF2E7D32); // Deep Green
    const Color secondaryColor = Color(0xFFFFA000); // Amber

    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.poppins(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.notoSans(fontSize: 14),
      labelLarge: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.bold),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
        secondary: secondaryColor,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
        secondary: secondaryColor,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: secondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
      ),
    );

    final themeProvider = context.watch<ThemeProvider>();
    
    return MaterialApp(
      title: 'Krishi Bandhu - PMFBY',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      home: _initialized
          ? MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: _authProvider),
                ChangeNotifierProvider(create: (_) => FirebaseAuthService()),
                ChangeNotifierProvider.value(value: _connectivityService),
                Provider.value(value: _autoSyncService),
                ChangeNotifierProvider(create: (_) => ImageUploadService()),
              ],
              child: const MainApp(),
            )
          : SplashScreen(
              onInitializationComplete: _initialize,
            ),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _buildRouter(context),
      title: 'PMFBY - Pradhan Mantri Fasal Bima Yojana',
      debugShowCheckedModeBanner: false,
      theme: PMFBYTheme.lightTheme,
    );
  }
}

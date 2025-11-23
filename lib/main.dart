import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'src/features/auth/presentation/login_screen.dart';
import 'src/features/auth/presentation/registration_screen.dart';
import 'src/features/auth/data/services/auth_service.dart';
import 'src/features/auth/presentation/providers/auth_provider.dart';
import 'src/features/auth/domain/models/user_model.dart';
import 'src/features/dashboard/presentation/dashboard_screen.dart';
import 'src/features/camera/presentation/camera_screen.dart';
import 'src/features/camera/presentation/image_preview_screen.dart';
import 'src/features/profile/presentation/profile_screen.dart';
import 'src/features/complaints/presentation/screens/complaints_screen.dart';
import 'src/features/complaints/presentation/screens/complaint_detail_screen.dart';
import 'src/features/complaints/domain/models/complaint_model.dart';

import 'src/features/crop_monitoring/capture_image_screen.dart';
import 'src/features/claims/file_claim_screen.dart';
import 'src/features/schemes/schemes_screen.dart';

import 'src/services/firebase_auth_service.dart';
import 'src/services/auth/auth_service.dart';
import 'src/services/auth/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Local Auth initialization (with demo user logic)
  final authService = AuthService();
  await authService.initialize();

  final allUsers = authService.getAllUsers();
  debugPrint('Number of users in database: ${allUsers.length}');

  if (allUsers.isEmpty) {
    debugPrint('Creating demo users...');
    await _createDemoUsers(authService);
    debugPrint('Demo users created successfully');
  }

  final authProvider = AuthProvider(authService);
  await authProvider.initialize();
  debugPrint('AuthProvider initialized - Is logged in: ${authProvider.isLoggedIn}');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => FirebaseAuthService()),
      ],
      child: const KrisiBandhuApp(),
    ),
  );
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
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegistrationScreen(),
      ),

      // DASHBOARD
      GoRoute(
        path: '/dashboard',
        builder: (_, __) => const DashboardScreen(),
      ),

      // CAMERA
      GoRoute(
        path: '/camera',
        builder: (_, __) => const CameraScreen(),
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

      // CROP MONITORING (NEW)
      GoRoute(
        path: '/capture-image',
        builder: (_, __) => const CaptureImageScreen(),
      ),

      // CLAIMS (NEW)
      GoRoute(
        path: '/file-claim',
        builder: (_, __) => const FileClaimScreen(),
      ),

      // SCHEMES (NEW)
      GoRoute(
        path: '/schemes',
        builder: (_, __) => const SchemesScreen(),
      ),

      // PROFILE
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
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


class CropicApp extends StatelessWidget {
  const CropicApp({super.key});

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

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          routerConfig: _buildRouter(context),
          title: 'Krashi Bandhu',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'finder_home_screen.dart';
import 'provider_history_screen.dart';
import 'finder_provider_profile_screen.dart';
import 'BookServiceScreen.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'edit_profile_screen.dart';
import 'provider_dashboard_screen.dart';
import 'provider_profile_screen.dart';
import 'provider_add_services_screen.dart';
import 'DBhelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Starting initialization...');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully.');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  try {
    await DatabaseHelper.instance.database;
    print('Database initialized successfully.');
  } catch (e) {
    print('Database initialization failed: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> _determineInitialRoute() async {
    bool isLoggedIn = await DatabaseHelper.instance.isLoggedIn();
    if (!isLoggedIn) return '/login';

    String userType = await DatabaseHelper.instance.getUserType() ?? 'Finder';
    print('User type: $userType');
    return userType == 'Provider' ? '/provider_dashboard' : '/finder_home';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Service Finder',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) =>  SplashScreen(),
        '/': (context) => FutureBuilder<String>(
          future: _determineInitialRoute(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            return const LoginScreen();
          },
        ),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/finder_home': (context) => const FinderHomeScreen(),
        '/finder_provider_profile': (context) =>
            FinderProviderProfileScreen(
                providerId: ModalRoute.of(context)!.settings.arguments as String),
        '/book_service': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return BookServiceScreen(
              providerId: args['providerId'], providerName: args['providerName']);
        },
        '/edit_profile': (context) => EditProfileScreen(
            userData: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>),
        '/provider_dashboard': (context) => const ProviderDashboardScreen(),
        '/provider_profile': (context) => const ProviderProfileScreen(),
        '/add_service': (context) => const AddServiceScreen(),
        '/provider_history': (context) => const ProviderHistoryScreen()
      },
    );
  }
}
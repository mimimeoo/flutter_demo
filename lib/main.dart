import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:firebase_core/firebase_core.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 

import 'firebase_options.dart'; 
import 'providers/auth_provider.dart';
import 'providers/favorite_provider.dart'; 
import 'providers/cart_provider.dart'; 

import 'screens/home_screen.dart'; 
import 'screens/onboarding_screen.dart'; 
import 'admin/admin_dashboard_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MyApp(isFirstTime: isFirstTime),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;

  const MyApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrewGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'GoogleSans',
              bodyColor: const Color(0xFF1A1D26), 
              displayColor: const Color(0xFF1A1D26),
            ),
      ),
      home: isFirstTime ? const OnboardingScreen() : const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    
    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF66BB6A))));
    }

    
    if (authProvider.isLoggedIn && authProvider.isAdmin) {
      return const AdminDashboardScreen();
    }

    
    return const HomeScreen();
  }
}
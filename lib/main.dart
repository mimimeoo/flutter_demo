import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:firebase_core/firebase_core.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; // 🔥 Thêm thư viện này

import 'firebase_options.dart'; 
import 'providers/auth_provider.dart';
import 'providers/favorite_provider.dart'; 
import 'providers/cart_provider.dart'; 
import 'screens/home_screen.dart'; 
import 'screens/onboarding_screen.dart'; // 🔥 Import trang Onboarding của bạn

void main() async {
  // Đảm bảo Flutter đã sẵn sàng trước khi gọi Native code (Firebase/Prefs)
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Kiểm tra trạng thái mở app lần đầu bằng SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  // Nếu chưa từng có dữ liệu 'isFirstTime', mặc định sẽ trả về true
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  runApp(
    // Khai báo các Provider để toàn bộ App có thể sử dụng
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MyApp(isFirstTime: isFirstTime), // Truyền biến vào MyApp
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
        // Cấu hình Font chữ và màu sắc chủ đạo
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'GoogleSans',
              bodyColor: const Color(0xFF1A1D26), 
              displayColor: const Color(0xFF1A1D26),
            ),
      ),
      // 🔥 LOGIC ĐIỀU HƯỚNG:
      // Nếu là lần đầu mở app -> Hiện OnboardingScreen
      // Nếu đã từng xem rồi -> Vào thẳng HomeScreen
      home: isFirstTime ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}
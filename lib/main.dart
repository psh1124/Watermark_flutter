import 'package:flutter/material.dart';
import 'screens/loading_screen.dart';
import 'screens/main_screen.dart';

void main() {
  print('=== WaterPark 앱 시작 ===');
  print('현재 시간: ${DateTime.now()}');
  print('Flutter 앱 초기화 중...');
  runApp(const WaterParkApp());
}

class WaterParkApp extends StatelessWidget {
  const WaterParkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaterPark SNS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667DEB),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter', // 기본 폰트 (시스템 폰트 사용)
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF333333),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
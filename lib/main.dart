import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hand Cricket',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
          ),
          useMaterial3: true,
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            bodyMedium: TextStyle(
              fontSize: 16,
              color: AppColors.textDark,
            ),
            labelMedium: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

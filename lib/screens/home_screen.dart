import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background_stadium.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game Title
                _buildGameTitle(),

                const SizedBox(height: 100),

                // Start Game Button
                _buildStartButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameTitle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PNG Logo
        Image.asset(
          "assets/images/hand-cricket-logo.png",
          height: 150,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 16),

        // Game Title Animation
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Color(0xFF0C1E35),
                        Color(0xFF0C1E35),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.35, 0.65, 1.0],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        GameStrings.appTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        "Challenge the ultimate cricket bot – fast-paced, fun, and packed with surprises!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Container(
              width: 200,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF3DC8A),
                    Color(0xFFBD9E5E),
                    Color(0xFFF3DC8A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.4),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  context.read<GameProvider>().startGame();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: AppColors.textDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  splashFactory: NoSplash.splashFactory,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      GameStrings.startGame,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.sports_cricket_rounded,
                      color: AppColors.textDark,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

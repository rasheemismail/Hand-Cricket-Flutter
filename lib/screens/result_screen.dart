import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'game_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final gameState = gameProvider.state;

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage("assets/images/background_stadium.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black54,
                  BlendMode.darken,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  Image.asset(
                    "assets/images/hand-cricket-logo.png",
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  Expanded(
                    child: _buildResultContent(gameState),
                  ),
                  _buildPlayAgainButton(context, gameProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultContent(GameState gameState) {
    final bool userWon = gameState.result == GameResult.userWin;
    final bool matchDraw = gameState.result == GameResult.draw;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildGradientCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDividerLine(),
                if (!matchDraw) ...[
                  Text(
                    userWon ? 'YOU' : 'BOT',
                    style: _titleStyle(),
                  ),
                  const Text(
                    'WON',
                    style: _wonStyle,
                  ),
                  Text(
                    _getMatchSummary(gameState),
                    style: _summaryStyle,
                  ),
                ] else
                  const Text(
                    'MATCH DRAW',
                    style: _wonStyle,
                  ),
                _buildDividerLine(),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGradientCard({required Widget child}) {
    return Container(
      height: 160,
      width: 250,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Color(0xFF0C1E35), Colors.transparent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }

  Widget _buildDividerLine() {
    return Container(
      height: 4,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Color(0xFFC0A05F), Colors.transparent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  TextStyle _titleStyle() => const TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      );

  static const TextStyle _wonStyle = TextStyle(
    color: Colors.white,
    fontSize: 36,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle _summaryStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  String _getMatchSummary(GameState gameState) {
    switch (gameState.result) {
      case GameResult.userWin:
        return "BY ${gameState.userScore - gameState.botScore} RUN(S)";
      case GameResult.botWin:
        return "BY 1 WICKET(S)";
      case GameResult.draw:
      default:
        return "";
    }
  }

  Widget _buildPlayAgainButton(
      BuildContext context, GameProvider gameProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTransparentButton(
            label: 'PLAY AGAIN',
            onPressed: () {
              gameProvider.resetGame();
              gameProvider.startGame();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const GameScreen()),
              );
            },
          ),
          const SizedBox(width: 16),
          _buildGradientButton(
            label: 'MAIN MENU',
            onPressed: () {
              gameProvider.resetGame();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransparentButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 150,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white),
          ),
        ),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 150,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Ink(
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
          ),
          child: Container(
            alignment: Alignment.center,
            height: 60,
            width: double.infinity,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';

class ScoreDisplay extends StatelessWidget {
  final GameState gameState;
  final bool isUserside;

  const ScoreDisplay({
    super.key,
    required this.gameState,
    required this.isUserside,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBatting = isUserside
        ? gameState.phase == GamePhase.userBatting
        : gameState.phase == GamePhase.botBatting;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            isUserside ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          // Player name
          Container(
            width: double.infinity,
            height: 30,
            decoration: BoxDecoration(
              color:
                  isBatting ? const Color(0xFFb7bdd1) : const Color(0xFFFEF7E6),
            ),
            child: Align(
              alignment:
                  isUserside ? Alignment.centerLeft : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  isUserside ? GameStrings.userName : GameStrings.botName,
                  style: const TextStyle(
                    color: Color(0xFF0b1c32),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Score + icon (bat/ball)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment:
                  isUserside ? MainAxisAlignment.start : MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: isUserside
                  ? [
                      _buildStatusIcon(isBatting),
                      const SizedBox(width: 8),
                      _buildScoreText(),
                    ]
                  : [
                      _buildScoreText(),
                      const SizedBox(width: 8),
                      _buildStatusIcon(isBatting),
                    ],
            ),
          ),
        ],
      ),
    );
  }

  // Status icon (bat/ball inside circle)
  Widget _buildStatusIcon(bool isBatting) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: !isBatting ? const Color(0xFF5CC9F5) : const Color(0xFFB88747),
      ),
      padding: const EdgeInsets.all(4),
      child: Image.asset(
        isBatting ? 'assets/images/bat.png' : 'assets/images/ball.png',
        fit: BoxFit.contain,
      ),
    );
  }

  // Score Text
  Widget _buildScoreText() {
    final score = isUserside ? gameState.userScore : gameState.botScore;
    final wickets = _getWickets();
    return Text(
      '$score / $wickets',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  // Wicket logic
  String _getWickets() {
    if (isUserside) {
      return gameState.isUserOut ? '1' : '0';
    } else {
      return gameState.isBotOut ? '1' : '0';
    }
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';
import '../widgets/hand_gesture_widget.dart';
import '../widgets/score_display.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int? _selectedIndex;
  int _previousBallsBowled = 0; // Track previous ball count
  late AnimationController _timerController;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: GameRules.timerDuration),
    );
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final gameState = gameProvider.state;

        // Restart the timer when a new ball starts.
        if (gameState.timeRemaining == GameRules.timerDuration) {
          _timerController.reset();
          _timerController.forward();
        }

        // Reset the selected button only when a new ball has started.
        // That is, when the ballsBowled count has increased and the new ball is active.
        if (gameState.ballsBowled != _previousBallsBowled &&
            !gameState.isBallComplete) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedIndex = null;
                _previousBallsBowled = gameState.ballsBowled;
              });
            }
          });
        }

        if (gameState.phase == GamePhase.gameOver) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (gameProvider.wasDisconnected()) {
              _showDisconnectionPopup(context);
              return;
            }
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const ResultScreen(),
                  ),
                );
              }
            });
          });
        }

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background_stadium.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildTopInfoBar(gameState),
                  _buildBallScoreTracker(gameState),
                  Expanded(
                    child: _buildGameArea(gameState),
                  ),
                  _buildNumberSelectionButtons(gameProvider, gameState.phase),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDisconnectionPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 60, 87, 130),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color.fromARGB(255, 100, 130, 180),
                width: 2,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Match Ended',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  GameStrings.disconnected,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      final gameProvider = context.read<GameProvider>();
                      gameProvider.startGame();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const GameScreen()),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          GameStrings.restartGame,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopInfoBar(GameState gameState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Score displays on left and right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child:
                          ScoreDisplay(gameState: gameState, isUserside: true),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child:
                          ScoreDisplay(gameState: gameState, isUserside: false),
                    ),
                  ),
                ],
              ),

              // Center circular timer or info
              _buildGameInfo(gameState),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfo(GameState gameState) {
    return Column(
      children: [
        SizedBox(height: 20),
        _buildTimerCircle(),
        SizedBox(height: 10),
        Container(
          width: 150,
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF7E6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'OVER: ',
                style: TextStyle(
                  color: Color(0xFF0b1c32),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                gameState.ballsBowled == 6
                    ? '1.0'
                    : '0.${gameState.ballsBowled}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0b1c32), // Hex color #0b1c32
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 150,
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Color(0xFFb7bdd1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            // Center the text horizontally and vertically
            child: Text(
              gameState.phase == GamePhase.userBatting
                  ? '${GameStrings.userName} scored ${gameState.userScore} in ${gameState.ballsBowled} balls'
                  : '${GameStrings.botName} needs ${max((gameState.userScore + 1) - gameState.botScore, 0)} from ${6 - gameState.ballsBowled} balls',
              textAlign: TextAlign
                  .center, // Also center align text within the Text widget
              style: TextStyle(
                color: Color(0xFF0b1c32),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildTimerCircle() {
    return AnimatedBuilder(
      animation: _timerController,
      builder: (context, child) {
        return CircularPercentIndicator(
          radius: 30,
          lineWidth: 8,
          percent: _timerController.value,
          progressColor: const Color(0xFFBC9C5C),
          backgroundColor: const Color(0xFF0B1C32),
          circularStrokeCap: CircularStrokeCap.round,
          center: Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: Color(0xFF2A3F60),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_bottom_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameArea(GameState gameState) {
    final showHands = gameState.isBallComplete &&
        (gameState.userNumber != null || gameState.botNumber != null);

    return SizedBox.expand(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: HandGestureWidget(
              number: showHands ? gameState.botNumber : null,
              isUser: false,
            ),
          ),
        ),
        _buildGameActionInfo(gameState),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: HandGestureWidget(
              number: showHands ? gameState.userNumber : null,
              isUser: true,
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildGameActionInfo(GameState gameState) {
    if (!gameState.isBallComplete) {
      return Container(
        height: 80,
        alignment: Alignment.center,
        child: (gameState.phase == GamePhase.userBatting ||
                gameState.phase == GamePhase.botBatting)
            ? Text(
                gameState.phase == GamePhase.userBatting ? "" : "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              )
            : const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Color(0xFFC0A05F),
                  strokeWidth: 3,
                ),
              ),
      );
    } else {
      final isOut = gameState.userNumber == gameState.botNumber;

      return Container(
        height: 100,
        width: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              Color(0xFF0C1E35), // solid center
              Colors.transparent,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 4,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Color(0xFFC0A05F),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
            Text(
              isOut
                  ? GameStrings.out
                  : '${gameState.phase == GamePhase.userBatting ? gameState.userNumber : gameState.botNumber}',
              style: TextStyle(
                color: Colors.white,
                fontSize: isOut ? 28 : 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isOut)
              const Text(
                '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              )
            else
              Text(
                _numberToWord(
                  gameState.phase == GamePhase.userBatting
                      ? gameState.userNumber
                      : gameState.botNumber,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            Container(
              height: 4,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Color(0xFFC0A05F),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            )
          ],
        ),
      );
    }
  }

  String _numberToWord(int? number) {
    const words = {
      1: 'ONE',
      2: 'TWO',
      3: 'THREE',
      4: 'FOUR',
      5: 'FIVE',
      6: 'SIX',
    };
    return words[number] ?? '';
  }

  Widget _buildBallScoreTracker(GameState gameState) {
    final scores = gameState.phase == GamePhase.userBatting
        ? gameState.userBallScores
        : gameState.botBallScores;

    // Convert scores to List<int?> for null padding support
    final List<int?> last6 =
        List<int?>.from(scores.reversed.take(6).toList().reversed);

    // Pad with nulls to reach 6 items total
    while (last6.length < 6) {
      last6.add(null); // add at end to keep left-to-right order
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: last6.map((score) {
          return Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: score == null
                  ? Colors.transparent
                  : (score == -1
                      ? Colors.red
                      : const Color.fromARGB(255, 100, 130, 180)),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Center(
              child: Text(
                score == null ? '' : (score == -1 ? 'W' : '$score'),
                style: TextStyle(
                  color: score == -1 ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNumberSelectionButtons(
      GameProvider gameProvider, GamePhase phase) {
    final gameState = gameProvider.state;

    String actionText = phase == GamePhase.userBatting
        ? "Choose how many runs you want to hit on this ball"
        : "Choose a number to bowl";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF2A3F60),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            actionText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: List.generate(6, (index) {
              final bool isSelected = _selectedIndex == index;
              final bool isDisabled = gameState.isBallComplete;

              return GestureDetector(
                onTap: isDisabled
                    ? null
                    : () {
                        setState(() {
                          _selectedIndex = index;
                        });

                        if (phase == GamePhase.userBatting) {
                          gameProvider.userSelectNumber(index + 1);
                        } else {
                          gameProvider.userSelectBowlingNumber(index + 1);
                        }
                      },
                child: Container(
                  width: 40,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [
                              Color(0xFFF3DC8A),
                              Color(0xFFBD9E5E),
                              Color(0xFFF3DC8A),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : AppColors.buttonBg,
                    border: Border.all(
                      color: const Color(0xFFC0A15F),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}

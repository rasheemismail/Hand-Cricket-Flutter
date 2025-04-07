import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../utils/bot_logic.dart';
import '../utils/constants.dart';

class GameProvider extends ChangeNotifier {
  // Game state
  GameState _state = GameState.initial();
  GameState get state => _state;

  // Bot logic
  final BotLogic _botLogic = BotLogic();

  // Timer for user input
  Timer? _timer;

  // Start a new game
  void startGame() {
    _state = GameState.initial().copyWith(
      phase: GamePhase.userBatting,
      timeRemaining: GameRules.timerDuration,
      userBallScores: [],
      botBallScores: [],
    );
    _startTimer();
    notifyListeners();
  }

  // Reset the game
  void resetGame() {
    _cancelTimer();
    _state = GameState.initial();
    notifyListeners();
  }

  // User selects a number
  void userSelectNumber(int number) {
    if (_state.phase != GamePhase.userBatting ||
        _state.isBallComplete ||
        _state.isUserOut) {
      return;
    }

    _cancelTimer();

    // User has made a choice, now get bot's choice
    final botNumber = _botLogic.getRandomNumber();

    bool isOut = number == botNumber;
    int newScore = isOut ? _state.userScore : _state.userScore + number;
    int newBallsBowled = _state.ballsBowled + 1;

    final updatedUserBallScores = List<int>.from(_state.userBallScores)
      ..add(isOut ? 0 : number);

    _state = _state.copyWith(
      userNumber: number,
      botNumber: botNumber,
      userScore: newScore,
      isUserOut: isOut,
      ballsBowled: newBallsBowled,
      isBallComplete: true,
      userBallScores: updatedUserBallScores,
    );

    notifyListeners();

    // Continue to next step after a delay
    Timer(const Duration(seconds: 2), () {
      _processUserInningsEnd(isOut, newBallsBowled);
    });
  }

  // Process the end of user's innings
  void _processUserInningsEnd(bool isOut, int ballsBowled) {
    if (isOut || ballsBowled >= GameRules.maxBalls) {
      // User's innings is over, start bot's innings
      _state = _state.copyWith(
        phase: GamePhase.botBatting,
        ballsBowled: 0,
        userNumber: null,
        botNumber: null,
        isBallComplete: false,
      );
      notifyListeners();
      _botBatting();
    } else {
      // Continue user's innings
      _state = _state.copyWith(
        userNumber: null,
        botNumber: null,
        isBallComplete: false,
        timeRemaining: GameRules.timerDuration,
      );
      _startTimer();
      notifyListeners();
    }
  }

  // Bot's batting turn
  void _botBatting() {
    // Reset state for bot's batting turn and wait for user to choose a number
    _state = _state.copyWith(
      userNumber: null,
      botNumber: null,
      isBallComplete: false,
      timeRemaining: GameRules.timerDuration,
    );
    _startTimer();
    notifyListeners();
  }

  // User selects a number when bowling (bot batting)
  void userSelectBowlingNumber(int number) {
    if (_state.phase != GamePhase.botBatting ||
        _state.isBallComplete ||
        _state.isBotOut) {
      return;
    }

    _cancelTimer();

    // User has made a bowling choice, now get bot's batting choice
    final botNumber = _botLogic.getSmartNumber(
      userScore: _state.userScore,
      botScore: _state.botScore,
      remainingBalls: GameRules.maxBalls - _state.ballsBowled,
      isBotBatting: true,
    );

    bool isOut = number == botNumber;
    int newScore = isOut ? _state.botScore : _state.botScore + botNumber;
    int newBallsBowled = _state.ballsBowled + 1;

    final updatedBotBallScores = List<int>.from(_state.botBallScores)
      ..add(isOut ? 0 : botNumber);

    // Check if bot has won
    GameResult gameResult = _state.result;
    if (newScore > _state.userScore && !isOut) {
      gameResult = GameResult.botWin;
    }

    _state = _state.copyWith(
      userNumber: number,
      botNumber: botNumber,
      botScore: newScore,
      isBotOut: isOut,
      ballsBowled: newBallsBowled,
      isBallComplete: true,
      result: gameResult,
      botBallScores: updatedBotBallScores,
    );

    notifyListeners();

    // If the bot is out, we need a slightly longer delay to show the out animation
    final delay =
        isOut ? const Duration(seconds: 2) : const Duration(seconds: 2);

    // Continue to next step after a delay
    Timer(delay, () {
      _processBotInningsEnd(isOut, newBallsBowled, newScore);
    });
  }

  // Process the end of bot's innings
  void _processBotInningsEnd(bool isOut, int ballsBowled, int botScore) {
    // If bot is out, make sure the bot score doesn't change from this point
    if (isOut) {
      // Ensure we're using the correct score when the bot is out
      botScore = _state.botScore;
    }

    if (isOut ||
        ballsBowled >= GameRules.maxBalls ||
        botScore > _state.userScore) {
      // Bot's innings is over, end the game
      GameResult finalResult;

      // Final comparison using the actual state scores to ensure accuracy
      final finalBotScore = isOut ? _state.botScore : botScore;

      if (finalBotScore > _state.userScore) {
        finalResult = GameResult.botWin;
      } else if (finalBotScore < _state.userScore) {
        finalResult = GameResult.userWin;
      } else {
        finalResult = GameResult.draw;
      }

      _state = _state.copyWith(
        phase: GamePhase.gameOver,
        result: finalResult,
        botScore: finalBotScore, // Make sure the score is correctly set
      );
    } else {
      // Continue bot's innings
      _state = _state.copyWith(
        userNumber: null,
        botNumber: null,
        isBallComplete: false,
      );
      _botBatting();
    }

    notifyListeners();
  }

  // Start the timer for user input
  void _startTimer() {
    _cancelTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.timeRemaining <= 1) {
        _handleTimeUp();
      } else {
        _state = _state.copyWith(
          timeRemaining: _state.timeRemaining - 1,
        );
        notifyListeners();
      }
    });
  }

  // Handle when time is up for user input
  void _handleTimeUp() {
    _cancelTimer();

    // User didn't make a choice in time
    _state = _state.copyWith(
      phase: GamePhase.gameOver,
      result: GameResult.botWin,
      timeRemaining: 0,
    );
    notifyListeners();
  }

  // Check if user was disconnected
  bool wasDisconnected() {
    return _state.phase == GamePhase.gameOver && _state.timeRemaining == 0;
  }

  // Cancel the timer
  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}

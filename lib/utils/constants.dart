import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF0b1c32);
  static const secondary = const Color(0xFFFEF7E6);
  static const background = Color(0xFF1A2C42); // Dark blue background
  static const textLight = Colors.white;
  static const textDark = Color.fromARGB(255, 17, 53, 97);
  static const buttonBg = Color(0xFF0B1C32); // Off-white for buttons
  static const accentYellow = Color(0xFFFFD166);
}

class GameRules {
  static const int maxBalls = 6;
  static const int timerDuration = 6;
  static const List<int> validNumbers = [1, 2, 3, 4, 5, 6];
}

class GameStrings {
  static const String appTitle = 'Hand Cricket';
  static const String startGame = 'START GAME';
  static const String restartGame = 'RESTART GAME';

  static const String yourTurn = 'Your Turn';
  static const String botTurn = 'Bot\'s Turn';
  static const String youWin = 'You Win!';
  static const String botWins = 'Bot Wins!';
  static const String yourScore = 'Your Score';
  static const String botScore = 'Bot Score';
  static const String gameOver = 'Game Over';
  static const String batting = 'BATTING';
  static const String bowling = 'BOWLING';
  static const String playAgain = 'PLAY AGAIN';
  static const String chooseNumber = 'Choose a number (1-6)';
  static const String disconnected = 'You got disconnected';
  static const String out = 'WICKET!';
  static const String timeUp = 'Time\'s up!';
  static const String userName = 'You';
  static const String botName = 'Bot';
}

enum GamePhase { notStarted, userBatting, botBatting, gameOver }

enum GameResult { inProgress, userWin, botWin, draw }

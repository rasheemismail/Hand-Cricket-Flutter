import '../utils/constants.dart';

class GameState {
  // Current phase of the game
  final GamePhase phase;

  // Scores
  final int userScore;
  final int botScore;

  // Current over information
  final int ballsBowled;

  // Currently selected numbers
  final int? userNumber;
  final int? botNumber;

  // Is the user out?
  final bool isUserOut;

  // Is the bot out?
  final bool isBotOut;

  // Result of the game
  final GameResult result;

  // Time remaining for user to make a choice
  final int timeRemaining;

  // Has current ball been played
  final bool isBallComplete;

  // ✅ New: Ball-by-ball scores
  final List<int> userBallScores;
  final List<int> botBallScores;

  GameState({
    required this.phase,
    required this.userScore,
    required this.botScore,
    required this.ballsBowled,
    this.userNumber,
    this.botNumber,
    required this.isUserOut,
    required this.isBotOut,
    required this.result,
    required this.timeRemaining,
    required this.isBallComplete,
    required this.userBallScores,
    required this.botBallScores,
  });

  factory GameState.initial() {
    return GameState(
      phase: GamePhase.notStarted,
      userScore: 0,
      botScore: 0,
      ballsBowled: 0,
      userNumber: null,
      botNumber: null,
      isUserOut: false,
      isBotOut: false,
      result: GameResult.inProgress,
      timeRemaining: GameRules.timerDuration,
      isBallComplete: false,
      userBallScores: [],
      botBallScores: [],
    );
  }

  GameState copyWith({
    GamePhase? phase,
    int? userScore,
    int? botScore,
    int? ballsBowled,
    int? userNumber,
    int? botNumber,
    bool? isUserOut,
    bool? isBotOut,
    GameResult? result,
    int? timeRemaining,
    bool? isBallComplete,
    List<int>? userBallScores,
    List<int>? botBallScores,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      userScore: userScore ?? this.userScore,
      botScore: botScore ?? this.botScore,
      ballsBowled: ballsBowled ?? this.ballsBowled,
      userNumber: userNumber ?? this.userNumber,
      botNumber: botNumber ?? this.botNumber,
      isUserOut: isUserOut ?? this.isUserOut,
      isBotOut: isBotOut ?? this.isBotOut,
      result: result ?? this.result,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isBallComplete: isBallComplete ?? this.isBallComplete,
      userBallScores: userBallScores ?? this.userBallScores,
      botBallScores: botBallScores ?? this.botBallScores,
    );
  }
}

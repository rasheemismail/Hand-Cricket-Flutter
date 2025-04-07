import 'dart:math';
import 'constants.dart';

class BotLogic {
  final Random _random = Random();
  
  /// Returns a random number between 1 and 6 for the bot's turn
  int getRandomNumber() {
    return GameRules.validNumbers[_random.nextInt(GameRules.validNumbers.length)];
  }
  
  /// Returns a "smarter" number based on game context
  /// This makes the bot play more strategically depending on the situation
  int getSmartNumber({
    required int userScore,
    required int botScore,
    required int remainingBalls,
    required bool isBotBatting,
  }) {
    // If bot is batting and needs to score more than 3 runs per ball on average to win
    if (isBotBatting && 
        remainingBalls > 0 && 
        (userScore - botScore) / remainingBalls > 3) {
      // Bot needs to score quickly - bias toward higher numbers
      return 4 + _random.nextInt(3); // Returns 4, 5, or 6
    }
    
    // If bot is bowling and user is batting well
    if (!isBotBatting && userScore > 12) {
      // Try to guess numbers the user might pick more often
      // Users often pick 4 and 6 for higher scores
      List<int> commonUserChoices = [4, 6, 3, 5, 2, 1];
      return commonUserChoices[_random.nextInt(3)]; // Pick from the first 3 most common
    }
    
    // Last ball and bot needs a specific number to win
    if (isBotBatting && 
        remainingBalls == 1 && 
        userScore - botScore <= 6 && 
        userScore - botScore > 0) {
      // Try to hit the exact number needed to win
      return userScore - botScore;
    }
    
    // Default to random choice
    return getRandomNumber();
  }
}
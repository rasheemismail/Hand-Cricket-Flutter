import 'package:flutter_test/flutter_test.dart';
import 'package:cricket/utils/bot_logic.dart';

void main() {
  group('BotLogic', () {
    final bot = BotLogic();

    test('getRandomNumber returns between 1 and 6', () {
      for (int i = 0; i < 100; i++) {
        final num = bot.getRandomNumber();
        expect(num >= 1 && num <= 6, isTrue);
      }
    });

    test('getSmartNumber returns exact number needed on last ball to win', () {
      // This config should always hit the deterministic block in logic
      const userScore = 26;
      const botScore = 21;
      const remainingBalls = 1;

      final number = bot.getSmartNumber(
        userScore: userScore,
        botScore: botScore,
        remainingBalls: remainingBalls,
        isBotBatting: true,
      );

      expect(number, userScore - botScore); // 5
    });
  });
}

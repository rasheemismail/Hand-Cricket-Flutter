import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cricket/providers/game_provider.dart';
import 'package:cricket/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen shows Start Game button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GameProvider(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Verify the Start Game button is present
    expect(find.text('START GAME'), findsOneWidget);
  });
}

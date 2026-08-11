import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nagardrishti/src/features/auth/data/auth_repository.dart';
import 'package:nagardrishti/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nagardrishti/src/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('Vikasit Nagpur LoginScreen renders app title and citizen login', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FirebaseAuthRepository()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump();

    // Verify app header title
    expect(find.text('Vikasit Nagpur'), findsOneWidget);
    expect(find.text('Login as Citizen'), findsOneWidget);
  });
}

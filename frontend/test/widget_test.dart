import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/main.dart';
import 'features/auth/auth_cubit_test.dart';

void main() {
  setUp(() async {
    await sl.reset();
    await initServiceLocator();
    // Swap repository with fake implementation
    sl.unregister<AuthRepository>();
    sl.registerLazySingleton<AuthRepository>(() => FakeAuthRepository());
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('Renders LoginPage when user is unauthenticated', (WidgetTester tester) async {
    await tester.pumpWidget(const CustomerManagementApp());
    await tester.pumpAndSettle();

    expect(find.text('Sign in to AI Helpdesk'), findsOneWidget);
    expect(find.text('Enter your credentials to access the workspace'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}

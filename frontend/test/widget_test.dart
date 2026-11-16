import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:frontend/main.dart';
import 'features/auth/auth_cubit_test.dart';

void main() {
  setUp(() async {
    await initServiceLocator();
    // Swap repository with fake implementation
    sl.unregister<AuthRepository>();
    sl.registerLazySingleton<AuthRepository>(() => FakeAuthRepository());
  });

  testWidgets('Renders LoginPage when user is unauthenticated', (WidgetTester tester) async {
    await tester.pumpWidget(const CustomerManagementApp());

    // Initial check redirects to /login when unauthenticated
    await sl<AuthCubit>().checkAuthStatus();
    await tester.pumpAndSettle();

    expect(find.text('Helpdesk Admin'), findsOneWidget);
    expect(find.text('AI Customer Management Portal'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}

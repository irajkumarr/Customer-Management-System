import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  final AuthCubit authCubit;

  AppRouter({required this.authCubit});

  late final GoRouter router = GoRouter(
    initialLocation: '/tickets',
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final authState = authCubit.state;
      final isLoggingIn = state.matchedLocation == '/login';

      final isAuthenticated = authState is Authenticated;
      final isUnauthenticated = authState is Unauthenticated || authState is AuthFailure;

      if (isUnauthenticated && !isLoggingIn) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/tickets';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/tickets',
        name: 'tickets',
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('Tickets Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => context.read<AuthCubit>().logout(),
              ),
            ],
          ),
          body: const Center(
            child: Text('Tickets Dashboard Placeholder'),
          ),
        ),
        routes: [
          GoRoute(
            path: ':id',
            name: 'ticket-detail',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return Scaffold(
                appBar: AppBar(title: Text('Ticket #$id')),
                body: Center(child: Text('Ticket Detail for $id')),
              );
            },
          ),
        ],
      ),
    ],
  );
}

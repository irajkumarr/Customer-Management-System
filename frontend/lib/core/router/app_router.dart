import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/tickets/presentation/bloc/ticket_list_cubit.dart';
import '../../features/tickets/presentation/pages/ticket_dashboard_page.dart';
import '../di/service_locator.dart';

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
        builder: (context, state) => BlocProvider<TicketListCubit>(
          create: (_) => sl<TicketListCubit>(),
          child: const TicketDashboardPage(),
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

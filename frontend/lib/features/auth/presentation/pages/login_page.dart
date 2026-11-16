import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_card.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Subtle radial ambient glow matching CognitiveDesk
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.1),
                  radius: 1.1,
                  colors: isDark
                      ? [
                          const Color(0xFF1E1B4B).withValues(alpha: 0.25),
                          AppColors.backgroundDark,
                        ]
                      : [
                          const Color(0xFFEEF2FF).withValues(alpha: 0.85),
                          const Color(0xFFF8FAFC),
                        ],
                ),
              ),
            ),
          ),
          BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is Authenticated) {
                context.go('/overview');
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.statusEscalated,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                  child: LoginCard(
                    authState: state,
                    onSubmit: (username, password) {
                      context.read<AuthCubit>().login(username, password);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

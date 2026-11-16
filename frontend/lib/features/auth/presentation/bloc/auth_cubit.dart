import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/check_session_status_usecase.dart';
import '../../domain/usecases/get_current_admin_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUsecase loginUseCase;
  final CheckSessionStatusUseCase checkSessionStatusUseCase;
  final GetCurrentAdminUseCase getCurrentAdminUseCase;
  final LogoutUseCase logoutUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.checkSessionStatusUseCase,
    required this.getCurrentAdminUseCase,
    required this.logoutUseCase,
  }) : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    final statusResult = await checkSessionStatusUseCase(const NoParams());

    await statusResult.fold(
      (failure) async {
        emit(const Unauthenticated());
      },
      (status) async {
        if (status.isAuthenticated) {
          final adminResult = await getCurrentAdminUseCase(const NoParams());
          adminResult.fold(
            (failure) => emit(const Unauthenticated()),
            (admin) => emit(Authenticated(admin)),
          );
        } else {
          // Automatic single-admin session initialization for Helpdesk workspace
          await login('admin', 'Admin@123456');
        }
      },
    );
  }

  Future<void> login(String username, String password) async {
    emit(const AuthLoading());
    final result = await loginUseCase(
      LoginParams(
        username: username,
        password: password,
      ),
    );

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (admin) => emit(Authenticated(admin)),
    );
  }

  Future<void> logout() async {
    emit(const AuthLoading());
    final result = await logoutUseCase(const NoParams());
    result.fold(
      (failure) => emit(const Unauthenticated(message: 'Logged out')),
      (_) => emit(const Unauthenticated(message: 'Logged out successfully')),
    );
  }
}

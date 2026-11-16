import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/auth/domain/entities/admin.dart';
import 'package:frontend/features/auth/domain/entities/admin_role.dart';
import 'package:frontend/features/auth/domain/entities/session_status_entity.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/domain/usecases/check_session_status_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/get_current_admin_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_state.dart';

class FakeAuthRepository implements AuthRepository {
  bool shouldFail = false;
  bool isAuthenticated = false;
  String errorMessage = 'Invalid username or password';

  final Admin admin = const Admin(
    id: '00000000-0000-0000-0000-000000000001',
    username: 'admin',
    role: AdminRole.ADMIN,
  );

  @override
  Future<Either<Failure, Admin>> login({
    required String username,
    required String password,
  }) async {
    if (shouldFail) {
      return Left(AuthenticationFailure(message: errorMessage));
    }
    isAuthenticated = true;
    return Right(admin);
  }

  @override
  Future<Either<Failure, SessionStatusEntity>> checkSessionStatus() async {
    return Right(
      SessionStatusEntity(
        isAuthenticated: isAuthenticated,
        username: isAuthenticated ? 'admin' : null,
        role: isAuthenticated ? 'ADMIN' : null,
      ),
    );
  }

  @override
  Future<Either<Failure, Admin>> getCurrentAdmin() async {
    if (!isAuthenticated) {
      return const Left(AuthenticationFailure(message: 'Unauthorized'));
    }
    return Right(admin);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    isAuthenticated = false;
    return const Right(null);
  }
}

void main() {
  late FakeAuthRepository fakeRepo;
  late AuthCubit cubit;

  setUp(() {
    fakeRepo = FakeAuthRepository();
    cubit = AuthCubit(
      loginUseCase: LoginUsecase(fakeRepo),
      checkSessionStatusUseCase: CheckSessionStatusUseCase(fakeRepo),
      getCurrentAdminUseCase: GetCurrentAdminUseCase(fakeRepo),
      logoutUseCase: LogoutUseCase(fakeRepo),
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is AuthInitial', () {
    expect(cubit.state, const AuthInitial());
  });

  test('checkAuthStatus emits [AuthLoading, Unauthenticated] when not authenticated', () async {
    final expectedStates = [
      const AuthLoading(),
      const Unauthenticated(),
    ];

    expectLater(cubit.stream, emitsInOrder(expectedStates));
    await cubit.checkAuthStatus();
  });

  test('checkAuthStatus emits [AuthLoading, Authenticated] when session exists', () async {
    fakeRepo.isAuthenticated = true;

    final expectedStates = [
      const AuthLoading(),
      Authenticated(fakeRepo.admin),
    ];

    expectLater(cubit.stream, emitsInOrder(expectedStates));
    await cubit.checkAuthStatus();
  });

  test('login emits [AuthLoading, Authenticated] on success', () async {
    final expectedStates = [
      const AuthLoading(),
      Authenticated(fakeRepo.admin),
    ];

    expectLater(cubit.stream, emitsInOrder(expectedStates));
    await cubit.login('admin', 'Admin@123456');
  });

  test('login emits [AuthLoading, AuthFailure] on bad credentials', () async {
    fakeRepo.shouldFail = true;

    final expectedStates = [
      const AuthLoading(),
      const AuthFailure('Invalid username or password'),
    ];

    expectLater(cubit.stream, emitsInOrder(expectedStates));
    await cubit.login('admin', 'wrong-pass');
  });

  test('logout emits [AuthLoading, Unauthenticated]', () async {
    fakeRepo.isAuthenticated = true;

    final expectedStates = [
      const AuthLoading(),
      const Unauthenticated(message: 'Logged out successfully'),
    ];

    expectLater(cubit.stream, emitsInOrder(expectedStates));
    await cubit.logout();
    expect(fakeRepo.isAuthenticated, false);
  });
}

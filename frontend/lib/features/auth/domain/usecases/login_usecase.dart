import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/admin.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String username;
  final String password;

  const LoginParams({
    required this.username,
    required this.password,
  });
}

class LoginUsecase implements Usecase<Admin, LoginParams> {
  final AuthRepository _authRepository;

  LoginUsecase(this._authRepository);

  @override
  Future<Either<Failure, Admin>> call(LoginParams params) async {
    return await _authRepository.login(
      username: params.username,
      password: params.password,
    );
  }
}

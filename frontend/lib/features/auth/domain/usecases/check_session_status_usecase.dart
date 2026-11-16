import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/session_status_entity.dart';
import '../repositories/auth_repository.dart';

class CheckSessionStatusUseCase implements Usecase<SessionStatusEntity, NoParams> {
  final AuthRepository _authRepository;

  CheckSessionStatusUseCase(this._authRepository);

  @override
  Future<Either<Failure, SessionStatusEntity>> call(NoParams params) async {
    return await _authRepository.checkSessionStatus();
  }
}

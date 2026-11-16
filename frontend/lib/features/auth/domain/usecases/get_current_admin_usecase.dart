import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/admin.dart';
import '../repositories/auth_repository.dart';

class GetCurrentAdminUseCase implements Usecase<Admin, NoParams> {
  final AuthRepository _authRepository;

  GetCurrentAdminUseCase(this._authRepository);

  @override
  Future<Either<Failure, Admin>> call(NoParams params) async {
    return await _authRepository.getCurrentAdmin();
  }
}

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin.dart';
import '../entities/session_status_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, Admin>> login({
    required String username,
    required String password,
  });

  Future<Either<Failure, SessionStatusEntity>> checkSessionStatus();

  Future<Either<Failure, Admin>> getCurrentAdmin();

  Future<Either<Failure, void>> logout();
}

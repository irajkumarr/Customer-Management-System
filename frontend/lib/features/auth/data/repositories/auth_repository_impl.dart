import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/admin.dart';
import '../../domain/entities/session_status_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/admin_profile.dart';
import '../models/session_status.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  Failure _mapExceptionToFailure(Object exception) {
    if (exception is ApiException) {
      if (exception.isUnauthorized) {
        return AuthenticationFailure(message: exception.message, statusCode: exception.statusCode);
      }
      return ServerFailure(message: exception.message, statusCode: exception.statusCode);
    }
    return ServerFailure(message: exception.toString());
  }

  @override
  Future<Either<Failure, Admin>> login({
    required String username,
    required String password,
  }) async {
    try {
      final model = await remoteDataSource.login(username, password);
      return Right(model.toEntity());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, SessionStatusEntity>> checkSessionStatus() async {
    try {
      final model = await remoteDataSource.checkSessionStatus();
      return Right(model.toEntity());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Admin>> getCurrentAdmin() async {
    try {
      final model = await remoteDataSource.getCurrentAdmin();
      return Right(model.toEntity());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }
}

import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../router/app_router.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_session_status_usecase.dart';
import '../../features/auth/domain/usecases/get_current_admin_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator({
  String? baseUrl,
  ApiClient? customApiClient,
}) async {
  // Reset if re-initializing in tests
  if (sl.isRegistered<ApiClient>()) {
    await sl.reset();
  }

  // Network Layer
  sl.registerLazySingleton<ApiClient>(
    () => customApiClient ?? ApiClient(baseUrl: baseUrl),
  );

  // Auth - Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Auth - Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
  );

  // Auth - Use Cases
  sl.registerLazySingleton(() => LoginUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => CheckSessionStatusUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentAdminUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));

  // Auth - Presentation (Cubit)
  sl.registerLazySingleton(
    () => AuthCubit(
      loginUseCase: sl<LoginUsecase>(),
      checkSessionStatusUseCase: sl<CheckSessionStatusUseCase>(),
      getCurrentAdminUseCase: sl<GetCurrentAdminUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
    ),
  );

  // Router
  sl.registerLazySingleton<AppRouter>(
    () => AppRouter(authCubit: sl<AuthCubit>()),
  );
}

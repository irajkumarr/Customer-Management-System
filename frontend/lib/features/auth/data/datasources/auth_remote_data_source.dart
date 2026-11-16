import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/admin_profile.dart';
import '../models/session_status.dart';

abstract class AuthRemoteDataSource {
  Future<AdminProfile> login(String username, String password);
  Future<SessionStatus> checkSessionStatus();
  Future<AdminProfile> getCurrentAdmin();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AdminProfile> login(String username, String password) async {
    final response = await apiClient.post<AdminProfile>(
      ApiConstants.login,
      data: {
        'username': username.trim(),
        'password': password,
      },
      fromJsonT: (data) => AdminProfile.fromJson(data as Map<String, dynamic>),
    );

    final profile = response.data;
    if (profile == null) {
      throw const ApiException(message: 'Login succeeded but admin profile was empty.');
    }
    return profile;
  }

  @override
  Future<SessionStatus> checkSessionStatus() async {
    final response = await apiClient.get<SessionStatus>(
      ApiConstants.authStatus,
      fromJsonT: (data) => SessionStatus.fromJson(data as Map<String, dynamic>),
    );

    return response.data ?? const SessionStatus(authenticated: false);
  }

  @override
  Future<AdminProfile> getCurrentAdmin() async {
    final response = await apiClient.get<AdminProfile>(
      ApiConstants.authMe,
      fromJsonT: (data) => AdminProfile.fromJson(data as Map<String, dynamic>),
    );

    final profile = response.data;
    if (profile == null) {
      throw const ApiException(message: 'Failed to retrieve admin profile.');
    }
    return profile;
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.rawPost(ApiConstants.logout);
    } catch (_) {
      // Ignore network failures on logout so local session clearance succeeds
    } finally {
      await apiClient.clearCookies();
    }
  }
}

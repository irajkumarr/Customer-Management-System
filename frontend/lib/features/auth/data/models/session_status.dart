import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/session_status_entity.dart';

part 'session_status.freezed.dart';
part 'session_status.g.dart';

@freezed
abstract class SessionStatus with _$SessionStatus {
  const factory SessionStatus({
    required bool authenticated,
    String? username,
    String? role,
  }) = _SessionStatus;

  factory SessionStatus.fromJson(Map<String, dynamic> json) => _$SessionStatusFromJson(json);
}

extension SessionStatusX on SessionStatus {
  SessionStatusEntity toEntity() => SessionStatusEntity(
        isAuthenticated: authenticated,
        username: username,
        role: role,
      );
}

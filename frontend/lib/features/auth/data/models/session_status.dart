import 'package:freezed_annotation/freezed_annotation.dart';

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

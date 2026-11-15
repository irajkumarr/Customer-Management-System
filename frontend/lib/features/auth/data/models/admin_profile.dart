import 'package:freezed_annotation/freezed_annotation.dart';
import 'admin_role.dart';

part 'admin_profile.freezed.dart';
part 'admin_profile.g.dart';

@freezed
abstract class AdminProfile with _$AdminProfile {
  const factory AdminProfile({
    required String id,
    required String username,
    required AdminRole role,
  }) = _AdminProfile;

  factory AdminProfile.fromJson(Map<String, dynamic> json) => _$AdminProfileFromJson(json);
}

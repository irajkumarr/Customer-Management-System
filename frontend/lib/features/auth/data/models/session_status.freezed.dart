// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionStatus {

 bool get authenticated; String? get username; String? get role;
/// Create a copy of SessionStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionStatusCopyWith<SessionStatus> get copyWith => _$SessionStatusCopyWithImpl<SessionStatus>(this as SessionStatus, _$identity);

  /// Serializes this SessionStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SessionStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionStatus&&(identical(other.authenticated, _this.authenticated) || other.authenticated == _this.authenticated)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.role, _this.role) || other.role == _this.role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SessionStatus;
  return Object.hash(runtimeType,_this.authenticated,_this.username,_this.role);
}

@override
String toString() {
  final _this = this as SessionStatus;
  return 'SessionStatus(authenticated: ${_this.authenticated}, username: ${_this.username}, role: ${_this.role})';
}


}

/// @nodoc
abstract mixin class $SessionStatusCopyWith<$Res>  {
  factory $SessionStatusCopyWith(SessionStatus value, $Res Function(SessionStatus) _then) = _$SessionStatusCopyWithImpl;
@useResult
$Res call({
 bool authenticated, String? username, String? role
});




}
/// @nodoc
class _$SessionStatusCopyWithImpl<$Res>
    implements $SessionStatusCopyWith<$Res> {
  _$SessionStatusCopyWithImpl(this._self, this._then);

  final SessionStatus _self;
  final $Res Function(SessionStatus) _then;

/// Create a copy of SessionStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? authenticated = null,Object? username = freezed,Object? role = freezed,}) {
  return _then(SessionStatus(
authenticated: null == authenticated ? _self.authenticated : authenticated // ignore: cast_nullable_to_non_nullable
as bool,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionStatus].
extension SessionStatusPatterns on SessionStatus {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionStatus() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionStatus value)  $default,){
final _that = this;
switch (_that) {
case _SessionStatus():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SessionStatus() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool authenticated,  String? username,  String? role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionStatus() when $default != null:
return $default(_that.authenticated,_that.username,_that.role);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool authenticated,  String? username,  String? role)  $default,) {final _that = this;
switch (_that) {
case _SessionStatus():
return $default(_that.authenticated,_that.username,_that.role);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool authenticated,  String? username,  String? role)?  $default,) {final _that = this;
switch (_that) {
case _SessionStatus() when $default != null:
return $default(_that.authenticated,_that.username,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionStatus implements SessionStatus {
  const _SessionStatus({required this.authenticated, this.username, this.role});
  factory _SessionStatus.fromJson(Map<String, dynamic> json) => _$SessionStatusFromJson(json);

@override final  bool authenticated;
@override final  String? username;
@override final  String? role;

/// Create a copy of SessionStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionStatusCopyWith<_SessionStatus> get copyWith => __$SessionStatusCopyWithImpl<_SessionStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionStatus&&(identical(other.authenticated, authenticated) || other.authenticated == authenticated)&&(identical(other.username, username) || other.username == username)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,authenticated,username,role);
}

@override
String toString() {
    return 'SessionStatus(authenticated: $authenticated, username: $username, role: $role)';
}


}

/// @nodoc
abstract mixin class _$SessionStatusCopyWith<$Res> implements $SessionStatusCopyWith<$Res> {
  factory _$SessionStatusCopyWith(_SessionStatus value, $Res Function(_SessionStatus) _then) = __$SessionStatusCopyWithImpl;
@override @useResult
$Res call({
 bool authenticated, String? username, String? role
});




}
/// @nodoc
class __$SessionStatusCopyWithImpl<$Res>
    implements _$SessionStatusCopyWith<$Res> {
  __$SessionStatusCopyWithImpl(this._self, this._then);

  final _SessionStatus _self;
  final $Res Function(_SessionStatus) _then;

/// Create a copy of SessionStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? authenticated = null,Object? username = freezed,Object? role = freezed,}) {
  return _then(_SessionStatus(
authenticated: null == authenticated ? _self.authenticated : authenticated // ignore: cast_nullable_to_non_nullable
as bool,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

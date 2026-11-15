// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ticket_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TicketStats {

 int get total; int get newTickets; int get aiProcessing; int get aiReplied; int get escalatedToHuman; int get inProgress; int get resolved; int get closed; Map<String, int> get byCategory;
/// Create a copy of TicketStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TicketStatsCopyWith<TicketStats> get copyWith => _$TicketStatsCopyWithImpl<TicketStats>(this as TicketStats, _$identity);

  /// Serializes this TicketStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TicketStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TicketStats&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.newTickets, _this.newTickets) || other.newTickets == _this.newTickets)&&(identical(other.aiProcessing, _this.aiProcessing) || other.aiProcessing == _this.aiProcessing)&&(identical(other.aiReplied, _this.aiReplied) || other.aiReplied == _this.aiReplied)&&(identical(other.escalatedToHuman, _this.escalatedToHuman) || other.escalatedToHuman == _this.escalatedToHuman)&&(identical(other.inProgress, _this.inProgress) || other.inProgress == _this.inProgress)&&(identical(other.resolved, _this.resolved) || other.resolved == _this.resolved)&&(identical(other.closed, _this.closed) || other.closed == _this.closed)&&const DeepCollectionEquality().equals(other.byCategory, _this.byCategory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TicketStats;
  return Object.hash(runtimeType,_this.total,_this.newTickets,_this.aiProcessing,_this.aiReplied,_this.escalatedToHuman,_this.inProgress,_this.resolved,_this.closed,const DeepCollectionEquality().hash(_this.byCategory));
}

@override
String toString() {
  final _this = this as TicketStats;
  return 'TicketStats(total: ${_this.total}, newTickets: ${_this.newTickets}, aiProcessing: ${_this.aiProcessing}, aiReplied: ${_this.aiReplied}, escalatedToHuman: ${_this.escalatedToHuman}, inProgress: ${_this.inProgress}, resolved: ${_this.resolved}, closed: ${_this.closed}, byCategory: ${_this.byCategory})';
}


}

/// @nodoc
abstract mixin class $TicketStatsCopyWith<$Res>  {
  factory $TicketStatsCopyWith(TicketStats value, $Res Function(TicketStats) _then) = _$TicketStatsCopyWithImpl;
@useResult
$Res call({
 int total, int newTickets, int aiProcessing, int aiReplied, int escalatedToHuman, int inProgress, int resolved, int closed, Map<String, int> byCategory
});




}
/// @nodoc
class _$TicketStatsCopyWithImpl<$Res>
    implements $TicketStatsCopyWith<$Res> {
  _$TicketStatsCopyWithImpl(this._self, this._then);

  final TicketStats _self;
  final $Res Function(TicketStats) _then;

/// Create a copy of TicketStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? newTickets = null,Object? aiProcessing = null,Object? aiReplied = null,Object? escalatedToHuman = null,Object? inProgress = null,Object? resolved = null,Object? closed = null,Object? byCategory = null,}) {
  return _then(TicketStats(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,newTickets: null == newTickets ? _self.newTickets : newTickets // ignore: cast_nullable_to_non_nullable
as int,aiProcessing: null == aiProcessing ? _self.aiProcessing : aiProcessing // ignore: cast_nullable_to_non_nullable
as int,aiReplied: null == aiReplied ? _self.aiReplied : aiReplied // ignore: cast_nullable_to_non_nullable
as int,escalatedToHuman: null == escalatedToHuman ? _self.escalatedToHuman : escalatedToHuman // ignore: cast_nullable_to_non_nullable
as int,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as int,resolved: null == resolved ? _self.resolved : resolved // ignore: cast_nullable_to_non_nullable
as int,closed: null == closed ? _self.closed : closed // ignore: cast_nullable_to_non_nullable
as int,byCategory: null == byCategory ? _self.byCategory : byCategory // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [TicketStats].
extension TicketStatsPatterns on TicketStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TicketStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TicketStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TicketStats value)  $default,){
final _that = this;
switch (_that) {
case _TicketStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TicketStats value)?  $default,){
final _that = this;
switch (_that) {
case _TicketStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total,  int newTickets,  int aiProcessing,  int aiReplied,  int escalatedToHuman,  int inProgress,  int resolved,  int closed,  Map<String, int> byCategory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TicketStats() when $default != null:
return $default(_that.total,_that.newTickets,_that.aiProcessing,_that.aiReplied,_that.escalatedToHuman,_that.inProgress,_that.resolved,_that.closed,_that.byCategory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total,  int newTickets,  int aiProcessing,  int aiReplied,  int escalatedToHuman,  int inProgress,  int resolved,  int closed,  Map<String, int> byCategory)  $default,) {final _that = this;
switch (_that) {
case _TicketStats():
return $default(_that.total,_that.newTickets,_that.aiProcessing,_that.aiReplied,_that.escalatedToHuman,_that.inProgress,_that.resolved,_that.closed,_that.byCategory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total,  int newTickets,  int aiProcessing,  int aiReplied,  int escalatedToHuman,  int inProgress,  int resolved,  int closed,  Map<String, int> byCategory)?  $default,) {final _that = this;
switch (_that) {
case _TicketStats() when $default != null:
return $default(_that.total,_that.newTickets,_that.aiProcessing,_that.aiReplied,_that.escalatedToHuman,_that.inProgress,_that.resolved,_that.closed,_that.byCategory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TicketStats implements TicketStats {
  const _TicketStats({required this.total, this.newTickets = 0, this.aiProcessing = 0, this.aiReplied = 0, this.escalatedToHuman = 0, this.inProgress = 0, this.resolved = 0, this.closed = 0,  Map<String, int> byCategory = const {}}): _byCategory = byCategory;
  factory _TicketStats.fromJson(Map<String, dynamic> json) => _$TicketStatsFromJson(json);

@override final  int total;
@override@JsonKey() final  int newTickets;
@override@JsonKey() final  int aiProcessing;
@override@JsonKey() final  int aiReplied;
@override@JsonKey() final  int escalatedToHuman;
@override@JsonKey() final  int inProgress;
@override@JsonKey() final  int resolved;
@override@JsonKey() final  int closed;
 final  Map<String, int> _byCategory;
@override@JsonKey() Map<String, int> get byCategory {
  if (_byCategory is EqualUnmodifiableMapView) return _byCategory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byCategory);
}


/// Create a copy of TicketStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TicketStatsCopyWith<_TicketStats> get copyWith => __$TicketStatsCopyWithImpl<_TicketStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TicketStatsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TicketStats&&(identical(other.total, total) || other.total == total)&&(identical(other.newTickets, newTickets) || other.newTickets == newTickets)&&(identical(other.aiProcessing, aiProcessing) || other.aiProcessing == aiProcessing)&&(identical(other.aiReplied, aiReplied) || other.aiReplied == aiReplied)&&(identical(other.escalatedToHuman, escalatedToHuman) || other.escalatedToHuman == escalatedToHuman)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.resolved, resolved) || other.resolved == resolved)&&(identical(other.closed, closed) || other.closed == closed)&&const DeepCollectionEquality().equals(other.byCategory, _byCategory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,total,newTickets,aiProcessing,aiReplied,escalatedToHuman,inProgress,resolved,closed,const DeepCollectionEquality().hash(_byCategory));
}

@override
String toString() {
    return 'TicketStats(total: $total, newTickets: $newTickets, aiProcessing: $aiProcessing, aiReplied: $aiReplied, escalatedToHuman: $escalatedToHuman, inProgress: $inProgress, resolved: $resolved, closed: $closed, byCategory: $byCategory)';
}


}

/// @nodoc
abstract mixin class _$TicketStatsCopyWith<$Res> implements $TicketStatsCopyWith<$Res> {
  factory _$TicketStatsCopyWith(_TicketStats value, $Res Function(_TicketStats) _then) = __$TicketStatsCopyWithImpl;
@override @useResult
$Res call({
 int total, int newTickets, int aiProcessing, int aiReplied, int escalatedToHuman, int inProgress, int resolved, int closed, Map<String, int> byCategory
});




}
/// @nodoc
class __$TicketStatsCopyWithImpl<$Res>
    implements _$TicketStatsCopyWith<$Res> {
  __$TicketStatsCopyWithImpl(this._self, this._then);

  final _TicketStats _self;
  final $Res Function(_TicketStats) _then;

/// Create a copy of TicketStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? newTickets = null,Object? aiProcessing = null,Object? aiReplied = null,Object? escalatedToHuman = null,Object? inProgress = null,Object? resolved = null,Object? closed = null,Object? byCategory = null,}) {
  return _then(_TicketStats(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,newTickets: null == newTickets ? _self.newTickets : newTickets // ignore: cast_nullable_to_non_nullable
as int,aiProcessing: null == aiProcessing ? _self.aiProcessing : aiProcessing // ignore: cast_nullable_to_non_nullable
as int,aiReplied: null == aiReplied ? _self.aiReplied : aiReplied // ignore: cast_nullable_to_non_nullable
as int,escalatedToHuman: null == escalatedToHuman ? _self.escalatedToHuman : escalatedToHuman // ignore: cast_nullable_to_non_nullable
as int,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as int,resolved: null == resolved ? _self.resolved : resolved // ignore: cast_nullable_to_non_nullable
as int,closed: null == closed ? _self.closed : closed // ignore: cast_nullable_to_non_nullable
as int,byCategory: null == byCategory ? _self._byCategory : byCategory // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

// dart format on

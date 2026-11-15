// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ticket_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TicketDetail {

 String get id; Customer get customer; String get subject; TicketStatus get status; TicketCategory get category; int? get version; DateTime get createdAt; DateTime get updatedAt; List<Message> get messages;
/// Create a copy of TicketDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TicketDetailCopyWith<TicketDetail> get copyWith => _$TicketDetailCopyWithImpl<TicketDetail>(this as TicketDetail, _$identity);

  /// Serializes this TicketDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TicketDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TicketDetail&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.customer, _this.customer) || other.customer == _this.customer)&&(identical(other.subject, _this.subject) || other.subject == _this.subject)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&const DeepCollectionEquality().equals(other.messages, _this.messages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TicketDetail;
  return Object.hash(runtimeType,_this.id,_this.customer,_this.subject,_this.status,_this.category,_this.version,_this.createdAt,_this.updatedAt,const DeepCollectionEquality().hash(_this.messages));
}

@override
String toString() {
  final _this = this as TicketDetail;
  return 'TicketDetail(id: ${_this.id}, customer: ${_this.customer}, subject: ${_this.subject}, status: ${_this.status}, category: ${_this.category}, version: ${_this.version}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, messages: ${_this.messages})';
}


}

/// @nodoc
abstract mixin class $TicketDetailCopyWith<$Res>  {
  factory $TicketDetailCopyWith(TicketDetail value, $Res Function(TicketDetail) _then) = _$TicketDetailCopyWithImpl;
@useResult
$Res call({
 String id, Customer customer, String subject, TicketStatus status, TicketCategory category, int? version, DateTime createdAt, DateTime updatedAt, List<Message> messages
});


$CustomerCopyWith<$Res> get customer;

}
/// @nodoc
class _$TicketDetailCopyWithImpl<$Res>
    implements $TicketDetailCopyWith<$Res> {
  _$TicketDetailCopyWithImpl(this._self, this._then);

  final TicketDetail _self;
  final $Res Function(TicketDetail) _then;

/// Create a copy of TicketDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customer = null,Object? subject = null,Object? status = null,Object? category = null,Object? version = freezed,Object? createdAt = null,Object? updatedAt = null,Object? messages = null,}) {
  return _then(TicketDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as Customer,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TicketStatus,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TicketCategory,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<Message>,
  ));
}
/// Create a copy of TicketDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerCopyWith<$Res> get customer {
  
  return $CustomerCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}
}


/// Adds pattern-matching-related methods to [TicketDetail].
extension TicketDetailPatterns on TicketDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TicketDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TicketDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TicketDetail value)  $default,){
final _that = this;
switch (_that) {
case _TicketDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TicketDetail value)?  $default,){
final _that = this;
switch (_that) {
case _TicketDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Customer customer,  String subject,  TicketStatus status,  TicketCategory category,  int? version,  DateTime createdAt,  DateTime updatedAt,  List<Message> messages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TicketDetail() when $default != null:
return $default(_that.id,_that.customer,_that.subject,_that.status,_that.category,_that.version,_that.createdAt,_that.updatedAt,_that.messages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Customer customer,  String subject,  TicketStatus status,  TicketCategory category,  int? version,  DateTime createdAt,  DateTime updatedAt,  List<Message> messages)  $default,) {final _that = this;
switch (_that) {
case _TicketDetail():
return $default(_that.id,_that.customer,_that.subject,_that.status,_that.category,_that.version,_that.createdAt,_that.updatedAt,_that.messages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Customer customer,  String subject,  TicketStatus status,  TicketCategory category,  int? version,  DateTime createdAt,  DateTime updatedAt,  List<Message> messages)?  $default,) {final _that = this;
switch (_that) {
case _TicketDetail() when $default != null:
return $default(_that.id,_that.customer,_that.subject,_that.status,_that.category,_that.version,_that.createdAt,_that.updatedAt,_that.messages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TicketDetail implements TicketDetail {
  const _TicketDetail({required this.id, required this.customer, required this.subject, required this.status, required this.category, this.version, required this.createdAt, required this.updatedAt,  List<Message> messages = const []}): _messages = messages;
  factory _TicketDetail.fromJson(Map<String, dynamic> json) => _$TicketDetailFromJson(json);

@override final  String id;
@override final  Customer customer;
@override final  String subject;
@override final  TicketStatus status;
@override final  TicketCategory category;
@override final  int? version;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  List<Message> _messages;
@override@JsonKey() List<Message> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of TicketDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TicketDetailCopyWith<_TicketDetail> get copyWith => __$TicketDetailCopyWithImpl<_TicketDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TicketDetailToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TicketDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.messages, _messages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,customer,subject,status,category,version,createdAt,updatedAt,const DeepCollectionEquality().hash(_messages));
}

@override
String toString() {
    return 'TicketDetail(id: $id, customer: $customer, subject: $subject, status: $status, category: $category, version: $version, createdAt: $createdAt, updatedAt: $updatedAt, messages: $messages)';
}


}

/// @nodoc
abstract mixin class _$TicketDetailCopyWith<$Res> implements $TicketDetailCopyWith<$Res> {
  factory _$TicketDetailCopyWith(_TicketDetail value, $Res Function(_TicketDetail) _then) = __$TicketDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, Customer customer, String subject, TicketStatus status, TicketCategory category, int? version, DateTime createdAt, DateTime updatedAt, List<Message> messages
});


@override $CustomerCopyWith<$Res> get customer;

}
/// @nodoc
class __$TicketDetailCopyWithImpl<$Res>
    implements _$TicketDetailCopyWith<$Res> {
  __$TicketDetailCopyWithImpl(this._self, this._then);

  final _TicketDetail _self;
  final $Res Function(_TicketDetail) _then;

/// Create a copy of TicketDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customer = null,Object? subject = null,Object? status = null,Object? category = null,Object? version = freezed,Object? createdAt = null,Object? updatedAt = null,Object? messages = null,}) {
  return _then(_TicketDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as Customer,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TicketStatus,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TicketCategory,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<Message>,
  ));
}

/// Create a copy of TicketDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerCopyWith<$Res> get customer {
  
  return $CustomerCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}
}

// dart format on

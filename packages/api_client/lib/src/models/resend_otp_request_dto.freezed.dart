// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resend_otp_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ResendOtpRequestDto {

 String get challengeId;
/// Create a copy of ResendOtpRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResendOtpRequestDtoCopyWith<ResendOtpRequestDto> get copyWith => _$ResendOtpRequestDtoCopyWithImpl<ResendOtpRequestDto>(this as ResendOtpRequestDto, _$identity);

  /// Serializes this ResendOtpRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResendOtpRequestDto&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,challengeId);



}

/// @nodoc
abstract mixin class $ResendOtpRequestDtoCopyWith<$Res>  {
  factory $ResendOtpRequestDtoCopyWith(ResendOtpRequestDto value, $Res Function(ResendOtpRequestDto) _then) = _$ResendOtpRequestDtoCopyWithImpl;
@useResult
$Res call({
 String challengeId
});




}
/// @nodoc
class _$ResendOtpRequestDtoCopyWithImpl<$Res>
    implements $ResendOtpRequestDtoCopyWith<$Res> {
  _$ResendOtpRequestDtoCopyWithImpl(this._self, this._then);

  final ResendOtpRequestDto _self;
  final $Res Function(ResendOtpRequestDto) _then;

/// Create a copy of ResendOtpRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? challengeId = null,}) {
  return _then(_self.copyWith(
challengeId: null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ResendOtpRequestDto].
extension ResendOtpRequestDtoPatterns on ResendOtpRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResendOtpRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResendOtpRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResendOtpRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _ResendOtpRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResendOtpRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _ResendOtpRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String challengeId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResendOtpRequestDto() when $default != null:
return $default(_that.challengeId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String challengeId)  $default,) {final _that = this;
switch (_that) {
case _ResendOtpRequestDto():
return $default(_that.challengeId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String challengeId)?  $default,) {final _that = this;
switch (_that) {
case _ResendOtpRequestDto() when $default != null:
return $default(_that.challengeId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResendOtpRequestDto implements ResendOtpRequestDto {
  const _ResendOtpRequestDto({required this.challengeId});
  factory _ResendOtpRequestDto.fromJson(Map<String, dynamic> json) => _$ResendOtpRequestDtoFromJson(json);

@override final  String challengeId;

/// Create a copy of ResendOtpRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResendOtpRequestDtoCopyWith<_ResendOtpRequestDto> get copyWith => __$ResendOtpRequestDtoCopyWithImpl<_ResendOtpRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResendOtpRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResendOtpRequestDto&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,challengeId);



}

/// @nodoc
abstract mixin class _$ResendOtpRequestDtoCopyWith<$Res> implements $ResendOtpRequestDtoCopyWith<$Res> {
  factory _$ResendOtpRequestDtoCopyWith(_ResendOtpRequestDto value, $Res Function(_ResendOtpRequestDto) _then) = __$ResendOtpRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String challengeId
});




}
/// @nodoc
class __$ResendOtpRequestDtoCopyWithImpl<$Res>
    implements _$ResendOtpRequestDtoCopyWith<$Res> {
  __$ResendOtpRequestDtoCopyWithImpl(this._self, this._then);

  final _ResendOtpRequestDto _self;
  final $Res Function(_ResendOtpRequestDto) _then;

/// Create a copy of ResendOtpRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? challengeId = null,}) {
  return _then(_ResendOtpRequestDto(
challengeId: null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

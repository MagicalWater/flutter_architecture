// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'otp_challenge_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OtpChallengeDto {

 String get challengeId; DateTime get expiresAt; String get maskedDestination; DateTime get resendAvailableAt; int? get attemptsRemaining;
/// Create a copy of OtpChallengeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpChallengeDtoCopyWith<OtpChallengeDto> get copyWith => _$OtpChallengeDtoCopyWithImpl<OtpChallengeDto>(this as OtpChallengeDto, _$identity);

  /// Serializes this OtpChallengeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpChallengeDto&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.maskedDestination, maskedDestination) || other.maskedDestination == maskedDestination)&&(identical(other.resendAvailableAt, resendAvailableAt) || other.resendAvailableAt == resendAvailableAt)&&(identical(other.attemptsRemaining, attemptsRemaining) || other.attemptsRemaining == attemptsRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,challengeId,expiresAt,maskedDestination,resendAvailableAt,attemptsRemaining);



}

/// @nodoc
abstract mixin class $OtpChallengeDtoCopyWith<$Res>  {
  factory $OtpChallengeDtoCopyWith(OtpChallengeDto value, $Res Function(OtpChallengeDto) _then) = _$OtpChallengeDtoCopyWithImpl;
@useResult
$Res call({
 String challengeId, DateTime expiresAt, String maskedDestination, DateTime resendAvailableAt, int? attemptsRemaining
});




}
/// @nodoc
class _$OtpChallengeDtoCopyWithImpl<$Res>
    implements $OtpChallengeDtoCopyWith<$Res> {
  _$OtpChallengeDtoCopyWithImpl(this._self, this._then);

  final OtpChallengeDto _self;
  final $Res Function(OtpChallengeDto) _then;

/// Create a copy of OtpChallengeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? challengeId = null,Object? expiresAt = null,Object? maskedDestination = null,Object? resendAvailableAt = null,Object? attemptsRemaining = freezed,}) {
  return _then(OtpChallengeDto(
challengeId: null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,maskedDestination: null == maskedDestination ? _self.maskedDestination : maskedDestination // ignore: cast_nullable_to_non_nullable
as String,resendAvailableAt: null == resendAvailableAt ? _self.resendAvailableAt : resendAvailableAt // ignore: cast_nullable_to_non_nullable
as DateTime,attemptsRemaining: freezed == attemptsRemaining ? _self.attemptsRemaining : attemptsRemaining // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [OtpChallengeDto].
extension OtpChallengeDtoPatterns on OtpChallengeDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OtpChallengeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OtpChallengeDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OtpChallengeDto value)  $default,){
final _that = this;
switch (_that) {
case _OtpChallengeDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OtpChallengeDto value)?  $default,){
final _that = this;
switch (_that) {
case _OtpChallengeDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String challengeId,  DateTime expiresAt,  String maskedDestination,  DateTime resendAvailableAt,  int? attemptsRemaining)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OtpChallengeDto() when $default != null:
return $default(_that.challengeId,_that.expiresAt,_that.maskedDestination,_that.resendAvailableAt,_that.attemptsRemaining);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String challengeId,  DateTime expiresAt,  String maskedDestination,  DateTime resendAvailableAt,  int? attemptsRemaining)  $default,) {final _that = this;
switch (_that) {
case _OtpChallengeDto():
return $default(_that.challengeId,_that.expiresAt,_that.maskedDestination,_that.resendAvailableAt,_that.attemptsRemaining);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String challengeId,  DateTime expiresAt,  String maskedDestination,  DateTime resendAvailableAt,  int? attemptsRemaining)?  $default,) {final _that = this;
switch (_that) {
case _OtpChallengeDto() when $default != null:
return $default(_that.challengeId,_that.expiresAt,_that.maskedDestination,_that.resendAvailableAt,_that.attemptsRemaining);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OtpChallengeDto implements OtpChallengeDto {
  const _OtpChallengeDto({required this.challengeId, required this.expiresAt, required this.maskedDestination, required this.resendAvailableAt, this.attemptsRemaining});
  factory _OtpChallengeDto.fromJson(Map<String, dynamic> json) => _$OtpChallengeDtoFromJson(json);

@override final  String challengeId;
@override final  DateTime expiresAt;
@override final  String maskedDestination;
@override final  DateTime resendAvailableAt;
@override final  int? attemptsRemaining;

/// Create a copy of OtpChallengeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpChallengeDtoCopyWith<_OtpChallengeDto> get copyWith => __$OtpChallengeDtoCopyWithImpl<_OtpChallengeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OtpChallengeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpChallengeDto&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.maskedDestination, maskedDestination) || other.maskedDestination == maskedDestination)&&(identical(other.resendAvailableAt, resendAvailableAt) || other.resendAvailableAt == resendAvailableAt)&&(identical(other.attemptsRemaining, attemptsRemaining) || other.attemptsRemaining == attemptsRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,challengeId,expiresAt,maskedDestination,resendAvailableAt,attemptsRemaining);



}

/// @nodoc
abstract mixin class _$OtpChallengeDtoCopyWith<$Res> implements $OtpChallengeDtoCopyWith<$Res> {
  factory _$OtpChallengeDtoCopyWith(_OtpChallengeDto value, $Res Function(_OtpChallengeDto) _then) = __$OtpChallengeDtoCopyWithImpl;
@override @useResult
$Res call({
 String challengeId, DateTime expiresAt, String maskedDestination, DateTime resendAvailableAt, int? attemptsRemaining
});




}
/// @nodoc
class __$OtpChallengeDtoCopyWithImpl<$Res>
    implements _$OtpChallengeDtoCopyWith<$Res> {
  __$OtpChallengeDtoCopyWithImpl(this._self, this._then);

  final _OtpChallengeDto _self;
  final $Res Function(_OtpChallengeDto) _then;

/// Create a copy of OtpChallengeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? challengeId = null,Object? expiresAt = null,Object? maskedDestination = null,Object? resendAvailableAt = null,Object? attemptsRemaining = freezed,}) {
  return _then(_OtpChallengeDto(
challengeId: null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,maskedDestination: null == maskedDestination ? _self.maskedDestination : maskedDestination // ignore: cast_nullable_to_non_nullable
as String,resendAvailableAt: null == resendAvailableAt ? _self.resendAvailableAt : resendAvailableAt // ignore: cast_nullable_to_non_nullable
as DateTime,attemptsRemaining: freezed == attemptsRemaining ? _self.attemptsRemaining : attemptsRemaining // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on

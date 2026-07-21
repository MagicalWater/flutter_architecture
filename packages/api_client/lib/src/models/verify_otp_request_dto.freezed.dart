// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verify_otp_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerifyOtpRequestDto {

 String get challengeId; String get code;
/// Create a copy of VerifyOtpRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifyOtpRequestDtoCopyWith<VerifyOtpRequestDto> get copyWith => _$VerifyOtpRequestDtoCopyWithImpl<VerifyOtpRequestDto>(this as VerifyOtpRequestDto, _$identity);

  /// Serializes this VerifyOtpRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifyOtpRequestDto&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,challengeId,code);



}

/// @nodoc
abstract mixin class $VerifyOtpRequestDtoCopyWith<$Res>  {
  factory $VerifyOtpRequestDtoCopyWith(VerifyOtpRequestDto value, $Res Function(VerifyOtpRequestDto) _then) = _$VerifyOtpRequestDtoCopyWithImpl;
@useResult
$Res call({
 String challengeId, String code
});




}
/// @nodoc
class _$VerifyOtpRequestDtoCopyWithImpl<$Res>
    implements $VerifyOtpRequestDtoCopyWith<$Res> {
  _$VerifyOtpRequestDtoCopyWithImpl(this._self, this._then);

  final VerifyOtpRequestDto _self;
  final $Res Function(VerifyOtpRequestDto) _then;

/// Create a copy of VerifyOtpRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? challengeId = null,Object? code = null,}) {
  return _then(_self.copyWith(
challengeId: null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VerifyOtpRequestDto].
extension VerifyOtpRequestDtoPatterns on VerifyOtpRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifyOtpRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifyOtpRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifyOtpRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _VerifyOtpRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifyOtpRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _VerifyOtpRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String challengeId,  String code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifyOtpRequestDto() when $default != null:
return $default(_that.challengeId,_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String challengeId,  String code)  $default,) {final _that = this;
switch (_that) {
case _VerifyOtpRequestDto():
return $default(_that.challengeId,_that.code);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String challengeId,  String code)?  $default,) {final _that = this;
switch (_that) {
case _VerifyOtpRequestDto() when $default != null:
return $default(_that.challengeId,_that.code);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerifyOtpRequestDto implements VerifyOtpRequestDto {
  const _VerifyOtpRequestDto({required this.challengeId, required this.code});
  factory _VerifyOtpRequestDto.fromJson(Map<String, dynamic> json) => _$VerifyOtpRequestDtoFromJson(json);

@override final  String challengeId;
@override final  String code;

/// Create a copy of VerifyOtpRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifyOtpRequestDtoCopyWith<_VerifyOtpRequestDto> get copyWith => __$VerifyOtpRequestDtoCopyWithImpl<_VerifyOtpRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerifyOtpRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifyOtpRequestDto&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,challengeId,code);



}

/// @nodoc
abstract mixin class _$VerifyOtpRequestDtoCopyWith<$Res> implements $VerifyOtpRequestDtoCopyWith<$Res> {
  factory _$VerifyOtpRequestDtoCopyWith(_VerifyOtpRequestDto value, $Res Function(_VerifyOtpRequestDto) _then) = __$VerifyOtpRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String challengeId, String code
});




}
/// @nodoc
class __$VerifyOtpRequestDtoCopyWithImpl<$Res>
    implements _$VerifyOtpRequestDtoCopyWith<$Res> {
  __$VerifyOtpRequestDtoCopyWithImpl(this._self, this._then);

  final _VerifyOtpRequestDto _self;
  final $Res Function(_VerifyOtpRequestDto) _then;

/// Create a copy of VerifyOtpRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? challengeId = null,Object? code = null,}) {
  return _then(_VerifyOtpRequestDto(
challengeId: null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

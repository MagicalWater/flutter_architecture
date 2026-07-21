// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'authenticated_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthenticatedResponseDto {

 String get accessToken; String get refreshToken; String get userId; String get userName;
/// Create a copy of AuthenticatedResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthenticatedResponseDtoCopyWith<AuthenticatedResponseDto> get copyWith => _$AuthenticatedResponseDtoCopyWithImpl<AuthenticatedResponseDto>(this as AuthenticatedResponseDto, _$identity);

  /// Serializes this AuthenticatedResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthenticatedResponseDto&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,userId,userName);



}

/// @nodoc
abstract mixin class $AuthenticatedResponseDtoCopyWith<$Res>  {
  factory $AuthenticatedResponseDtoCopyWith(AuthenticatedResponseDto value, $Res Function(AuthenticatedResponseDto) _then) = _$AuthenticatedResponseDtoCopyWithImpl;
@useResult
$Res call({
 String accessToken, String refreshToken, String userId, String userName
});




}
/// @nodoc
class _$AuthenticatedResponseDtoCopyWithImpl<$Res>
    implements $AuthenticatedResponseDtoCopyWith<$Res> {
  _$AuthenticatedResponseDtoCopyWithImpl(this._self, this._then);

  final AuthenticatedResponseDto _self;
  final $Res Function(AuthenticatedResponseDto) _then;

/// Create a copy of AuthenticatedResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? refreshToken = null,Object? userId = null,Object? userName = null,}) {
  return _then(_self.copyWith(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthenticatedResponseDto].
extension AuthenticatedResponseDtoPatterns on AuthenticatedResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthenticatedResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthenticatedResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthenticatedResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _AuthenticatedResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthenticatedResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _AuthenticatedResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accessToken,  String refreshToken,  String userId,  String userName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthenticatedResponseDto() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.userId,_that.userName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accessToken,  String refreshToken,  String userId,  String userName)  $default,) {final _that = this;
switch (_that) {
case _AuthenticatedResponseDto():
return $default(_that.accessToken,_that.refreshToken,_that.userId,_that.userName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accessToken,  String refreshToken,  String userId,  String userName)?  $default,) {final _that = this;
switch (_that) {
case _AuthenticatedResponseDto() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.userId,_that.userName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthenticatedResponseDto implements AuthenticatedResponseDto {
  const _AuthenticatedResponseDto({required this.accessToken, required this.refreshToken, required this.userId, required this.userName});
  factory _AuthenticatedResponseDto.fromJson(Map<String, dynamic> json) => _$AuthenticatedResponseDtoFromJson(json);

@override final  String accessToken;
@override final  String refreshToken;
@override final  String userId;
@override final  String userName;

/// Create a copy of AuthenticatedResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthenticatedResponseDtoCopyWith<_AuthenticatedResponseDto> get copyWith => __$AuthenticatedResponseDtoCopyWithImpl<_AuthenticatedResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthenticatedResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthenticatedResponseDto&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,userId,userName);



}

/// @nodoc
abstract mixin class _$AuthenticatedResponseDtoCopyWith<$Res> implements $AuthenticatedResponseDtoCopyWith<$Res> {
  factory _$AuthenticatedResponseDtoCopyWith(_AuthenticatedResponseDto value, $Res Function(_AuthenticatedResponseDto) _then) = __$AuthenticatedResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String accessToken, String refreshToken, String userId, String userName
});




}
/// @nodoc
class __$AuthenticatedResponseDtoCopyWithImpl<$Res>
    implements _$AuthenticatedResponseDtoCopyWith<$Res> {
  __$AuthenticatedResponseDtoCopyWithImpl(this._self, this._then);

  final _AuthenticatedResponseDto _self;
  final $Res Function(_AuthenticatedResponseDto) _then;

/// Create a copy of AuthenticatedResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? refreshToken = null,Object? userId = null,Object? userName = null,}) {
  return _then(_AuthenticatedResponseDto(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

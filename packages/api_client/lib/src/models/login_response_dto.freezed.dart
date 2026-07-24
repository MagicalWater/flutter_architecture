// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
LoginResponseDto _$LoginResponseDtoFromJson(
  Map<String, dynamic> json
) {
        switch (json['resultType']) {
                  case 'authenticated':
          return AuthenticatedLoginResponseDto.fromJson(
            json
          );
                case 'otpChallenge':
          return OtpChallengeLoginResponseDto.fromJson(
            json
          );

          default:
            throw CheckedFromJsonException(
  json,
  'resultType',
  'LoginResponseDto',
  'Invalid union type "${json['resultType']}"!'
);
        }

}

/// @nodoc
mixin _$LoginResponseDto {



  /// Serializes this LoginResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginResponseDto);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;



}

/// @nodoc
class $LoginResponseDtoCopyWith<$Res>  {
$LoginResponseDtoCopyWith(LoginResponseDto _, $Res Function(LoginResponseDto) __);
}


/// Adds pattern-matching-related methods to [LoginResponseDto].
extension LoginResponseDtoPatterns on LoginResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AuthenticatedLoginResponseDto value)?  authenticated,TResult Function( OtpChallengeLoginResponseDto value)?  otpChallenge,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AuthenticatedLoginResponseDto() when authenticated != null:
return authenticated(_that);case OtpChallengeLoginResponseDto() when otpChallenge != null:
return otpChallenge(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AuthenticatedLoginResponseDto value)  authenticated,required TResult Function( OtpChallengeLoginResponseDto value)  otpChallenge,}){
final _that = this;
switch (_that) {
case AuthenticatedLoginResponseDto():
return authenticated(_that);case OtpChallengeLoginResponseDto():
return otpChallenge(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AuthenticatedLoginResponseDto value)?  authenticated,TResult? Function( OtpChallengeLoginResponseDto value)?  otpChallenge,}){
final _that = this;
switch (_that) {
case AuthenticatedLoginResponseDto() when authenticated != null:
return authenticated(_that);case OtpChallengeLoginResponseDto() when otpChallenge != null:
return otpChallenge(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function(@JsonKey(fromJson: AuthenticatedResponseDto.fromJson, toJson: _authenticatedToJson)  AuthenticatedResponseDto authenticated)?  authenticated,TResult Function(@JsonKey(fromJson: OtpChallengeDto.fromJson, toJson: _challengeToJson)  OtpChallengeDto challenge)?  otpChallenge,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AuthenticatedLoginResponseDto() when authenticated != null:
return authenticated(_that.authenticated);case OtpChallengeLoginResponseDto() when otpChallenge != null:
return otpChallenge(_that.challenge);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function(@JsonKey(fromJson: AuthenticatedResponseDto.fromJson, toJson: _authenticatedToJson)  AuthenticatedResponseDto authenticated)  authenticated,required TResult Function(@JsonKey(fromJson: OtpChallengeDto.fromJson, toJson: _challengeToJson)  OtpChallengeDto challenge)  otpChallenge,}) {final _that = this;
switch (_that) {
case AuthenticatedLoginResponseDto():
return authenticated(_that.authenticated);case OtpChallengeLoginResponseDto():
return otpChallenge(_that.challenge);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function(@JsonKey(fromJson: AuthenticatedResponseDto.fromJson, toJson: _authenticatedToJson)  AuthenticatedResponseDto authenticated)?  authenticated,TResult? Function(@JsonKey(fromJson: OtpChallengeDto.fromJson, toJson: _challengeToJson)  OtpChallengeDto challenge)?  otpChallenge,}) {final _that = this;
switch (_that) {
case AuthenticatedLoginResponseDto() when authenticated != null:
return authenticated(_that.authenticated);case OtpChallengeLoginResponseDto() when otpChallenge != null:
return otpChallenge(_that.challenge);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class AuthenticatedLoginResponseDto implements LoginResponseDto {
  const AuthenticatedLoginResponseDto({@JsonKey(fromJson: AuthenticatedResponseDto.fromJson, toJson: _authenticatedToJson) required this.authenticated,  String? $type}): $type = $type ?? 'authenticated';
  factory AuthenticatedLoginResponseDto.fromJson(Map<String, dynamic> json) => _$AuthenticatedLoginResponseDtoFromJson(json);

@JsonKey(fromJson: AuthenticatedResponseDto.fromJson, toJson: _authenticatedToJson) final  AuthenticatedResponseDto authenticated;

@JsonKey(name: 'resultType')
final String $type;


/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthenticatedLoginResponseDtoCopyWith<AuthenticatedLoginResponseDto> get copyWith => _$AuthenticatedLoginResponseDtoCopyWithImpl<AuthenticatedLoginResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthenticatedLoginResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthenticatedLoginResponseDto&&(identical(other.authenticated, authenticated) || other.authenticated == authenticated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,authenticated);



}

/// @nodoc
abstract mixin class $AuthenticatedLoginResponseDtoCopyWith<$Res> implements $LoginResponseDtoCopyWith<$Res> {
  factory $AuthenticatedLoginResponseDtoCopyWith(AuthenticatedLoginResponseDto value, $Res Function(AuthenticatedLoginResponseDto) _then) = _$AuthenticatedLoginResponseDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: AuthenticatedResponseDto.fromJson, toJson: _authenticatedToJson) AuthenticatedResponseDto authenticated
});


$AuthenticatedResponseDtoCopyWith<$Res> get authenticated;

}
/// @nodoc
class _$AuthenticatedLoginResponseDtoCopyWithImpl<$Res>
    implements $AuthenticatedLoginResponseDtoCopyWith<$Res> {
  _$AuthenticatedLoginResponseDtoCopyWithImpl(this._self, this._then);

  final AuthenticatedLoginResponseDto _self;
  final $Res Function(AuthenticatedLoginResponseDto) _then;

/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? authenticated = null,}) {
  return _then(AuthenticatedLoginResponseDto(
authenticated: null == authenticated ? _self.authenticated : authenticated // ignore: cast_nullable_to_non_nullable
as AuthenticatedResponseDto,
  ));
}

/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthenticatedResponseDtoCopyWith<$Res> get authenticated {

  return $AuthenticatedResponseDtoCopyWith<$Res>(_self.authenticated, (value) {
    return _then(_self.copyWith(authenticated: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class OtpChallengeLoginResponseDto implements LoginResponseDto {
  const OtpChallengeLoginResponseDto({@JsonKey(fromJson: OtpChallengeDto.fromJson, toJson: _challengeToJson) required this.challenge,  String? $type}): $type = $type ?? 'otpChallenge';
  factory OtpChallengeLoginResponseDto.fromJson(Map<String, dynamic> json) => _$OtpChallengeLoginResponseDtoFromJson(json);

@JsonKey(fromJson: OtpChallengeDto.fromJson, toJson: _challengeToJson) final  OtpChallengeDto challenge;

@JsonKey(name: 'resultType')
final String $type;


/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpChallengeLoginResponseDtoCopyWith<OtpChallengeLoginResponseDto> get copyWith => _$OtpChallengeLoginResponseDtoCopyWithImpl<OtpChallengeLoginResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OtpChallengeLoginResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpChallengeLoginResponseDto&&(identical(other.challenge, challenge) || other.challenge == challenge));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,challenge);



}

/// @nodoc
abstract mixin class $OtpChallengeLoginResponseDtoCopyWith<$Res> implements $LoginResponseDtoCopyWith<$Res> {
  factory $OtpChallengeLoginResponseDtoCopyWith(OtpChallengeLoginResponseDto value, $Res Function(OtpChallengeLoginResponseDto) _then) = _$OtpChallengeLoginResponseDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: OtpChallengeDto.fromJson, toJson: _challengeToJson) OtpChallengeDto challenge
});


$OtpChallengeDtoCopyWith<$Res> get challenge;

}
/// @nodoc
class _$OtpChallengeLoginResponseDtoCopyWithImpl<$Res>
    implements $OtpChallengeLoginResponseDtoCopyWith<$Res> {
  _$OtpChallengeLoginResponseDtoCopyWithImpl(this._self, this._then);

  final OtpChallengeLoginResponseDto _self;
  final $Res Function(OtpChallengeLoginResponseDto) _then;

/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? challenge = null,}) {
  return _then(OtpChallengeLoginResponseDto(
challenge: null == challenge ? _self.challenge : challenge // ignore: cast_nullable_to_non_nullable
as OtpChallengeDto,
  ));
}

/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OtpChallengeDtoCopyWith<$Res> get challenge {

  return $OtpChallengeDtoCopyWith<$Res>(_self.challenge, (value) {
    return _then(_self.copyWith(challenge: value));
  });
}
}

// dart format on

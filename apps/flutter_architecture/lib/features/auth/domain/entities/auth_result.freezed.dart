// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuthResult {
  String get accessToken => throw _privateConstructorUsedError;
  AuthUser get user => throw _privateConstructorUsedError;

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResultCopyWith<AuthResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResultCopyWith<$Res> {
  factory $AuthResultCopyWith(
          AuthResult value, $Res Function(AuthResult) then) =
      _$AuthResultCopyWithImpl<$Res, AuthResult>;
  @useResult
  $Res call({String accessToken, AuthUser user});

  $AuthUserCopyWith<$Res> get user;
}

/// @nodoc
class _$AuthResultCopyWithImpl<$Res, $Val extends AuthResult>
    implements $AuthResultCopyWith<$Res> {
  _$AuthResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? user = null,
  }) {
    return _then(_value.copyWith(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as AuthUser,
    ) as $Val);
  }

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthUserCopyWith<$Res> get user {
    return $AuthUserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthResultImplCopyWith<$Res>
    implements $AuthResultCopyWith<$Res> {
  factory _$$AuthResultImplCopyWith(
          _$AuthResultImpl value, $Res Function(_$AuthResultImpl) then) =
      __$$AuthResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String accessToken, AuthUser user});

  @override
  $AuthUserCopyWith<$Res> get user;
}

/// @nodoc
class __$$AuthResultImplCopyWithImpl<$Res>
    extends _$AuthResultCopyWithImpl<$Res, _$AuthResultImpl>
    implements _$$AuthResultImplCopyWith<$Res> {
  __$$AuthResultImplCopyWithImpl(
      _$AuthResultImpl _value, $Res Function(_$AuthResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? user = null,
  }) {
    return _then(_$AuthResultImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as AuthUser,
    ));
  }
}

/// @nodoc

class _$AuthResultImpl implements _AuthResult {
  const _$AuthResultImpl({required this.accessToken, required this.user});

  @override
  final String accessToken;
  @override
  final AuthUser user;

  @override
  String toString() {
    return 'AuthResult(accessToken: $accessToken, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResultImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, accessToken, user);

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResultImplCopyWith<_$AuthResultImpl> get copyWith =>
      __$$AuthResultImplCopyWithImpl<_$AuthResultImpl>(this, _$identity);
}

abstract class _AuthResult implements AuthResult {
  const factory _AuthResult(
      {required final String accessToken,
      required final AuthUser user}) = _$AuthResultImpl;

  @override
  String get accessToken;
  @override
  AuthUser get user;

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResultImplCopyWith<_$AuthResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

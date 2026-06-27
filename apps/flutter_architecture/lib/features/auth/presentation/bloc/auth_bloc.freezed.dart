// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuthEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String account, String password) loginRequested,
    required TResult Function() logoutRequested,
    required TResult Function() sessionCleared,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String account, String password)? loginRequested,
    TResult? Function()? logoutRequested,
    TResult? Function()? sessionCleared,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String account, String password)? loginRequested,
    TResult Function()? logoutRequested,
    TResult Function()? sessionCleared,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthStarted value) started,
    required TResult Function(AuthLoginRequested value) loginRequested,
    required TResult Function(AuthLogoutRequested value) logoutRequested,
    required TResult Function(AuthSessionCleared value) sessionCleared,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthStarted value)? started,
    TResult? Function(AuthLoginRequested value)? loginRequested,
    TResult? Function(AuthLogoutRequested value)? logoutRequested,
    TResult? Function(AuthSessionCleared value)? sessionCleared,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthStarted value)? started,
    TResult Function(AuthLoginRequested value)? loginRequested,
    TResult Function(AuthLogoutRequested value)? logoutRequested,
    TResult Function(AuthSessionCleared value)? sessionCleared,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthEventCopyWith<$Res> {
  factory $AuthEventCopyWith(AuthEvent value, $Res Function(AuthEvent) then) =
      _$AuthEventCopyWithImpl<$Res, AuthEvent>;
}

/// @nodoc
class _$AuthEventCopyWithImpl<$Res, $Val extends AuthEvent>
    implements $AuthEventCopyWith<$Res> {
  _$AuthEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$AuthStartedImplCopyWith<$Res> {
  factory _$$AuthStartedImplCopyWith(
          _$AuthStartedImpl value, $Res Function(_$AuthStartedImpl) then) =
      __$$AuthStartedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AuthStartedImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$AuthStartedImpl>
    implements _$$AuthStartedImplCopyWith<$Res> {
  __$$AuthStartedImplCopyWithImpl(
      _$AuthStartedImpl _value, $Res Function(_$AuthStartedImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$AuthStartedImpl implements AuthStarted {
  const _$AuthStartedImpl();

  @override
  String toString() {
    return 'AuthEvent.started()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AuthStartedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String account, String password) loginRequested,
    required TResult Function() logoutRequested,
    required TResult Function() sessionCleared,
  }) {
    return started();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String account, String password)? loginRequested,
    TResult? Function()? logoutRequested,
    TResult? Function()? sessionCleared,
  }) {
    return started?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String account, String password)? loginRequested,
    TResult Function()? logoutRequested,
    TResult Function()? sessionCleared,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthStarted value) started,
    required TResult Function(AuthLoginRequested value) loginRequested,
    required TResult Function(AuthLogoutRequested value) logoutRequested,
    required TResult Function(AuthSessionCleared value) sessionCleared,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthStarted value)? started,
    TResult? Function(AuthLoginRequested value)? loginRequested,
    TResult? Function(AuthLogoutRequested value)? logoutRequested,
    TResult? Function(AuthSessionCleared value)? sessionCleared,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthStarted value)? started,
    TResult Function(AuthLoginRequested value)? loginRequested,
    TResult Function(AuthLogoutRequested value)? logoutRequested,
    TResult Function(AuthSessionCleared value)? sessionCleared,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class AuthStarted implements AuthEvent {
  const factory AuthStarted() = _$AuthStartedImpl;
}

/// @nodoc
abstract class _$$AuthLoginRequestedImplCopyWith<$Res> {
  factory _$$AuthLoginRequestedImplCopyWith(_$AuthLoginRequestedImpl value,
          $Res Function(_$AuthLoginRequestedImpl) then) =
      __$$AuthLoginRequestedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String account, String password});
}

/// @nodoc
class __$$AuthLoginRequestedImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$AuthLoginRequestedImpl>
    implements _$$AuthLoginRequestedImplCopyWith<$Res> {
  __$$AuthLoginRequestedImplCopyWithImpl(_$AuthLoginRequestedImpl _value,
      $Res Function(_$AuthLoginRequestedImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? account = null,
    Object? password = null,
  }) {
    return _then(_$AuthLoginRequestedImpl(
      account: null == account
          ? _value.account
          : account // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AuthLoginRequestedImpl implements AuthLoginRequested {
  const _$AuthLoginRequestedImpl(
      {required this.account, required this.password});

  @override
  final String account;
  @override
  final String password;

  @override
  String toString() {
    return 'AuthEvent.loginRequested(account: $account, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthLoginRequestedImpl &&
            (identical(other.account, account) || other.account == account) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @override
  int get hashCode => Object.hash(runtimeType, account, password);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthLoginRequestedImplCopyWith<_$AuthLoginRequestedImpl> get copyWith =>
      __$$AuthLoginRequestedImplCopyWithImpl<_$AuthLoginRequestedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String account, String password) loginRequested,
    required TResult Function() logoutRequested,
    required TResult Function() sessionCleared,
  }) {
    return loginRequested(account, password);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String account, String password)? loginRequested,
    TResult? Function()? logoutRequested,
    TResult? Function()? sessionCleared,
  }) {
    return loginRequested?.call(account, password);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String account, String password)? loginRequested,
    TResult Function()? logoutRequested,
    TResult Function()? sessionCleared,
    required TResult orElse(),
  }) {
    if (loginRequested != null) {
      return loginRequested(account, password);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthStarted value) started,
    required TResult Function(AuthLoginRequested value) loginRequested,
    required TResult Function(AuthLogoutRequested value) logoutRequested,
    required TResult Function(AuthSessionCleared value) sessionCleared,
  }) {
    return loginRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthStarted value)? started,
    TResult? Function(AuthLoginRequested value)? loginRequested,
    TResult? Function(AuthLogoutRequested value)? logoutRequested,
    TResult? Function(AuthSessionCleared value)? sessionCleared,
  }) {
    return loginRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthStarted value)? started,
    TResult Function(AuthLoginRequested value)? loginRequested,
    TResult Function(AuthLogoutRequested value)? logoutRequested,
    TResult Function(AuthSessionCleared value)? sessionCleared,
    required TResult orElse(),
  }) {
    if (loginRequested != null) {
      return loginRequested(this);
    }
    return orElse();
  }
}

abstract class AuthLoginRequested implements AuthEvent {
  const factory AuthLoginRequested(
      {required final String account,
      required final String password}) = _$AuthLoginRequestedImpl;

  String get account;
  String get password;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthLoginRequestedImplCopyWith<_$AuthLoginRequestedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AuthLogoutRequestedImplCopyWith<$Res> {
  factory _$$AuthLogoutRequestedImplCopyWith(_$AuthLogoutRequestedImpl value,
          $Res Function(_$AuthLogoutRequestedImpl) then) =
      __$$AuthLogoutRequestedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AuthLogoutRequestedImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$AuthLogoutRequestedImpl>
    implements _$$AuthLogoutRequestedImplCopyWith<$Res> {
  __$$AuthLogoutRequestedImplCopyWithImpl(_$AuthLogoutRequestedImpl _value,
      $Res Function(_$AuthLogoutRequestedImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$AuthLogoutRequestedImpl implements AuthLogoutRequested {
  const _$AuthLogoutRequestedImpl();

  @override
  String toString() {
    return 'AuthEvent.logoutRequested()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthLogoutRequestedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String account, String password) loginRequested,
    required TResult Function() logoutRequested,
    required TResult Function() sessionCleared,
  }) {
    return logoutRequested();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String account, String password)? loginRequested,
    TResult? Function()? logoutRequested,
    TResult? Function()? sessionCleared,
  }) {
    return logoutRequested?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String account, String password)? loginRequested,
    TResult Function()? logoutRequested,
    TResult Function()? sessionCleared,
    required TResult orElse(),
  }) {
    if (logoutRequested != null) {
      return logoutRequested();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthStarted value) started,
    required TResult Function(AuthLoginRequested value) loginRequested,
    required TResult Function(AuthLogoutRequested value) logoutRequested,
    required TResult Function(AuthSessionCleared value) sessionCleared,
  }) {
    return logoutRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthStarted value)? started,
    TResult? Function(AuthLoginRequested value)? loginRequested,
    TResult? Function(AuthLogoutRequested value)? logoutRequested,
    TResult? Function(AuthSessionCleared value)? sessionCleared,
  }) {
    return logoutRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthStarted value)? started,
    TResult Function(AuthLoginRequested value)? loginRequested,
    TResult Function(AuthLogoutRequested value)? logoutRequested,
    TResult Function(AuthSessionCleared value)? sessionCleared,
    required TResult orElse(),
  }) {
    if (logoutRequested != null) {
      return logoutRequested(this);
    }
    return orElse();
  }
}

abstract class AuthLogoutRequested implements AuthEvent {
  const factory AuthLogoutRequested() = _$AuthLogoutRequestedImpl;
}

/// @nodoc
abstract class _$$AuthSessionClearedImplCopyWith<$Res> {
  factory _$$AuthSessionClearedImplCopyWith(_$AuthSessionClearedImpl value,
          $Res Function(_$AuthSessionClearedImpl) then) =
      __$$AuthSessionClearedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AuthSessionClearedImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$AuthSessionClearedImpl>
    implements _$$AuthSessionClearedImplCopyWith<$Res> {
  __$$AuthSessionClearedImplCopyWithImpl(_$AuthSessionClearedImpl _value,
      $Res Function(_$AuthSessionClearedImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$AuthSessionClearedImpl implements AuthSessionCleared {
  const _$AuthSessionClearedImpl();

  @override
  String toString() {
    return 'AuthEvent.sessionCleared()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AuthSessionClearedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String account, String password) loginRequested,
    required TResult Function() logoutRequested,
    required TResult Function() sessionCleared,
  }) {
    return sessionCleared();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String account, String password)? loginRequested,
    TResult? Function()? logoutRequested,
    TResult? Function()? sessionCleared,
  }) {
    return sessionCleared?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String account, String password)? loginRequested,
    TResult Function()? logoutRequested,
    TResult Function()? sessionCleared,
    required TResult orElse(),
  }) {
    if (sessionCleared != null) {
      return sessionCleared();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthStarted value) started,
    required TResult Function(AuthLoginRequested value) loginRequested,
    required TResult Function(AuthLogoutRequested value) logoutRequested,
    required TResult Function(AuthSessionCleared value) sessionCleared,
  }) {
    return sessionCleared(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthStarted value)? started,
    TResult? Function(AuthLoginRequested value)? loginRequested,
    TResult? Function(AuthLogoutRequested value)? logoutRequested,
    TResult? Function(AuthSessionCleared value)? sessionCleared,
  }) {
    return sessionCleared?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthStarted value)? started,
    TResult Function(AuthLoginRequested value)? loginRequested,
    TResult Function(AuthLogoutRequested value)? logoutRequested,
    TResult Function(AuthSessionCleared value)? sessionCleared,
    required TResult orElse(),
  }) {
    if (sessionCleared != null) {
      return sessionCleared(this);
    }
    return orElse();
  }
}

abstract class AuthSessionCleared implements AuthEvent {
  const factory AuthSessionCleared() = _$AuthSessionClearedImpl;
}

/// @nodoc
mixin _$AuthState {
  bool get isLoading => throw _privateConstructorUsedError;
  AuthUser? get user => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthStateCopyWith<AuthState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
      _$AuthStateCopyWithImpl<$Res, AuthState>;
  @useResult
  $Res call({bool isLoading, AuthUser? user, String? errorMessage});

  $AuthUserCopyWith<$Res>? get user;
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res, $Val extends AuthState>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? user = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as AuthUser?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthUserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $AuthUserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthStateImplCopyWith<$Res>
    implements $AuthStateCopyWith<$Res> {
  factory _$$AuthStateImplCopyWith(
          _$AuthStateImpl value, $Res Function(_$AuthStateImpl) then) =
      __$$AuthStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isLoading, AuthUser? user, String? errorMessage});

  @override
  $AuthUserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$AuthStateImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthStateImpl>
    implements _$$AuthStateImplCopyWith<$Res> {
  __$$AuthStateImplCopyWithImpl(
      _$AuthStateImpl _value, $Res Function(_$AuthStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? user = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$AuthStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as AuthUser?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$AuthStateImpl extends _AuthState {
  const _$AuthStateImpl(
      {required this.isLoading, required this.user, required this.errorMessage})
      : super._();

  @override
  final bool isLoading;
  @override
  final AuthUser? user;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'AuthState(isLoading: $isLoading, user: $user, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, user, errorMessage);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthStateImplCopyWith<_$AuthStateImpl> get copyWith =>
      __$$AuthStateImplCopyWithImpl<_$AuthStateImpl>(this, _$identity);
}

abstract class _AuthState extends AuthState {
  const factory _AuthState(
      {required final bool isLoading,
      required final AuthUser? user,
      required final String? errorMessage}) = _$AuthStateImpl;
  const _AuthState._() : super._();

  @override
  bool get isLoading;
  @override
  AuthUser? get user;
  @override
  String? get errorMessage;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthStateImplCopyWith<_$AuthStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthEvent);
}


@override
int get hashCode => runtimeType.hashCode;



}

/// @nodoc
class $AuthEventCopyWith<$Res>  {
$AuthEventCopyWith(AuthEvent _, $Res Function(AuthEvent) __);
}


/// Adds pattern-matching-related methods to [AuthEvent].
extension AuthEventPatterns on AuthEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AuthStarted value)?  started,TResult Function( AuthLoginRequested value)?  loginRequested,TResult Function( AuthOtpVerifyRequested value)?  otpVerifyRequested,TResult Function( AuthOtpResendRequested value)?  otpResendRequested,TResult Function( AuthLogoutRequested value)?  logoutRequested,TResult Function( AuthSessionCleared value)?  sessionCleared,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AuthStarted() when started != null:
return started(_that);case AuthLoginRequested() when loginRequested != null:
return loginRequested(_that);case AuthOtpVerifyRequested() when otpVerifyRequested != null:
return otpVerifyRequested(_that);case AuthOtpResendRequested() when otpResendRequested != null:
return otpResendRequested(_that);case AuthLogoutRequested() when logoutRequested != null:
return logoutRequested(_that);case AuthSessionCleared() when sessionCleared != null:
return sessionCleared(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AuthStarted value)  started,required TResult Function( AuthLoginRequested value)  loginRequested,required TResult Function( AuthOtpVerifyRequested value)  otpVerifyRequested,required TResult Function( AuthOtpResendRequested value)  otpResendRequested,required TResult Function( AuthLogoutRequested value)  logoutRequested,required TResult Function( AuthSessionCleared value)  sessionCleared,}){
final _that = this;
switch (_that) {
case AuthStarted():
return started(_that);case AuthLoginRequested():
return loginRequested(_that);case AuthOtpVerifyRequested():
return otpVerifyRequested(_that);case AuthOtpResendRequested():
return otpResendRequested(_that);case AuthLogoutRequested():
return logoutRequested(_that);case AuthSessionCleared():
return sessionCleared(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AuthStarted value)?  started,TResult? Function( AuthLoginRequested value)?  loginRequested,TResult? Function( AuthOtpVerifyRequested value)?  otpVerifyRequested,TResult? Function( AuthOtpResendRequested value)?  otpResendRequested,TResult? Function( AuthLogoutRequested value)?  logoutRequested,TResult? Function( AuthSessionCleared value)?  sessionCleared,}){
final _that = this;
switch (_that) {
case AuthStarted() when started != null:
return started(_that);case AuthLoginRequested() when loginRequested != null:
return loginRequested(_that);case AuthOtpVerifyRequested() when otpVerifyRequested != null:
return otpVerifyRequested(_that);case AuthOtpResendRequested() when otpResendRequested != null:
return otpResendRequested(_that);case AuthLogoutRequested() when logoutRequested != null:
return logoutRequested(_that);case AuthSessionCleared() when sessionCleared != null:
return sessionCleared(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( String account,  String password)?  loginRequested,TResult Function( String code)?  otpVerifyRequested,TResult Function()?  otpResendRequested,TResult Function()?  logoutRequested,TResult Function()?  sessionCleared,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AuthStarted() when started != null:
return started();case AuthLoginRequested() when loginRequested != null:
return loginRequested(_that.account,_that.password);case AuthOtpVerifyRequested() when otpVerifyRequested != null:
return otpVerifyRequested(_that.code);case AuthOtpResendRequested() when otpResendRequested != null:
return otpResendRequested();case AuthLogoutRequested() when logoutRequested != null:
return logoutRequested();case AuthSessionCleared() when sessionCleared != null:
return sessionCleared();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( String account,  String password)  loginRequested,required TResult Function( String code)  otpVerifyRequested,required TResult Function()  otpResendRequested,required TResult Function()  logoutRequested,required TResult Function()  sessionCleared,}) {final _that = this;
switch (_that) {
case AuthStarted():
return started();case AuthLoginRequested():
return loginRequested(_that.account,_that.password);case AuthOtpVerifyRequested():
return otpVerifyRequested(_that.code);case AuthOtpResendRequested():
return otpResendRequested();case AuthLogoutRequested():
return logoutRequested();case AuthSessionCleared():
return sessionCleared();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( String account,  String password)?  loginRequested,TResult? Function( String code)?  otpVerifyRequested,TResult? Function()?  otpResendRequested,TResult? Function()?  logoutRequested,TResult? Function()?  sessionCleared,}) {final _that = this;
switch (_that) {
case AuthStarted() when started != null:
return started();case AuthLoginRequested() when loginRequested != null:
return loginRequested(_that.account,_that.password);case AuthOtpVerifyRequested() when otpVerifyRequested != null:
return otpVerifyRequested(_that.code);case AuthOtpResendRequested() when otpResendRequested != null:
return otpResendRequested();case AuthLogoutRequested() when logoutRequested != null:
return logoutRequested();case AuthSessionCleared() when sessionCleared != null:
return sessionCleared();case _:
  return null;

}
}

}

/// @nodoc


class AuthStarted implements AuthEvent {
  const AuthStarted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthStarted);
}


@override
int get hashCode => runtimeType.hashCode;



}




/// @nodoc


class AuthLoginRequested implements AuthEvent {
  const AuthLoginRequested({required this.account, required this.password});
  

 final  String account;
 final  String password;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthLoginRequestedCopyWith<AuthLoginRequested> get copyWith => _$AuthLoginRequestedCopyWithImpl<AuthLoginRequested>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthLoginRequested&&(identical(other.account, account) || other.account == account)&&(identical(other.password, password) || other.password == password));
}


@override
int get hashCode => Object.hash(runtimeType,account,password);



}

/// @nodoc
abstract mixin class $AuthLoginRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthLoginRequestedCopyWith(AuthLoginRequested value, $Res Function(AuthLoginRequested) _then) = _$AuthLoginRequestedCopyWithImpl;
@useResult
$Res call({
 String account, String password
});




}
/// @nodoc
class _$AuthLoginRequestedCopyWithImpl<$Res>
    implements $AuthLoginRequestedCopyWith<$Res> {
  _$AuthLoginRequestedCopyWithImpl(this._self, this._then);

  final AuthLoginRequested _self;
  final $Res Function(AuthLoginRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? account = null,Object? password = null,}) {
  return _then(AuthLoginRequested(
account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthOtpVerifyRequested implements AuthEvent {
  const AuthOtpVerifyRequested({required this.code});


 final  String code;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthOtpVerifyRequestedCopyWith<AuthOtpVerifyRequested> get copyWith => _$AuthOtpVerifyRequestedCopyWithImpl<AuthOtpVerifyRequested>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthOtpVerifyRequested&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,code);



}

/// @nodoc
abstract mixin class $AuthOtpVerifyRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthOtpVerifyRequestedCopyWith(AuthOtpVerifyRequested value, $Res Function(AuthOtpVerifyRequested) _then) = _$AuthOtpVerifyRequestedCopyWithImpl;
@useResult
$Res call({
 String code
});




}
/// @nodoc
class _$AuthOtpVerifyRequestedCopyWithImpl<$Res>
    implements $AuthOtpVerifyRequestedCopyWith<$Res> {
  _$AuthOtpVerifyRequestedCopyWithImpl(this._self, this._then);

  final AuthOtpVerifyRequested _self;
  final $Res Function(AuthOtpVerifyRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(AuthOtpVerifyRequested(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthOtpResendRequested implements AuthEvent {
  const AuthOtpResendRequested();







@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthOtpResendRequested);
}


@override
int get hashCode => runtimeType.hashCode;



}




/// @nodoc


class AuthLogoutRequested implements AuthEvent {
  const AuthLogoutRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthLogoutRequested);
}


@override
int get hashCode => runtimeType.hashCode;



}




/// @nodoc


class AuthSessionCleared implements AuthEvent {
  const AuthSessionCleared();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSessionCleared);
}


@override
int get hashCode => runtimeType.hashCode;



}




/// @nodoc
mixin _$AuthState {

 AuthPresentationStatus get status; bool get isLoading; AuthUser? get user; OtpChallenge? get otpChallenge; Failure? get failure; AuthFailureOperation? get failureOperation;
/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthStateCopyWith<AuthState> get copyWith => _$AuthStateCopyWithImpl<AuthState>(this as AuthState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState&&(identical(other.status, status) || other.status == status)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.user, user) || other.user == user)&&(identical(other.otpChallenge, otpChallenge) || other.otpChallenge == otpChallenge)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.failureOperation, failureOperation) || other.failureOperation == failureOperation));
}


@override
int get hashCode => Object.hash(runtimeType,status,isLoading,user,otpChallenge,failure,failureOperation);

@override
String toString() {
  return 'AuthState(status: $status, isLoading: $isLoading, user: $user, otpChallenge: $otpChallenge, failure: $failure, failureOperation: $failureOperation)';
}


}

/// @nodoc
abstract mixin class $AuthStateCopyWith<$Res>  {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) _then) = _$AuthStateCopyWithImpl;
@useResult
$Res call({
 AuthPresentationStatus status, bool isLoading, AuthUser? user, OtpChallenge? otpChallenge, Failure? failure, AuthFailureOperation? failureOperation
});


$AuthUserCopyWith<$Res>? get user;

}
/// @nodoc
class _$AuthStateCopyWithImpl<$Res>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._self, this._then);

  final AuthState _self;
  final $Res Function(AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? isLoading = null,Object? user = freezed,Object? otpChallenge = freezed,Object? failure = freezed,Object? failureOperation = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AuthPresentationStatus,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AuthUser?,otpChallenge: freezed == otpChallenge ? _self.otpChallenge : otpChallenge // ignore: cast_nullable_to_non_nullable
as OtpChallenge?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,failureOperation: freezed == failureOperation ? _self.failureOperation : failureOperation // ignore: cast_nullable_to_non_nullable
as AuthFailureOperation?,
  ));
}
/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthUserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $AuthUserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthState].
extension AuthStatePatterns on AuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthState value)  $default,){
final _that = this;
switch (_that) {
case _AuthState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthState value)?  $default,){
final _that = this;
switch (_that) {
case _AuthState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AuthPresentationStatus status,  bool isLoading,  AuthUser? user,  OtpChallenge? otpChallenge,  Failure? failure,  AuthFailureOperation? failureOperation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that.status,_that.isLoading,_that.user,_that.otpChallenge,_that.failure,_that.failureOperation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AuthPresentationStatus status,  bool isLoading,  AuthUser? user,  OtpChallenge? otpChallenge,  Failure? failure,  AuthFailureOperation? failureOperation)  $default,) {final _that = this;
switch (_that) {
case _AuthState():
return $default(_that.status,_that.isLoading,_that.user,_that.otpChallenge,_that.failure,_that.failureOperation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AuthPresentationStatus status,  bool isLoading,  AuthUser? user,  OtpChallenge? otpChallenge,  Failure? failure,  AuthFailureOperation? failureOperation)?  $default,) {final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that.status,_that.isLoading,_that.user,_that.otpChallenge,_that.failure,_that.failureOperation);case _:
  return null;

}
}

}

/// @nodoc


class _AuthState extends AuthState {
  const _AuthState({this.status = AuthPresentationStatus.unauthenticated, required this.isLoading, required this.user, this.otpChallenge = null, required this.failure, required this.failureOperation}): super._();
  

@override@JsonKey() final  AuthPresentationStatus status;
@override final  bool isLoading;
@override final  AuthUser? user;
@override@JsonKey() final  OtpChallenge? otpChallenge;
@override final  Failure? failure;
@override final  AuthFailureOperation? failureOperation;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthStateCopyWith<_AuthState> get copyWith => __$AuthStateCopyWithImpl<_AuthState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthState&&(identical(other.status, status) || other.status == status)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.user, user) || other.user == user)&&(identical(other.otpChallenge, otpChallenge) || other.otpChallenge == otpChallenge)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.failureOperation, failureOperation) || other.failureOperation == failureOperation));
}


@override
int get hashCode => Object.hash(runtimeType,status,isLoading,user,otpChallenge,failure,failureOperation);

@override
String toString() {
  return 'AuthState(status: $status, isLoading: $isLoading, user: $user, otpChallenge: $otpChallenge, failure: $failure, failureOperation: $failureOperation)';
}


}

/// @nodoc
abstract mixin class _$AuthStateCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$AuthStateCopyWith(_AuthState value, $Res Function(_AuthState) _then) = __$AuthStateCopyWithImpl;
@override @useResult
$Res call({
 AuthPresentationStatus status, bool isLoading, AuthUser? user, OtpChallenge? otpChallenge, Failure? failure, AuthFailureOperation? failureOperation
});


@override $AuthUserCopyWith<$Res>? get user;

}
/// @nodoc
class __$AuthStateCopyWithImpl<$Res>
    implements _$AuthStateCopyWith<$Res> {
  __$AuthStateCopyWithImpl(this._self, this._then);

  final _AuthState _self;
  final $Res Function(_AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? isLoading = null,Object? user = freezed,Object? otpChallenge = freezed,Object? failure = freezed,Object? failureOperation = freezed,}) {
  return _then(_AuthState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AuthPresentationStatus,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AuthUser?,otpChallenge: freezed == otpChallenge ? _self.otpChallenge : otpChallenge // ignore: cast_nullable_to_non_nullable
as OtpChallenge?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,failureOperation: freezed == failureOperation ? _self.failureOperation : failureOperation // ignore: cast_nullable_to_non_nullable
as AuthFailureOperation?,
  ));
}

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthUserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $AuthUserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on

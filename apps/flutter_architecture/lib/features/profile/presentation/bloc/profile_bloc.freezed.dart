// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileEvent()';
}


}

/// @nodoc
class $ProfileEventCopyWith<$Res>  {
$ProfileEventCopyWith(ProfileEvent _, $Res Function(ProfileEvent) __);
}


/// Adds pattern-matching-related methods to [ProfileEvent].
extension ProfileEventPatterns on ProfileEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ProfileRequested value)?  requested,TResult Function( ProfileLogoutRequested value)?  logoutRequested,TResult Function( ProfileSessionCleared value)?  sessionCleared,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProfileRequested() when requested != null:
return requested(_that);case ProfileLogoutRequested() when logoutRequested != null:
return logoutRequested(_that);case ProfileSessionCleared() when sessionCleared != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ProfileRequested value)  requested,required TResult Function( ProfileLogoutRequested value)  logoutRequested,required TResult Function( ProfileSessionCleared value)  sessionCleared,}){
final _that = this;
switch (_that) {
case ProfileRequested():
return requested(_that);case ProfileLogoutRequested():
return logoutRequested(_that);case ProfileSessionCleared():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ProfileRequested value)?  requested,TResult? Function( ProfileLogoutRequested value)?  logoutRequested,TResult? Function( ProfileSessionCleared value)?  sessionCleared,}){
final _that = this;
switch (_that) {
case ProfileRequested() when requested != null:
return requested(_that);case ProfileLogoutRequested() when logoutRequested != null:
return logoutRequested(_that);case ProfileSessionCleared() when sessionCleared != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  requested,TResult Function()?  logoutRequested,TResult Function()?  sessionCleared,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProfileRequested() when requested != null:
return requested();case ProfileLogoutRequested() when logoutRequested != null:
return logoutRequested();case ProfileSessionCleared() when sessionCleared != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  requested,required TResult Function()  logoutRequested,required TResult Function()  sessionCleared,}) {final _that = this;
switch (_that) {
case ProfileRequested():
return requested();case ProfileLogoutRequested():
return logoutRequested();case ProfileSessionCleared():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  requested,TResult? Function()?  logoutRequested,TResult? Function()?  sessionCleared,}) {final _that = this;
switch (_that) {
case ProfileRequested() when requested != null:
return requested();case ProfileLogoutRequested() when logoutRequested != null:
return logoutRequested();case ProfileSessionCleared() when sessionCleared != null:
return sessionCleared();case _:
  return null;

}
}

}

/// @nodoc


class ProfileRequested implements ProfileEvent {
  const ProfileRequested();







@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileEvent.requested()';
}


}




/// @nodoc


class ProfileLogoutRequested implements ProfileEvent {
  const ProfileLogoutRequested();







@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileLogoutRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileEvent.logoutRequested()';
}


}




/// @nodoc


class ProfileSessionCleared implements ProfileEvent {
  const ProfileSessionCleared();







@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileSessionCleared);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileEvent.sessionCleared()';
}


}




/// @nodoc
mixin _$ProfileState {

 bool get isLoading; bool get isAuthenticated; bool get logoutSucceeded; Profile? get profile; Failure? get failure; ProfileFailureOperation? get failureOperation;
/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileStateCopyWith<ProfileState> get copyWith => _$ProfileStateCopyWithImpl<ProfileState>(this as ProfileState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isAuthenticated, isAuthenticated) || other.isAuthenticated == isAuthenticated)&&(identical(other.logoutSucceeded, logoutSucceeded) || other.logoutSucceeded == logoutSucceeded)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.failureOperation, failureOperation) || other.failureOperation == failureOperation));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isAuthenticated,logoutSucceeded,profile,failure,failureOperation);

@override
String toString() {
  return 'ProfileState(isLoading: $isLoading, isAuthenticated: $isAuthenticated, logoutSucceeded: $logoutSucceeded, profile: $profile, failure: $failure, failureOperation: $failureOperation)';
}


}

/// @nodoc
abstract mixin class $ProfileStateCopyWith<$Res>  {
  factory $ProfileStateCopyWith(ProfileState value, $Res Function(ProfileState) _then) = _$ProfileStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool isAuthenticated, bool logoutSucceeded, Profile? profile, Failure? failure, ProfileFailureOperation? failureOperation
});


$ProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class _$ProfileStateCopyWithImpl<$Res>
    implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._self, this._then);

  final ProfileState _self;
  final $Res Function(ProfileState) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? isAuthenticated = null,Object? logoutSucceeded = null,Object? profile = freezed,Object? failure = freezed,Object? failureOperation = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isAuthenticated: null == isAuthenticated ? _self.isAuthenticated : isAuthenticated // ignore: cast_nullable_to_non_nullable
as bool,logoutSucceeded: null == logoutSucceeded ? _self.logoutSucceeded : logoutSucceeded // ignore: cast_nullable_to_non_nullable
as bool,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,failureOperation: freezed == failureOperation ? _self.failureOperation : failureOperation // ignore: cast_nullable_to_non_nullable
as ProfileFailureOperation?,
  ));
}
/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $ProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProfileState].
extension ProfileStatePatterns on ProfileState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileState value)  $default,){
final _that = this;
switch (_that) {
case _ProfileState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileState value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool isAuthenticated,  bool logoutSucceeded,  Profile? profile,  Failure? failure,  ProfileFailureOperation? failureOperation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
return $default(_that.isLoading,_that.isAuthenticated,_that.logoutSucceeded,_that.profile,_that.failure,_that.failureOperation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool isAuthenticated,  bool logoutSucceeded,  Profile? profile,  Failure? failure,  ProfileFailureOperation? failureOperation)  $default,) {final _that = this;
switch (_that) {
case _ProfileState():
return $default(_that.isLoading,_that.isAuthenticated,_that.logoutSucceeded,_that.profile,_that.failure,_that.failureOperation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool isAuthenticated,  bool logoutSucceeded,  Profile? profile,  Failure? failure,  ProfileFailureOperation? failureOperation)?  $default,) {final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
return $default(_that.isLoading,_that.isAuthenticated,_that.logoutSucceeded,_that.profile,_that.failure,_that.failureOperation);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileState implements ProfileState {
  const _ProfileState({required this.isLoading, required this.isAuthenticated, required this.logoutSucceeded, required this.profile, required this.failure, required this.failureOperation});


@override final  bool isLoading;
@override final  bool isAuthenticated;
@override final  bool logoutSucceeded;
@override final  Profile? profile;
@override final  Failure? failure;
@override final  ProfileFailureOperation? failureOperation;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileStateCopyWith<_ProfileState> get copyWith => __$ProfileStateCopyWithImpl<_ProfileState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isAuthenticated, isAuthenticated) || other.isAuthenticated == isAuthenticated)&&(identical(other.logoutSucceeded, logoutSucceeded) || other.logoutSucceeded == logoutSucceeded)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.failureOperation, failureOperation) || other.failureOperation == failureOperation));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isAuthenticated,logoutSucceeded,profile,failure,failureOperation);

@override
String toString() {
  return 'ProfileState(isLoading: $isLoading, isAuthenticated: $isAuthenticated, logoutSucceeded: $logoutSucceeded, profile: $profile, failure: $failure, failureOperation: $failureOperation)';
}


}

/// @nodoc
abstract mixin class _$ProfileStateCopyWith<$Res> implements $ProfileStateCopyWith<$Res> {
  factory _$ProfileStateCopyWith(_ProfileState value, $Res Function(_ProfileState) _then) = __$ProfileStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool isAuthenticated, bool logoutSucceeded, Profile? profile, Failure? failure, ProfileFailureOperation? failureOperation
});


@override $ProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class __$ProfileStateCopyWithImpl<$Res>
    implements _$ProfileStateCopyWith<$Res> {
  __$ProfileStateCopyWithImpl(this._self, this._then);

  final _ProfileState _self;
  final $Res Function(_ProfileState) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? isAuthenticated = null,Object? logoutSucceeded = null,Object? profile = freezed,Object? failure = freezed,Object? failureOperation = freezed,}) {
  return _then(_ProfileState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isAuthenticated: null == isAuthenticated ? _self.isAuthenticated : isAuthenticated // ignore: cast_nullable_to_non_nullable
as bool,logoutSucceeded: null == logoutSucceeded ? _self.logoutSucceeded : logoutSucceeded // ignore: cast_nullable_to_non_nullable
as bool,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,failureOperation: freezed == failureOperation ? _self.failureOperation : failureOperation // ignore: cast_nullable_to_non_nullable
as ProfileFailureOperation?,
  ));
}

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $ProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}

// dart format on

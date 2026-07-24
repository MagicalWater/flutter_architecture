// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CatalogEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CatalogEvent()';
}


}

/// @nodoc
class $CatalogEventCopyWith<$Res>  {
$CatalogEventCopyWith(CatalogEvent _, $Res Function(CatalogEvent) __);
}


/// Adds pattern-matching-related methods to [CatalogEvent].
extension CatalogEventPatterns on CatalogEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CatalogInitialRequested value)?  initialRequested,TResult Function( CatalogQueryChanged value)?  queryChanged,TResult Function( CatalogLoadMoreRequested value)?  loadMoreRequested,TResult Function( CatalogRefreshRequested value)?  refreshRequested,TResult Function( CatalogReconnectObserved value)?  reconnectObserved,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CatalogInitialRequested() when initialRequested != null:
return initialRequested(_that);case CatalogQueryChanged() when queryChanged != null:
return queryChanged(_that);case CatalogLoadMoreRequested() when loadMoreRequested != null:
return loadMoreRequested(_that);case CatalogRefreshRequested() when refreshRequested != null:
return refreshRequested(_that);case CatalogReconnectObserved() when reconnectObserved != null:
return reconnectObserved(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CatalogInitialRequested value)  initialRequested,required TResult Function( CatalogQueryChanged value)  queryChanged,required TResult Function( CatalogLoadMoreRequested value)  loadMoreRequested,required TResult Function( CatalogRefreshRequested value)  refreshRequested,required TResult Function( CatalogReconnectObserved value)  reconnectObserved,}){
final _that = this;
switch (_that) {
case CatalogInitialRequested():
return initialRequested(_that);case CatalogQueryChanged():
return queryChanged(_that);case CatalogLoadMoreRequested():
return loadMoreRequested(_that);case CatalogRefreshRequested():
return refreshRequested(_that);case CatalogReconnectObserved():
return reconnectObserved(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CatalogInitialRequested value)?  initialRequested,TResult? Function( CatalogQueryChanged value)?  queryChanged,TResult? Function( CatalogLoadMoreRequested value)?  loadMoreRequested,TResult? Function( CatalogRefreshRequested value)?  refreshRequested,TResult? Function( CatalogReconnectObserved value)?  reconnectObserved,}){
final _that = this;
switch (_that) {
case CatalogInitialRequested() when initialRequested != null:
return initialRequested(_that);case CatalogQueryChanged() when queryChanged != null:
return queryChanged(_that);case CatalogLoadMoreRequested() when loadMoreRequested != null:
return loadMoreRequested(_that);case CatalogRefreshRequested() when refreshRequested != null:
return refreshRequested(_that);case CatalogReconnectObserved() when reconnectObserved != null:
return reconnectObserved(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initialRequested,TResult Function( String query)?  queryChanged,TResult Function()?  loadMoreRequested,TResult Function()?  refreshRequested,TResult Function()?  reconnectObserved,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CatalogInitialRequested() when initialRequested != null:
return initialRequested();case CatalogQueryChanged() when queryChanged != null:
return queryChanged(_that.query);case CatalogLoadMoreRequested() when loadMoreRequested != null:
return loadMoreRequested();case CatalogRefreshRequested() when refreshRequested != null:
return refreshRequested();case CatalogReconnectObserved() when reconnectObserved != null:
return reconnectObserved();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initialRequested,required TResult Function( String query)  queryChanged,required TResult Function()  loadMoreRequested,required TResult Function()  refreshRequested,required TResult Function()  reconnectObserved,}) {final _that = this;
switch (_that) {
case CatalogInitialRequested():
return initialRequested();case CatalogQueryChanged():
return queryChanged(_that.query);case CatalogLoadMoreRequested():
return loadMoreRequested();case CatalogRefreshRequested():
return refreshRequested();case CatalogReconnectObserved():
return reconnectObserved();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initialRequested,TResult? Function( String query)?  queryChanged,TResult? Function()?  loadMoreRequested,TResult? Function()?  refreshRequested,TResult? Function()?  reconnectObserved,}) {final _that = this;
switch (_that) {
case CatalogInitialRequested() when initialRequested != null:
return initialRequested();case CatalogQueryChanged() when queryChanged != null:
return queryChanged(_that.query);case CatalogLoadMoreRequested() when loadMoreRequested != null:
return loadMoreRequested();case CatalogRefreshRequested() when refreshRequested != null:
return refreshRequested();case CatalogReconnectObserved() when reconnectObserved != null:
return reconnectObserved();case _:
  return null;

}
}

}

/// @nodoc


class CatalogInitialRequested implements CatalogEvent {
  const CatalogInitialRequested();







@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogInitialRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CatalogEvent.initialRequested()';
}


}




/// @nodoc


class CatalogQueryChanged implements CatalogEvent {
  const CatalogQueryChanged(this.query);


 final  String query;

/// Create a copy of CatalogEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogQueryChangedCopyWith<CatalogQueryChanged> get copyWith => _$CatalogQueryChangedCopyWithImpl<CatalogQueryChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogQueryChanged&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,query);

@override
String toString() {
  return 'CatalogEvent.queryChanged(query: $query)';
}


}

/// @nodoc
abstract mixin class $CatalogQueryChangedCopyWith<$Res> implements $CatalogEventCopyWith<$Res> {
  factory $CatalogQueryChangedCopyWith(CatalogQueryChanged value, $Res Function(CatalogQueryChanged) _then) = _$CatalogQueryChangedCopyWithImpl;
@useResult
$Res call({
 String query
});




}
/// @nodoc
class _$CatalogQueryChangedCopyWithImpl<$Res>
    implements $CatalogQueryChangedCopyWith<$Res> {
  _$CatalogQueryChangedCopyWithImpl(this._self, this._then);

  final CatalogQueryChanged _self;
  final $Res Function(CatalogQueryChanged) _then;

/// Create a copy of CatalogEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? query = null,}) {
  return _then(CatalogQueryChanged(
null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CatalogLoadMoreRequested implements CatalogEvent {
  const CatalogLoadMoreRequested();







@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogLoadMoreRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CatalogEvent.loadMoreRequested()';
}


}




/// @nodoc


class CatalogRefreshRequested implements CatalogEvent {
  const CatalogRefreshRequested();







@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogRefreshRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CatalogEvent.refreshRequested()';
}


}




/// @nodoc


class CatalogReconnectObserved implements CatalogEvent {
  const CatalogReconnectObserved();







@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogReconnectObserved);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CatalogEvent.reconnectObserved()';
}


}




/// @nodoc
mixin _$CatalogState {

 String get query; List<CatalogItem> get items; String? get nextCursor; bool get isInitialLoading; bool get isRefreshing; bool get isLoadingMore; bool get hasCompletedInitialLoad; bool get isUsingCachedData; bool get isStale; DateTime? get lastUpdatedAt; bool get isRevalidating; bool get isReconnectRevalidating; Failure? get initialFailure; Failure? get revalidationFailure; Failure? get reconnectFailure; Failure? get refreshFailure; Failure? get appendFailure;
/// Create a copy of CatalogState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogStateCopyWith<CatalogState> get copyWith => _$CatalogStateCopyWithImpl<CatalogState>(this as CatalogState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogState&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.isInitialLoading, isInitialLoading) || other.isInitialLoading == isInitialLoading)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.hasCompletedInitialLoad, hasCompletedInitialLoad) || other.hasCompletedInitialLoad == hasCompletedInitialLoad)&&(identical(other.isUsingCachedData, isUsingCachedData) || other.isUsingCachedData == isUsingCachedData)&&(identical(other.isStale, isStale) || other.isStale == isStale)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.isRevalidating, isRevalidating) || other.isRevalidating == isRevalidating)&&(identical(other.isReconnectRevalidating, isReconnectRevalidating) || other.isReconnectRevalidating == isReconnectRevalidating)&&(identical(other.initialFailure, initialFailure) || other.initialFailure == initialFailure)&&(identical(other.revalidationFailure, revalidationFailure) || other.revalidationFailure == revalidationFailure)&&(identical(other.reconnectFailure, reconnectFailure) || other.reconnectFailure == reconnectFailure)&&(identical(other.refreshFailure, refreshFailure) || other.refreshFailure == refreshFailure)&&(identical(other.appendFailure, appendFailure) || other.appendFailure == appendFailure));
}


@override
int get hashCode => Object.hash(runtimeType,query,const DeepCollectionEquality().hash(items),nextCursor,isInitialLoading,isRefreshing,isLoadingMore,hasCompletedInitialLoad,isUsingCachedData,isStale,lastUpdatedAt,isRevalidating,isReconnectRevalidating,initialFailure,revalidationFailure,reconnectFailure,refreshFailure,appendFailure);

@override
String toString() {
  return 'CatalogState(query: $query, items: $items, nextCursor: $nextCursor, isInitialLoading: $isInitialLoading, isRefreshing: $isRefreshing, isLoadingMore: $isLoadingMore, hasCompletedInitialLoad: $hasCompletedInitialLoad, isUsingCachedData: $isUsingCachedData, isStale: $isStale, lastUpdatedAt: $lastUpdatedAt, isRevalidating: $isRevalidating, isReconnectRevalidating: $isReconnectRevalidating, initialFailure: $initialFailure, revalidationFailure: $revalidationFailure, reconnectFailure: $reconnectFailure, refreshFailure: $refreshFailure, appendFailure: $appendFailure)';
}


}

/// @nodoc
abstract mixin class $CatalogStateCopyWith<$Res>  {
  factory $CatalogStateCopyWith(CatalogState value, $Res Function(CatalogState) _then) = _$CatalogStateCopyWithImpl;
@useResult
$Res call({
 String query, List<CatalogItem> items, String? nextCursor, bool isInitialLoading, bool isRefreshing, bool isLoadingMore, bool hasCompletedInitialLoad, bool isUsingCachedData, bool isStale, DateTime? lastUpdatedAt, bool isRevalidating, bool isReconnectRevalidating, Failure? initialFailure, Failure? revalidationFailure, Failure? reconnectFailure, Failure? refreshFailure, Failure? appendFailure
});




}
/// @nodoc
class _$CatalogStateCopyWithImpl<$Res>
    implements $CatalogStateCopyWith<$Res> {
  _$CatalogStateCopyWithImpl(this._self, this._then);

  final CatalogState _self;
  final $Res Function(CatalogState) _then;

/// Create a copy of CatalogState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? items = null,Object? nextCursor = freezed,Object? isInitialLoading = null,Object? isRefreshing = null,Object? isLoadingMore = null,Object? hasCompletedInitialLoad = null,Object? isUsingCachedData = null,Object? isStale = null,Object? lastUpdatedAt = freezed,Object? isRevalidating = null,Object? isReconnectRevalidating = null,Object? initialFailure = freezed,Object? revalidationFailure = freezed,Object? reconnectFailure = freezed,Object? refreshFailure = freezed,Object? appendFailure = freezed,}) {
  return _then(CatalogState(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CatalogItem>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,isInitialLoading: null == isInitialLoading ? _self.isInitialLoading : isInitialLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasCompletedInitialLoad: null == hasCompletedInitialLoad ? _self.hasCompletedInitialLoad : hasCompletedInitialLoad // ignore: cast_nullable_to_non_nullable
as bool,isUsingCachedData: null == isUsingCachedData ? _self.isUsingCachedData : isUsingCachedData // ignore: cast_nullable_to_non_nullable
as bool,isStale: null == isStale ? _self.isStale : isStale // ignore: cast_nullable_to_non_nullable
as bool,lastUpdatedAt: freezed == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isRevalidating: null == isRevalidating ? _self.isRevalidating : isRevalidating // ignore: cast_nullable_to_non_nullable
as bool,isReconnectRevalidating: null == isReconnectRevalidating ? _self.isReconnectRevalidating : isReconnectRevalidating // ignore: cast_nullable_to_non_nullable
as bool,initialFailure: freezed == initialFailure ? _self.initialFailure : initialFailure // ignore: cast_nullable_to_non_nullable
as Failure?,revalidationFailure: freezed == revalidationFailure ? _self.revalidationFailure : revalidationFailure // ignore: cast_nullable_to_non_nullable
as Failure?,reconnectFailure: freezed == reconnectFailure ? _self.reconnectFailure : reconnectFailure // ignore: cast_nullable_to_non_nullable
as Failure?,refreshFailure: freezed == refreshFailure ? _self.refreshFailure : refreshFailure // ignore: cast_nullable_to_non_nullable
as Failure?,appendFailure: freezed == appendFailure ? _self.appendFailure : appendFailure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogState].
extension CatalogStatePatterns on CatalogState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogState value)  $default,){
final _that = this;
switch (_that) {
case _CatalogState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogState value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  List<CatalogItem> items,  String? nextCursor,  bool isInitialLoading,  bool isRefreshing,  bool isLoadingMore,  bool hasCompletedInitialLoad,  bool isUsingCachedData,  bool isStale,  DateTime? lastUpdatedAt,  bool isRevalidating,  bool isReconnectRevalidating,  Failure? initialFailure,  Failure? revalidationFailure,  Failure? reconnectFailure,  Failure? refreshFailure,  Failure? appendFailure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogState() when $default != null:
return $default(_that.query,_that.items,_that.nextCursor,_that.isInitialLoading,_that.isRefreshing,_that.isLoadingMore,_that.hasCompletedInitialLoad,_that.isUsingCachedData,_that.isStale,_that.lastUpdatedAt,_that.isRevalidating,_that.isReconnectRevalidating,_that.initialFailure,_that.revalidationFailure,_that.reconnectFailure,_that.refreshFailure,_that.appendFailure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  List<CatalogItem> items,  String? nextCursor,  bool isInitialLoading,  bool isRefreshing,  bool isLoadingMore,  bool hasCompletedInitialLoad,  bool isUsingCachedData,  bool isStale,  DateTime? lastUpdatedAt,  bool isRevalidating,  bool isReconnectRevalidating,  Failure? initialFailure,  Failure? revalidationFailure,  Failure? reconnectFailure,  Failure? refreshFailure,  Failure? appendFailure)  $default,) {final _that = this;
switch (_that) {
case _CatalogState():
return $default(_that.query,_that.items,_that.nextCursor,_that.isInitialLoading,_that.isRefreshing,_that.isLoadingMore,_that.hasCompletedInitialLoad,_that.isUsingCachedData,_that.isStale,_that.lastUpdatedAt,_that.isRevalidating,_that.isReconnectRevalidating,_that.initialFailure,_that.revalidationFailure,_that.reconnectFailure,_that.refreshFailure,_that.appendFailure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  List<CatalogItem> items,  String? nextCursor,  bool isInitialLoading,  bool isRefreshing,  bool isLoadingMore,  bool hasCompletedInitialLoad,  bool isUsingCachedData,  bool isStale,  DateTime? lastUpdatedAt,  bool isRevalidating,  bool isReconnectRevalidating,  Failure? initialFailure,  Failure? revalidationFailure,  Failure? reconnectFailure,  Failure? refreshFailure,  Failure? appendFailure)?  $default,) {final _that = this;
switch (_that) {
case _CatalogState() when $default != null:
return $default(_that.query,_that.items,_that.nextCursor,_that.isInitialLoading,_that.isRefreshing,_that.isLoadingMore,_that.hasCompletedInitialLoad,_that.isUsingCachedData,_that.isStale,_that.lastUpdatedAt,_that.isRevalidating,_that.isReconnectRevalidating,_that.initialFailure,_that.revalidationFailure,_that.reconnectFailure,_that.refreshFailure,_that.appendFailure);case _:
  return null;

}
}

}

/// @nodoc


class _CatalogState extends CatalogState {
  const _CatalogState({required this.query, required  List<CatalogItem> items, required this.nextCursor, required this.isInitialLoading, required this.isRefreshing, required this.isLoadingMore, required this.hasCompletedInitialLoad, required this.isUsingCachedData, required this.isStale, required this.lastUpdatedAt, required this.isRevalidating, required this.isReconnectRevalidating, required this.initialFailure, required this.revalidationFailure, required this.reconnectFailure, required this.refreshFailure, required this.appendFailure}): _items = items,super._();


@override final  String query;
 final  List<CatalogItem> _items;
@override List<CatalogItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? nextCursor;
@override final  bool isInitialLoading;
@override final  bool isRefreshing;
@override final  bool isLoadingMore;
@override final  bool hasCompletedInitialLoad;
@override final  bool isUsingCachedData;
@override final  bool isStale;
@override final  DateTime? lastUpdatedAt;
@override final  bool isRevalidating;
@override final  bool isReconnectRevalidating;
@override final  Failure? initialFailure;
@override final  Failure? revalidationFailure;
@override final  Failure? reconnectFailure;
@override final  Failure? refreshFailure;
@override final  Failure? appendFailure;

/// Create a copy of CatalogState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogStateCopyWith<_CatalogState> get copyWith => __$CatalogStateCopyWithImpl<_CatalogState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogState&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.isInitialLoading, isInitialLoading) || other.isInitialLoading == isInitialLoading)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.hasCompletedInitialLoad, hasCompletedInitialLoad) || other.hasCompletedInitialLoad == hasCompletedInitialLoad)&&(identical(other.isUsingCachedData, isUsingCachedData) || other.isUsingCachedData == isUsingCachedData)&&(identical(other.isStale, isStale) || other.isStale == isStale)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.isRevalidating, isRevalidating) || other.isRevalidating == isRevalidating)&&(identical(other.isReconnectRevalidating, isReconnectRevalidating) || other.isReconnectRevalidating == isReconnectRevalidating)&&(identical(other.initialFailure, initialFailure) || other.initialFailure == initialFailure)&&(identical(other.revalidationFailure, revalidationFailure) || other.revalidationFailure == revalidationFailure)&&(identical(other.reconnectFailure, reconnectFailure) || other.reconnectFailure == reconnectFailure)&&(identical(other.refreshFailure, refreshFailure) || other.refreshFailure == refreshFailure)&&(identical(other.appendFailure, appendFailure) || other.appendFailure == appendFailure));
}


@override
int get hashCode => Object.hash(runtimeType,query,const DeepCollectionEquality().hash(_items),nextCursor,isInitialLoading,isRefreshing,isLoadingMore,hasCompletedInitialLoad,isUsingCachedData,isStale,lastUpdatedAt,isRevalidating,isReconnectRevalidating,initialFailure,revalidationFailure,reconnectFailure,refreshFailure,appendFailure);

@override
String toString() {
  return 'CatalogState(query: $query, items: $items, nextCursor: $nextCursor, isInitialLoading: $isInitialLoading, isRefreshing: $isRefreshing, isLoadingMore: $isLoadingMore, hasCompletedInitialLoad: $hasCompletedInitialLoad, isUsingCachedData: $isUsingCachedData, isStale: $isStale, lastUpdatedAt: $lastUpdatedAt, isRevalidating: $isRevalidating, isReconnectRevalidating: $isReconnectRevalidating, initialFailure: $initialFailure, revalidationFailure: $revalidationFailure, reconnectFailure: $reconnectFailure, refreshFailure: $refreshFailure, appendFailure: $appendFailure)';
}


}

/// @nodoc
abstract mixin class _$CatalogStateCopyWith<$Res> implements $CatalogStateCopyWith<$Res> {
  factory _$CatalogStateCopyWith(_CatalogState value, $Res Function(_CatalogState) _then) = __$CatalogStateCopyWithImpl;
@override @useResult
$Res call({
 String query, List<CatalogItem> items, String? nextCursor, bool isInitialLoading, bool isRefreshing, bool isLoadingMore, bool hasCompletedInitialLoad, bool isUsingCachedData, bool isStale, DateTime? lastUpdatedAt, bool isRevalidating, bool isReconnectRevalidating, Failure? initialFailure, Failure? revalidationFailure, Failure? reconnectFailure, Failure? refreshFailure, Failure? appendFailure
});




}
/// @nodoc
class __$CatalogStateCopyWithImpl<$Res>
    implements _$CatalogStateCopyWith<$Res> {
  __$CatalogStateCopyWithImpl(this._self, this._then);

  final _CatalogState _self;
  final $Res Function(_CatalogState) _then;

/// Create a copy of CatalogState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? items = null,Object? nextCursor = freezed,Object? isInitialLoading = null,Object? isRefreshing = null,Object? isLoadingMore = null,Object? hasCompletedInitialLoad = null,Object? isUsingCachedData = null,Object? isStale = null,Object? lastUpdatedAt = freezed,Object? isRevalidating = null,Object? isReconnectRevalidating = null,Object? initialFailure = freezed,Object? revalidationFailure = freezed,Object? reconnectFailure = freezed,Object? refreshFailure = freezed,Object? appendFailure = freezed,}) {
  return _then(_CatalogState(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CatalogItem>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,isInitialLoading: null == isInitialLoading ? _self.isInitialLoading : isInitialLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasCompletedInitialLoad: null == hasCompletedInitialLoad ? _self.hasCompletedInitialLoad : hasCompletedInitialLoad // ignore: cast_nullable_to_non_nullable
as bool,isUsingCachedData: null == isUsingCachedData ? _self.isUsingCachedData : isUsingCachedData // ignore: cast_nullable_to_non_nullable
as bool,isStale: null == isStale ? _self.isStale : isStale // ignore: cast_nullable_to_non_nullable
as bool,lastUpdatedAt: freezed == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isRevalidating: null == isRevalidating ? _self.isRevalidating : isRevalidating // ignore: cast_nullable_to_non_nullable
as bool,isReconnectRevalidating: null == isReconnectRevalidating ? _self.isReconnectRevalidating : isReconnectRevalidating // ignore: cast_nullable_to_non_nullable
as bool,initialFailure: freezed == initialFailure ? _self.initialFailure : initialFailure // ignore: cast_nullable_to_non_nullable
as Failure?,revalidationFailure: freezed == revalidationFailure ? _self.revalidationFailure : revalidationFailure // ignore: cast_nullable_to_non_nullable
as Failure?,reconnectFailure: freezed == reconnectFailure ? _self.reconnectFailure : reconnectFailure // ignore: cast_nullable_to_non_nullable
as Failure?,refreshFailure: freezed == refreshFailure ? _self.refreshFailure : refreshFailure // ignore: cast_nullable_to_non_nullable
as Failure?,appendFailure: freezed == appendFailure ? _self.appendFailure : appendFailure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on

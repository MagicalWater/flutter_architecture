// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CatalogPage {

 List<CatalogItem> get items; String? get nextCursor;
/// Create a copy of CatalogPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogPageCopyWith<CatalogPage> get copyWith => _$CatalogPageCopyWithImpl<CatalogPage>(this as CatalogPage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogPage&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),nextCursor);

@override
String toString() {
  return 'CatalogPage(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $CatalogPageCopyWith<$Res>  {
  factory $CatalogPageCopyWith(CatalogPage value, $Res Function(CatalogPage) _then) = _$CatalogPageCopyWithImpl;
@useResult
$Res call({
 List<CatalogItem> items, String? nextCursor
});




}
/// @nodoc
class _$CatalogPageCopyWithImpl<$Res>
    implements $CatalogPageCopyWith<$Res> {
  _$CatalogPageCopyWithImpl(this._self, this._then);

  final CatalogPage _self;
  final $Res Function(CatalogPage) _then;

/// Create a copy of CatalogPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(CatalogPage(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CatalogItem>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogPage].
extension CatalogPagePatterns on CatalogPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogPage value)  $default,){
final _that = this;
switch (_that) {
case _CatalogPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogPage value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CatalogItem> items,  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogPage() when $default != null:
return $default(_that.items,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CatalogItem> items,  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _CatalogPage():
return $default(_that.items,_that.nextCursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CatalogItem> items,  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _CatalogPage() when $default != null:
return $default(_that.items,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc


class _CatalogPage extends CatalogPage {
  const _CatalogPage({required  List<CatalogItem> items, this.nextCursor}): _items = items,super._();


 final  List<CatalogItem> _items;
@override List<CatalogItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? nextCursor;

/// Create a copy of CatalogPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogPageCopyWith<_CatalogPage> get copyWith => __$CatalogPageCopyWithImpl<_CatalogPage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogPage&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor);

@override
String toString() {
  return 'CatalogPage(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$CatalogPageCopyWith<$Res> implements $CatalogPageCopyWith<$Res> {
  factory _$CatalogPageCopyWith(_CatalogPage value, $Res Function(_CatalogPage) _then) = __$CatalogPageCopyWithImpl;
@override @useResult
$Res call({
 List<CatalogItem> items, String? nextCursor
});




}
/// @nodoc
class __$CatalogPageCopyWithImpl<$Res>
    implements _$CatalogPageCopyWith<$Res> {
  __$CatalogPageCopyWithImpl(this._self, this._then);

  final _CatalogPage _self;
  final $Res Function(_CatalogPage) _then;

/// Create a copy of CatalogPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(_CatalogPage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CatalogItem>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

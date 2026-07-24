// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_page_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CatalogPageResponseDto {

@JsonKey(fromJson: _itemsFromJson, toJson: _itemsToJson) List<CatalogItemDto> get items; String? get nextCursor;
/// Create a copy of CatalogPageResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogPageResponseDtoCopyWith<CatalogPageResponseDto> get copyWith => _$CatalogPageResponseDtoCopyWithImpl<CatalogPageResponseDto>(this as CatalogPageResponseDto, _$identity);

  /// Serializes this CatalogPageResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogPageResponseDto&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),nextCursor);

@override
String toString() {
  return 'CatalogPageResponseDto(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $CatalogPageResponseDtoCopyWith<$Res>  {
  factory $CatalogPageResponseDtoCopyWith(CatalogPageResponseDto value, $Res Function(CatalogPageResponseDto) _then) = _$CatalogPageResponseDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _itemsFromJson, toJson: _itemsToJson) List<CatalogItemDto> items, String? nextCursor
});




}
/// @nodoc
class _$CatalogPageResponseDtoCopyWithImpl<$Res>
    implements $CatalogPageResponseDtoCopyWith<$Res> {
  _$CatalogPageResponseDtoCopyWithImpl(this._self, this._then);

  final CatalogPageResponseDto _self;
  final $Res Function(CatalogPageResponseDto) _then;

/// Create a copy of CatalogPageResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(CatalogPageResponseDto(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CatalogItemDto>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogPageResponseDto].
extension CatalogPageResponseDtoPatterns on CatalogPageResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogPageResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogPageResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogPageResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _CatalogPageResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogPageResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogPageResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _itemsFromJson, toJson: _itemsToJson)  List<CatalogItemDto> items,  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogPageResponseDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _itemsFromJson, toJson: _itemsToJson)  List<CatalogItemDto> items,  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _CatalogPageResponseDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _itemsFromJson, toJson: _itemsToJson)  List<CatalogItemDto> items,  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _CatalogPageResponseDto() when $default != null:
return $default(_that.items,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CatalogPageResponseDto implements CatalogPageResponseDto {
  const _CatalogPageResponseDto({@JsonKey(fromJson: _itemsFromJson, toJson: _itemsToJson) required  List<CatalogItemDto> items, this.nextCursor}): _items = items;
  factory _CatalogPageResponseDto.fromJson(Map<String, dynamic> json) => _$CatalogPageResponseDtoFromJson(json);

 final  List<CatalogItemDto> _items;
@override@JsonKey(fromJson: _itemsFromJson, toJson: _itemsToJson) List<CatalogItemDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? nextCursor;

/// Create a copy of CatalogPageResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogPageResponseDtoCopyWith<_CatalogPageResponseDto> get copyWith => __$CatalogPageResponseDtoCopyWithImpl<_CatalogPageResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CatalogPageResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogPageResponseDto&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor);

@override
String toString() {
  return 'CatalogPageResponseDto(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$CatalogPageResponseDtoCopyWith<$Res> implements $CatalogPageResponseDtoCopyWith<$Res> {
  factory _$CatalogPageResponseDtoCopyWith(_CatalogPageResponseDto value, $Res Function(_CatalogPageResponseDto) _then) = __$CatalogPageResponseDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _itemsFromJson, toJson: _itemsToJson) List<CatalogItemDto> items, String? nextCursor
});




}
/// @nodoc
class __$CatalogPageResponseDtoCopyWithImpl<$Res>
    implements _$CatalogPageResponseDtoCopyWith<$Res> {
  __$CatalogPageResponseDtoCopyWithImpl(this._self, this._then);

  final _CatalogPageResponseDto _self;
  final $Res Function(_CatalogPageResponseDto) _then;

/// Create a copy of CatalogPageResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(_CatalogPageResponseDto(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CatalogItemDto>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

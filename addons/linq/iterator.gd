class_name Iterator extends RefCounted

static func from(value: Variant) -> Iterator:
	match typeof(value):
		TYPE_OBJECT:
			if value is Iterator: return value;
		TYPE_ARRAY,\
		TYPE_PACKED_BYTE_ARRAY,\
		TYPE_PACKED_COLOR_ARRAY,\
		TYPE_PACKED_FLOAT32_ARRAY,\
		TYPE_PACKED_FLOAT64_ARRAY,\
		TYPE_PACKED_FLOAT64_ARRAY,\
		TYPE_PACKED_INT32_ARRAY,\
		TYPE_PACKED_INT64_ARRAY,\
		TYPE_PACKED_STRING_ARRAY,\
		TYPE_PACKED_VECTOR2_ARRAY,\
		TYPE_PACKED_VECTOR3_ARRAY,\
		TYPE_PACKED_VECTOR4_ARRAY:
			return ArrayIterator.new(value);
		TYPE_DICTIONARY:
			return DictionaryIterator.new(value);
		var type:
			# TODO: Add support for more types which can be iterated.
			assert(false, "[Iterator.from()] does not support type [{type}]".format({ "type": type_string(type) }));
	return null;

#region Implements interfaces

func _iter_init(iter: Array) -> bool:
	return false;

func _iter_next(iter: Array) -> bool:
	return false;

func _iter_get(iter: Variant) -> Variant:
	return null;

#endregion Implements interfaces

#region Extension methods

## Counts elements for which [param predicate] returns [code]true[/code]. If no
## [param predicate] has been provided, all elements are counted.[br][br]
##
## [param predicate] has the following signature:
## [codeblock]
## func predicate(value: Variant) -> bool
## [/codeblock]
func count(predicate: Callable = Callable()) -> int:
	var count := 0;
	for element in self:
		if not predicate.is_valid() or predicate.call(element):
			count += 1;
			
	return count;

func select(selector: Callable) -> SelectIterator:
	return SelectIterator.new(self, selector);

func select_many(collection_selector: Callable, result_selector: Callable = Callable()) -> SelectManyIterator:
	return SelectManyIterator.new(self, collection_selector, result_selector);

func where(predicate: Callable) -> WhereIterator:
	return WhereIterator.new(self, predicate);

func zip(other: Variant) -> ZipIterator:
	return ZipIterator.new(self, Iterator.from(other));

#endregion Extension methods

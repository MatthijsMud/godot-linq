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
			assert(false, "[Iterator.from()] does not support type [{type}]".format({ "type": type_string(type) }));
	return empty();

## Returns an [Iterator] that does [b]not[/b] yield any elements.
##
## Use in place of [code]null[/code]
static func empty() -> Iterator:
	return Iterator.new();

## Returns an [Iterator] that yields the provided [param element] a number
## of times equal to [param count].
##
## [codeblock]
## Iterator.repeat("Hello", 5).to_array();
## ["Hello", "Hello", "Hello", "Hello", "Hello"]
## [/codeblock]
static func repeat(element: Variant, count: int) -> RepeatIterator:
	return RepeatIterator.new(element, count);

#region Implements interfaces

func _iter_init(iter: Array) -> bool:
	return false;

func _iter_next(iter: Array) -> bool:
	return false;

func _iter_get(iter: Variant) -> Variant:
	return null;

#endregion Implements interfaces

#region Extension methods

## Returns [code]true[/code] if [param predicate] returns [code]true[/code] for each element in the sequence.
##
## Stops as soon as any invocation returns [code]false[/code].[br][br]
##
## [param predicate] has the following signature.
## [codeblock]
## func predicate(value: Variant) -> bool
## [/codeblock]
func all(predicate: Callable) -> bool:
	for value in self:
		if not predicate.call(value):
			return false;
	return true;

## Returns [code]true[/code] if [param predicate] returns [code]true[/code] for 
## at least one element in the sequence. It stops as soon as the result can
## be determined.[br][br]
##
## [param predicate] has the following signature:
## [codeblock]
## func predicate(value: Variant) -> bool
## [/codeblock]
##
## If [param predicate] is not provided, it assumes all elements would return
## [code]true[/code]. In other words: the sequence contains 1 or more elements.
func any(predicate: Callable = Callable()) -> bool:
	for element in self:
		if not predicate.is_valid() or predicate.call(element):
			return true;
		
	return false;

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

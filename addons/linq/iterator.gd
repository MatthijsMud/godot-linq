## Represents the concept of a sequence which can be transformed and iterated lazily.
class_name Iterator extends RefCounted

## Used as default value in methods with overloads where one argument could be
## anything. It is treated as not providing a value.
static func UNDEFINED() -> void: 
	push_error("[Iterator.UNDEFINED()] should not be invoked.");

## Wraps the provided iterable object in a suitable [Iterator] to allow for easy 
## chaining of various operations on sequences.[br][br]
##
## If the provided value is already an Iterator, the provided value is returned instead (to avoid excessive wrapping).
static func from(value: Variant) -> Iterator:
	match typeof(value):
		TYPE_OBJECT:
			if value is Iterator: return value;
			if CustomIterator.has_interface(value):
				return CustomIterator.new(value);
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
func count(predicate: Callable = UNDEFINED) -> int:
	var count := 0;
	for element in self:
		if is_same(predicate, UNDEFINED) or predicate.call(element):
			count += 1;
			
	return count;

## Returns the default value for the supposed type.
func default_if_empty() -> Iterator:
	if not _iter_init([null]):
		return ArrayIterator.new([_default()]);
	return self;

func first() -> Variant:
	return FirstIterator.first(self);
	
func first_or_default(default: Variant = UNDEFINED) -> Variant:
	return FirstIterator.first_or_default(self, default);

## Creates a new [Iterator] where each value is the result of calling [param selector]
## with the corresponding element in the source (and optionally its index).[br][br]
##
## [param selector] has any of the following signatures, where[param index] is 
## the index in its source (starting at [code]0[/code]).
## [codeblock]
## func selector(value: Variant) -> Variant
## func selector(value: Variant, index: int) -> Variant
## [/codeblock]
func select(selector: Callable) -> SelectIterator:
	return SelectIterator.new(self, selector);

## Creates a new [Iterator] that iterates over the results of calling 
## [param collection_selector] up to once for each element in its source.[br][br]
##
## [param collection_selector] has the following signature:
## [codeblock]
## func collection_selector(element: Variant) -> Iterator
## func collection_selector(element: Variant, index: int) -> Iterator
## [/codeblock]
## Callback which is used to turn each element in the source into an 
## [Iterator]-like object. It can optionally accept the index of the element 
## in its source.[br][br]
##
## [param result_selector] has the following signature:
## [codeblock]
## func result_selector(source: Variant, element: Variant) -> Variant
## [/codeblock]
## Callback which allows transforming the element. This is similar to chaining 
## [method select], but in this case the source is also provided, which allows for setting up references.
## The default implementation (if this callback is omited) returns [param element].
func select_many(collection_selector: Callable, result_selector: Callable = UNDEFINED) -> SelectManyIterator:
	return SelectManyIterator.new(self, collection_selector, result_selector);

## Constructs an [Array] containing all elements in this [Iterator].
func to_array() -> Array:
	var state := [null];
	var result := [];
	var has_next := _iter_init(state);
	while has_next:
		result.push_back(_iter_get(state[0]));
		has_next = _iter_next(state);
	return result;
 
## Creates a new [Iterator] that is a subset of its source. It only contains 
## elements for which [param predicate] returned [code]true[/code].[br][br]
##
## [param predicate] has the following signature:
## [codeblock]
## func predicate(value: Variant) -> bool
## func predicate(value: Variant, index: int) -> bool
## [/codeblock]
## Callback which's return value indicates whether each next element in the 
## source should be in the resulting Iterator ([code]true[/code]), or if it 
## should be skipped ([code]false[/code]).
func where(predicate: Callable) -> WhereIterator:
	return WhereIterator.new(self, predicate);

## Creates a new [Iterator] that combines each element from its source with the 
## corresponding element in the provided [param other] [Iterator] until either is exhausted.
func zip(other: Variant) -> ZipIterator:
	return ZipIterator.new(self, Iterator.from(other));

#endregion Extension methods

## Virtual method for generating a default value based on the type of data this 
## iterator yields.
##
## Used internally by methods like [method default_if_empty], [method first_or_default], 
## [method single_or_default].
func _default() -> Variant:
	return null;

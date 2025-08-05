## Represents the concept of a sequence which can be transformed and iterated lazily.
class_name Iterator extends RefCounted

## Used as default value in methods with overloads where one argument could be
## anything. It is treated as not providing a value.
static func UNDEFINED() -> void:
	push_error("[Iterator.UNDEFINED()] should not be invoked!");

## Wraps the provided iterable object in a suitable [Iterator] to allow for easy 
## chaining of various operations on sequences.[br][br]
##
## If the provided value is already an Iterator, the provided value is returned instead (to avoid excessive wrapping).
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
func any(predicate: Callable = UNDEFINED) -> bool:
	for element in self:
		if is_same(predicate, UNDEFINED) or predicate.call(element):
			return true;
		
	return false;
	
## Returns [code]true[/code] if the provided [param value] is present in this [Iterator].
func contains(value: Variant, comparer: Callable = UNDEFINED) -> bool:
	comparer = comparer if not is_same(comparer, UNDEFINED) else is_same;
	for element in self:
		if comparer.call(element, value):
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

## Returns the first element for which [param predicate] returns [code]true[/code].[br][br]
##
## [param predicate] has the following signature.
## [codeblock]
## func predicate(element: Variant) -> bool
## [/codeblock]
func first(predicate: Callable = UNDEFINED) -> Variant:
	if is_same(predicate, UNDEFINED):
		predicate = func(_e): return true;
		
	for element in self:
		if predicate.call(element):
			return element;
	
	push_error("[Iterator] cannot access [first()] because it is empty.");
	return null;

## Returns the first element for which [param predicate] returns [code]true[/code], 
## or [param default] if no element satisfies the constraints.[br][br]
##
## [param predicate] has the following signature.
## [codeblock]
## func predicate(element: Variant) -> bool
## [/codeblock]
func first_or_default(predicate_or_default: Variant = UNDEFINED, default: Variant = UNDEFINED) -> Variant:
	var predicate: Callable = UNDEFINED;
	# Determine which overload is invoked.
	match [typeof(predicate_or_default), not is_same(default, UNDEFINED)]:
		# Represents `func first_or_default(predicate)`
		[TYPE_CALLABLE, false]: 
			predicate = predicate_or_default;
			default = _default();
			print_verbose("[Iterator] assumes provided callback is [param predicate]");
		# Represents `func first_or_default(predicate, default)`
		[TYPE_CALLABLE, true]:
			predicate = predicate_or_default;
			# [default] already has the correct value.
		# Represents `func first_or_default(default)`
		[_, false]: 
			default = predicate_or_default;
		_: 
			push_error("[Iterator] requires first parameter to be a [Callable] if a default value is provided.");
			return default;
	
	if is_same(predicate, UNDEFINED):
		predicate = func(_e): return true;
	
	for element in self:
		if predicate.call(element):
			return element;
	
	return default;
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

## Creates a new [Iterator] that contains elements from its source except a 
## number of elements from the start equal to [param number_to_skip]. 
## The resulting sequence will be empty if [param number_to_skip] is equal to, 
## or greater than, the number of elements in the source.[br][br]
##
## [param number_to_skip] indicates how many elements at the start of the source
## should be ignored.
func skip(number_to_skip: int) -> Iterator:
	return SkipIterator.new(self, number_to_skip);

## Calculates the sum of the elements in this sequence.[br][br]
##
## Note that this method returns [code]null[/code] if the sequence is empty.
func sum(selector: Callable = UNDEFINED) -> Variant:
	
	var iter := [null];
	if not _iter_init(iter):
		return null;
		
	if is_same(selector, UNDEFINED):
		selector = func(e): return e;
	
	var add: Callable = func(left: Variant, right: Variant) -> Variant:
		match [typeof(left), typeof(right)]:
			[TYPE_FLOAT, TYPE_FLOAT],\
			[TYPE_FLOAT, TYPE_INT],\
			[TYPE_INT, TYPE_FLOAT],\
			[TYPE_INT, TYPE_INT]:
				return left + right;
			[TYPE_FLOAT, TYPE_NIL],\
			[TYPE_INT, TYPE_NIL]:
				return left;
			[TYPE_NIL, TYPE_FLOAT],\
			[TYPE_NIL, TYPE_INT]:
				return right;
			[TYPE_NIL, TYPE_NIL]:
				return null;
		return UNDEFINED;
	
	# Sum supports adding either [int] or [float] values.
	var total: Variant = selector.call(_iter_get(iter[0]));
	var left: Variant = null;
	var right: Variant = null;
	while(_iter_next(iter)):
		left = total;
		right = selector.call(_iter_get(iter[0]));
		total = add.call(left, right);
		if is_same(total, UNDEFINED):
			push_error("[Iterator] cannot sum elements of type [{left}] and [{right}]".format({
				"left": type_string(typeof(left)),
				"right": type_string(typeof(right))
			}))
			return null;

	return total;

## Creates a new [Iterator] that contains a number of elements from the start of
## its source, but no more than [param number_to_take]. If the source contains 
## fewer elements, the sequence is equivalent.[br][br]
## 
## [param number_to_take] Maximum number of elements from the start of the 
## source to include in this [Iterator].
func take(number_to_take) -> TakeIterator:
	return TakeIterator.new(self, number_to_take);

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

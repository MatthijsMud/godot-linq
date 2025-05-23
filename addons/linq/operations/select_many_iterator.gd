class_name SelectManyIterator extends ChainedIterator

var _collection_selector: Callable;
var _result_selector: Callable;

func _init(source: Iterator, collection_selector: Callable, result_selector: Callable = UNDEFINED) -> void:
	super(source);
	_collection_selector = _resolve_collection_selector_overload(collection_selector);
	_result_selector = _resolve_result_selector_overload(result_selector);

func _resolve_collection_selector_overload(collection_selector: Callable) -> Callable:
	if not collection_selector.is_valid():
		push_error("[select_many_iterator] requires a valid [param collection_selector]");
		return collection_selector;
	
	match collection_selector.get_argument_count():
		# func collection_selector() -> Iterator
		0: return collection_selector.unbind(2);
		# func collection_selector(element: Variant) -> Iterator;
		1: return collection_selector.unbind(1);
		# func collection_selector(element: Variant, index: int) -> Iterator
		2: return collection_selector;
		_: 
			push_error("[SelectManyIterator] received [param collection_selector] expecting more parameters than would be provided.")
	return Callable();

func _resolve_result_selector_overload(result_selector: Callable) -> Callable:
	if is_same(result_selector, UNDEFINED):
		return _default_result_selector;
		
	if not result_selector.is_valid():
		push_error("[SelectManyIterator] requires either a valid [param result_selector] or its default value.");
		return result_selector;
		
	match result_selector.get_argument_count():
		# func result_selector() -> Variant
		0: return result_selector.unbind(2);
		# func result_selector(source: Variant) -> Variant
		# NOTE: The provided parameter is the source, NOT an element in its sub-collection.
		# For example: [[0,1], [2,3,4]] would be called like [0,1], [0,1], [2,3,4], [2,3,4], [2,3,4].
		# It is more likely [...].select_many(collection_selector).select(result_selector) was intended.
		1:
			push_warning("[select_many_iterator] provides source element as first parameter to [param result_selector]");
			return result_selector.unbind(1);
		# func result_selector(source: Variant, element: Variant) -> Variant
		2: return result_selector;
		_:
			push_error("[SelectManyIterator] received [param result_selector] expecting more parameters than would be provided.");
			
	return Callable();

func _iter_init(iter: Array) -> bool:
	var state := State.new();
	iter[0] = state;
	
	var source_has_elements := _source._iter_init(state.source_iterator_state);
	while source_has_elements:
		state.source_element = _source._iter_get(state.source_iterator_state[0]);
		state.sub_collection_iterator = Iterator.from(_collection_selector.call(state.source_element, state.source_index));
		var sub_source_has_elements := state.sub_collection_iterator._iter_init(state.sub_collection_iterator_state);
		if sub_source_has_elements:
			return true;
			
		source_has_elements = _source._iter_next(state.source_iterator_state);
		state.source_index += 1;
	
	print_verbose("[SelectManyIterator] has reached the end of its source.")
	return false;

func _iter_next(iter: Array) -> bool:
	var state := iter[0] as State;
	var sub_source_has_elements := state.sub_collection_iterator._iter_next(state.sub_collection_iterator_state);
		
	while not sub_source_has_elements:
		var source_has_elements = _source._iter_next(state.source_iterator_state);
		if not source_has_elements:
			break;
		state.source_index += 1;
		state.source_element = _source._iter_get(state.source_iterator_state[0]);
		state.sub_collection_iterator = Iterator.from(_collection_selector.call(state.source_element, state.source_index));
		sub_source_has_elements = state.sub_collection_iterator._iter_init(state.sub_collection_iterator_state);
		
	return sub_source_has_elements;

func _iter_get(iter: Variant) -> Variant:
	var state := iter as State;
	var current := state.sub_collection_iterator._iter_get(state.sub_collection_iterator_state[0]);
	return _result_selector.call(state.source_element, current);

func _default() -> Variant:
	push_warning("[SelectManyIterator] always returns [null] because [selector]s'return type cannot be determined.");
	return null;

static func _default_result_selector(source: Variant, element: Variant) -> Variant:
	return element;

class State extends RefCounted:
	var source_index := 0;
	var source_iterator_state := [null];
	var source_element: Variant = null;
	
	var sub_collection_iterator: Iterator = null;
	var sub_collection_iterator_state := [null];

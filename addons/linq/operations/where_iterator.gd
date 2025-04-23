class_name WhereIterator extends ChainedIterator

var _predicate: Callable

func _init(source: Iterator, predicate: Callable) -> void:
	super(source);
	_predicate = _resolve_predicate_overload(predicate);

func _resolve_predicate_overload(predicate: Callable) -> Callable:
	match predicate.get_argument_count():
		# func predicate() -> bool
		# NOTE: While this overload is supported, it is likely unintended.
		# The predicate would have to decide whether to keep or drop an element
		# without knowing anything about the element in question.
		0: 
			push_warning("[WhereIterator] received [param predicate] which doesn't expect parameters.");
			return predicate.unbind(2);
		# func predicate(element: Variant) -> bool
		1: return predicate.unbind(1);
		# func predicate(element: Variant, index: int) -> bool
		2: return predicate;
		var number_of_arguments:
			push_error("[WhereIterator] received [param predicate] expecting more parameters than would be provided.");
	
	return Callable();
	
func _iter_init(iter: Array) -> bool:
	var state := State.new();
	iter[0] = state;
	var source_has_elements := _source._iter_init(state.source_iterator_state);
	while source_has_elements:
		state.current = _source._iter_get(state.source_iterator_state[0]);
		if _predicate.call(state.current, state.index):
			return true
		source_has_elements = _source._iter_next(state.source_iterator_state);
		state.index += 1;
	print_verbose("[WhereIterator] no elements matched predicate.");
	iter[0] = null;
	return false;

func _iter_next(iter: Array) -> bool:
	var state := iter[0] as State;
	if not state:
		push_error("[WhereIterator] received unexpected state in [method _iter_next]; it has likely finished.");
		return false;
		
	var source_has_elements := _source._iter_next(state.source_iterator_state);
	while source_has_elements:
		state.index += 1;
		state.current = _source._iter_get(state.source_iterator_state[0]);
		if _predicate.call(state.current, state.index):
			return true;
		source_has_elements = _source._iter_next(state.source_iterator_state);
		
	print_verbose("[WhereIterator] has reached the end of its source.");
	iter[0] = null;
	return false;

func _iter_get(iter: Variant) -> Variant:
	var state := iter as State;
	if not state:
		push_error("[WhereIterator] received unexpected state in [method _iter_get]; it has likely finished");
		return null;
	return state.current;

class State extends RefCounted:
	var source_iterator_state := [null];
	var current: Variant = null;
	var index: int = 0;

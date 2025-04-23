class_name SelectIterator extends ChainedIterator

var _selector: Callable;

func _init(source: Iterator, selector: Callable) -> void:
	super(source)
	_selector = _resolve_selector_overload(selector);

func _resolve_selector_overload(selector: Callable) -> Callable:
	match selector.get_argument_count():
		# func selector() -> Variant
		0: return selector.unbind(2);
		# func selector(element: Variant) -> Variant
		1: return selector.unbind(1);
		# func selector(element: Variant, index: int) -> Variant
		2: return selector;
		
		var expected_number_of_arguments: 
			push_error("[select_iterator] does not support provided [param selector] overload", expected_number_of_arguments)
			return Callable();

func _iter_init(iter: Array) -> bool:
	var state := State.new();
	iter[0] = state;
	return super(state.source_iterator_state);

func _iter_next(iter: Array) -> bool:
	var state := iter[0] as State;
	state.index += 1;
	return super(state.source_iterator_state);

func _iter_get(iter: Variant) -> Variant:
	var state := iter as State;
	var current := super(state.source_iterator_state[0]);
	return _selector.call(current, state.index);

class State extends RefCounted:
	var source_iterator_state := [null];
	var index := 0;

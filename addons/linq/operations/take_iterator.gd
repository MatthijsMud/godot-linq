class_name TakeIterator extends ChainedIterator

var _number_to_take: int = 0;

func _init(source: Iterator, number_to_take) -> void:
	super(source);
	if number_to_take < 0:
		push_error("[TakeIterator] cannot take a negative number of elements.");
		return;
	elif number_to_take == 0:
		push_warning("[TakeIterator] taking 0 elements is pointless.");
		return;
	
	_number_to_take = number_to_take;

func _iter_init(iter: Array) -> bool:
	var state := State.new();
	iter[0] = state;
	return _source._iter_init(state.source_iterator_state) and state.number_taken < _number_to_take;

func _iter_next(iter: Array) -> bool:
	var state := iter[0] as State;
	state.number_taken += 1;
	return _source._iter_next(state.source_iterator_state) and state.number_taken < _number_to_take;

func _iter_get(iter: Variant) -> Variant:
	var state := iter as State;
	return _source._iter_get(state.source_iterator_state[0]);

class State extends RefCounted:
	var source_iterator_state := [null];
	var number_taken := 0;

class_name ZipIterator extends ChainedIterator

var _other: Iterator;

func _init(source: Iterator, other: Iterator) -> void:
	super(source);
	_other = other;

func _iter_init(iter: Array) -> bool:
	var state := State.new();
	iter[0] = state;
	return _source._iter_init(state.source_state) and _other._iter_init(state.other_state);
	
func _iter_next(iter: Array) -> bool:
	var state := iter[0] as State;
	return _source._iter_next(state.source_state) and _other._iter_next(state.other_state);
	
func _iter_get(iter: Variant) -> Variant:
	var state := iter[0] as State;
	return [_source._iter_get(state.source_state), _other._iter_get(state.other_state)];

func _default() -> Variant:
	return [_source._default(), _other._default()];

class State extends RefCounted:
	var source_state := [null];
	var other_state := [null];

class_name DictionaryIterator extends Iterator

var _source: Dictionary;

func _init(source: Dictionary) -> void:
	_source = source;
	
func _iter_init(iter: Array) -> bool:
	var state := State.new();
	iter[0] = state;
	
	state.key_iterator = Iterator.from(_source.keys());
	return state.key_iterator._iter_init(state.key_iterator_state);
	
func _iter_next(iter: Array) -> bool:
	var state := iter[0] as State;
	return state.key_iterator._iter_next(state.key_iterator_state);
	
func _iter_get(iter: Variant) -> Variant:
	var state := iter as State;
	var key := state.key_iterator._iter_get(state.key_iterator_state[0]);
	return [key, _source.get(key)];

class State extends RefCounted:
	var key_iterator: Iterator;
	var key_iterator_state := [null];

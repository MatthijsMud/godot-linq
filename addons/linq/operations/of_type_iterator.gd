class_name OfTypeIterator extends ChainedIterator

static func _is_builtin_type(value: Variant, type: Variant.Type) -> bool:
	return typeof(value) == type;

static func _is_class(value: Variant, type: String) -> bool:
	if value is not Object: return false;
	var obj := value as Object;
	return obj.is_class(type)

static func _has_script(value: Object, type: Script) -> bool:
	var script := value.get_script() as Script;
	
	while script:
		if script == type: 
			return true;
		script = script.get_base_script();
		
	return false;

var _type: Variant;
var _predicate: Callable;

func _init(source: Iterator, type: Variant) -> void:
	super(source);
	_type = type;
	match typeof(type):
		TYPE_INT:
			_predicate = _is_builtin_type;
		TYPE_STRING, TYPE_STRING_NAME:
			_predicate = _is_class;
		TYPE_OBJECT:
			var script := type as Script;
			# NOTE: Builtin types, such as [Node], extend a type that is not exposed to GdScript.
			# Working with those types is therefore not practical.
			if not script: push_error("[OfTypeIterator] expects the provided type to be a [Script]");
			_predicate = _has_script;
		var t: push_error("[OfTypeIterator] does not support {type}".format({ "type": type_string(t) }));
	
		
func _iter_init(iter: Array) -> bool:
	var state := State.new();
	iter[0] = state;
	var source_has_elements := _source._iter_init(state.source_state);
	while source_has_elements:
		state.element = _source._iter_get(state.source_state[0]);
		if _predicate.call(state.element, _type): 
			return true;
		source_has_elements = _source._iter_next(state.source_state);
	
	print_verbose("[OfTypeIterator] no elements were of provided type.");
	iter[0] = null;
	return false;

func _iter_next(iter: Array) -> bool:
	var state := iter[0] as State;
	if not state:
		push_error("[OfTypeIterator] received unexpected state in [_iter_next]; it has likely finished.");
		return false;
	
	var source_has_elements := _source._iter_next(state.source_state);
	while source_has_elements:
		state.element = _source._iter_get(state.source_state[0]);
		if _predicate.call(state.element, _type): 
			return true;
		source_has_elements = _source._iter_next(state.source_state);
	
	print_verbose("[OfTypeIterator] has reached the end of its source.")
	iter[0] = null;
	return false;

func _iter_get(iter: Variant) -> Variant:
	var state := iter as State;
	if not state: 
		push_error("[OfTypeIterator] received unexpected state in [_iter_get]; it has likely finished.");
		return false;
		
	return state.element;

func _default() -> Variant:
	if typeof(_type) == TYPE_INT:
		return type_convert(null, _type as Variant.Type);
	
	return null;

class State extends RefCounted:
	var source_state := [null];
	var element: Variant = null;

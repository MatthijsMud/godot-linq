class_name RepeatIterator extends Iterator

var _element: Variant;
var _count: int;

func _init(element: Variant, count: int) -> void:
	_element = element;
	_count = count;
	if count < 0: push_error("[RepeatIterator] expects [count] to be positive.");

func _iter_init(iter: Array) -> bool:
	iter[0] = 0;
	return iter[0] < _count;

func _iter_next(iter: Array) -> bool:
	iter[0] += 1;
	return iter[0] < _count;

func _iter_get(iter: Variant) -> Variant:
	return _element;

func _default() -> Variant:
	return type_convert(null, typeof(_element));

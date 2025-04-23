class_name ArrayIterator extends Iterator

var _source: Array;

func _init(source: Array) -> void:
	_source = source;

func _iter_init(iter: Array) -> bool:
	iter[0] = 0;
	return iter[0] < len(_source);

func _iter_next(iter: Array) -> bool:
	iter[0] = iter[0] + 1;
	return iter[0] < len(_source);

func _iter_get(iter: Variant) -> Variant:
	return _source[iter];

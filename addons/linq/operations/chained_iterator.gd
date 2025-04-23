class_name ChainedIterator extends Iterator

var _source: Iterator;

func _init(source: Iterator) -> void:
	_source = source;

func _iter_init(iter: Array) -> bool:
	return _source._iter_init(iter);
	
func _iter_next(iter: Array) -> bool:
	return _source._iter_next(iter);

func _iter_get(iter: Variant) -> Variant:
	return _source._iter_get(iter);

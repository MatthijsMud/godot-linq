## "Abstract" [Iterator] that operates on the provided [param source].
## By default it forwards all calls to its source.
class_name ChainedIterator extends Iterator

var _source: Iterator;

func _init(source: Iterator) -> void:
	if not source: push_error("[ChainedIterator] expect source to not be [null].");
	_source = source;

func _iter_init(iter: Array) -> bool:
	return _source._iter_init(iter);
	
func _iter_next(iter: Array) -> bool:
	return _source._iter_next(iter);

func _iter_get(iter: Variant) -> Variant:
	return _source._iter_get(iter);

func _default() -> Variant:
	return _source._default();

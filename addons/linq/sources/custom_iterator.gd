## Wrapper around user defined iterators.
##
## A user defined iterator needs to have the following functions:
## [codeblock]
## func _iter_init(iter: Array) -> bool:
##   return false;
## 
## func _iter_next(iter: Array) -> bool:
##   return false;
##
## func _iter_get() -> Variant:
##   return null;
## [/codeblock]
## Consider using [method Iterator.from]
class_name CustomIterator extends Iterator

static func has_interface(value: Object) -> bool:
	return (Callable.create(value, &"_iter_init").is_valid()
		and Callable.create(value, &"_iter_next").is_valid()
		and Callable.create(value, &"_iter_get").is_valid()
	);

var _source: Object;

func _init(source: Object) -> void:
	_source = source;
	if not has_interface(source):
		push_error("[CustomIterator] received iterator with incorrect signature.")

func _iter_init(iter: Array) -> bool:
	return _source[&"_iter_init"].call(iter);

func _iter_next(iter: Array) -> bool:
	return _source[&"_iter_next"].call(iter);

func _iter_get(iter: Variant) -> Variant:
	return _source[&"_iter_get"].call(iter);

func _default() -> Variant:
	push_warning("[CustomIterator] does not know what type its source will yield.");
	return null;

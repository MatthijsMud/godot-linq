class_name SkipIterator extends ChainedIterator

var _number_to_skip: int = 0;

func _init(source: Iterator, number_to_skip: int) -> void:
	super(source);
	if number_to_skip < 0:
		push_error("[SkipIterator] cannot skip a negative number of elements");
		return;
		
	_number_to_skip = number_to_skip;
	
func _iter_init(iter: Array) -> bool:
	var number_skipped = 0;
	var source_has_elements := _source._iter_init(iter);
	while number_skipped < _number_to_skip and source_has_elements:
		source_has_elements = _source._iter_next(iter);
		number_skipped += 1;
	return source_has_elements;

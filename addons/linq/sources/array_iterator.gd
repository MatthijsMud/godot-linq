class_name ArrayIterator extends Iterator

var _source: Variant;

func _init(source: Variant) -> void:
	_source = source;

func _iter_init(iter: Array) -> bool:
	iter[0] = 0;
	return iter[0] < len(_source);

func _iter_next(iter: Array) -> bool:
	iter[0] = iter[0] + 1;
	return iter[0] < len(_source);

func _iter_get(iter: Variant) -> Variant:
	return _source[iter];

func _default() -> Variant:
	match typeof(_source):
		TYPE_ARRAY:
			return type_convert(null, (_source as Array).get_typed_builtin());
		TYPE_PACKED_BYTE_ARRAY: return type_convert(null, TYPE_INT); # GdScript does not have a [byte] type.
		TYPE_PACKED_COLOR_ARRAY: return type_convert(null, TYPE_COLOR);
		TYPE_PACKED_FLOAT32_ARRAY: return type_convert(null, TYPE_FLOAT);
		TYPE_PACKED_FLOAT64_ARRAY: return type_convert(null, TYPE_FLOAT);
		TYPE_PACKED_INT32_ARRAY: return type_convert(null, TYPE_INT);
		TYPE_PACKED_INT64_ARRAY: return type_convert(null, TYPE_INT);
		TYPE_PACKED_VECTOR2_ARRAY: return type_convert(null, TYPE_VECTOR2);
		TYPE_PACKED_VECTOR3_ARRAY: return type_convert(null, TYPE_VECTOR3);
		TYPE_PACKED_VECTOR4_ARRAY: return type_convert(null, TYPE_VECTOR4);
		TYPE_PACKED_STRING_ARRAY: return type_convert(null, TYPE_STRING);
		
		var type: push_error("[ArrayIterator] could not determine intended default for {type}".format({ "type": type_string(type) }));
	return null;

class_name Iterator extends RefCounted

static func from(value: Variant) -> Iterator:
	match typeof(value):
		TYPE_OBJECT:
			if value is Iterator: return value;
		TYPE_ARRAY,\
		TYPE_PACKED_BYTE_ARRAY,\
		TYPE_PACKED_COLOR_ARRAY,\
		TYPE_PACKED_FLOAT32_ARRAY,\
		TYPE_PACKED_FLOAT64_ARRAY,\
		TYPE_PACKED_FLOAT64_ARRAY,\
		TYPE_PACKED_INT32_ARRAY,\
		TYPE_PACKED_INT64_ARRAY,\
		TYPE_PACKED_STRING_ARRAY,\
		TYPE_PACKED_VECTOR2_ARRAY,\
		TYPE_PACKED_VECTOR3_ARRAY,\
		TYPE_PACKED_VECTOR4_ARRAY:
			return ArrayIterator.new(value)
		var type:
			# TODO: Add support for more types which can be iterated.
			assert(false, "[Iterator.from()] does not support type [{type}]".format({ "type": type_string(type) }));
	return null;

#region Implements interfaces

func _iter_init(iter: Array) -> bool:
	return false;

func _iter_next(iter: Array) -> bool:
	return false;

func _iter_get(iter: Variant) -> Variant:
	return null;

#endregion Implements interfaces

#region Extension methods

func select(selector: Callable) -> SelectIterator:
	return SelectIterator.new(self, selector);

#endregion Extension methods

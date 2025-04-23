class_name Iterator extends RefCounted

static func from(value: Variant) -> Iterator:
	match typeof(value):
		TYPE_OBJECT:
			if value is Iterator: return value;
		var type:
			# TODO: Add support for more types which can be iterated.
			assert(false, "[Iterator.from()] does not support type [%]" % type_string(type));
	return null;

#region Implements interfaces

func _iter_init(iter: Array) -> bool:
	return false;

func _iter_next(iter: Array) -> bool:
	return false;

func _iter_get(iter: Variant) -> Variant:
	return null;

#endregion Implements interfaces

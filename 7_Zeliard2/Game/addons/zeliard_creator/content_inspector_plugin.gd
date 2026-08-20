@tool
class_name ZeliardContentInspectorPlugin
extends EditorInspectorPlugin

var _index: ZeliardCreatorCatalogIndex


func _init(index: ZeliardCreatorCatalogIndex) -> void:
	_index = index


func _can_handle(object: Object) -> bool:
	return object.has_method(&"reference_field_kinds")


func _parse_property(
	object: Object,
	type: Variant.Type,
	name: String,
	_hint_type: PropertyHint,
	_hint_string: String,
	_usage_flags: int,
	_wide: bool
) -> bool:
	var reference_kinds := object.call(&"reference_field_kinds") as Dictionary
	var property_name := StringName(name)
	if not reference_kinds.has(property_name):
		return false
	if type != TYPE_STRING_NAME and type != TYPE_PACKED_STRING_ARRAY:
		return false
	var picker := ZeliardContentReferenceProperty.new()
	picker.configure(_index.choices(reference_kinds[property_name]), type == TYPE_PACKED_STRING_ARRAY)
	add_property_editor(name, picker)
	return true

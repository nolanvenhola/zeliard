@tool
class_name ZeliardItemDefinition
extends ZeliardContent

const SUPPORTED_ITEM_TYPES := ["key", "consumable", "equipment", "quest"]

@export_enum("key", "consumable", "equipment", "quest") var item_type: String = "key"
@export_range(0, 9999) var value: int = 0
@export var granted_ability_id: StringName = &""
@export var icon_asset_id: StringName = &""


func content_kind() -> StringName:
	return ZeliardContentKinds.ITEM


func validation_errors() -> PackedStringArray:
	var errors := super()
	if not SUPPORTED_ITEM_TYPES.has(item_type):
		errors.append("unsupported item_type %s" % item_type)
	if value < 0:
		errors.append("value cannot be negative")
	if icon_asset_id.is_empty():
		errors.append("icon_asset_id is required")
	return errors


func content_references() -> Array[ZeliardContentReference]:
	var references: Array[ZeliardContentReference] = []
	_append_reference(references, &"granted_ability_id", granted_ability_id, ZeliardContentKinds.ABILITY)
	_append_reference(references, &"icon_asset_id", icon_asset_id, ZeliardContentKinds.ASSET)
	return references


func reference_field_kinds() -> Dictionary:
	return {
		&"granted_ability_id": ZeliardContentKinds.ABILITY,
		&"icon_asset_id": ZeliardContentKinds.ASSET,
	}

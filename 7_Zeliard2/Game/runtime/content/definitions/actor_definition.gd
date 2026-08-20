@tool
class_name ZeliardActorDefinition
extends ZeliardContent

@export_range(1, 999) var max_health: int = 1
@export var starting_item_ids := PackedStringArray()
@export var ability_ids := PackedStringArray()
@export var sprite_asset_id: StringName = &""


func content_kind() -> StringName:
	return ZeliardContentKinds.ACTOR


func validation_errors() -> PackedStringArray:
	var errors := super()
	if max_health <= 0:
		errors.append("max_health must be positive")
	if sprite_asset_id.is_empty():
		errors.append("sprite_asset_id is required")
	return errors


func content_references() -> Array[ZeliardContentReference]:
	var references: Array[ZeliardContentReference] = []
	for item_id: String in starting_item_ids:
		_append_reference(references, &"starting_item_ids", StringName(item_id), ZeliardContentKinds.ITEM)
	for ability_id: String in ability_ids:
		_append_reference(references, &"ability_ids", StringName(ability_id), ZeliardContentKinds.ABILITY)
	_append_reference(references, &"sprite_asset_id", sprite_asset_id, ZeliardContentKinds.ASSET)
	return references


func reference_field_kinds() -> Dictionary:
	return {
		&"starting_item_ids": ZeliardContentKinds.ITEM,
		&"ability_ids": ZeliardContentKinds.ABILITY,
		&"sprite_asset_id": ZeliardContentKinds.ASSET,
	}

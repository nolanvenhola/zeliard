class_name ZeliardEnemyDefinition
extends ZeliardContent

@export_range(1, 999) var max_health: int = 1
@export_range(0, 999) var contact_damage: int = 0
@export var ability_ids := PackedStringArray()
@export var sprite_asset_id: StringName = &""


func content_kind() -> StringName:
	return ZeliardContentKinds.ENEMY


func validation_errors() -> PackedStringArray:
	var errors := super()
	if max_health <= 0:
		errors.append("max_health must be positive")
	if contact_damage < 0:
		errors.append("contact_damage cannot be negative")
	if sprite_asset_id.is_empty():
		errors.append("sprite_asset_id is required")
	return errors


func content_references() -> Array[ZeliardContentReference]:
	var references: Array[ZeliardContentReference] = []
	for ability_id: String in ability_ids:
		_append_reference(references, &"ability_ids", StringName(ability_id), ZeliardContentKinds.ABILITY)
	_append_reference(references, &"sprite_asset_id", sprite_asset_id, ZeliardContentKinds.ASSET)
	return references

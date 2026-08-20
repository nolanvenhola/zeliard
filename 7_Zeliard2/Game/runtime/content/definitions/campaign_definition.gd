@tool
class_name ZeliardCampaignDefinition
extends ZeliardContent

@export var region_ids := PackedStringArray()
@export var starting_region_id: StringName = &""
@export var player_actor_id: StringName = &""


func content_kind() -> StringName:
	return ZeliardContentKinds.CAMPAIGN


func validation_errors() -> PackedStringArray:
	var errors := super()
	if region_ids.is_empty():
		errors.append("campaign requires at least one region")
	if starting_region_id.is_empty() or not region_ids.has(String(starting_region_id)):
		errors.append("starting_region_id must appear in region_ids")
	if player_actor_id.is_empty():
		errors.append("player_actor_id is required")
	return errors


func content_references() -> Array[ZeliardContentReference]:
	var references: Array[ZeliardContentReference] = []
	for region_id: String in region_ids:
		_append_reference(references, &"region_ids", StringName(region_id), ZeliardContentKinds.REGION)
	_append_reference(references, &"starting_region_id", starting_region_id, ZeliardContentKinds.REGION)
	_append_reference(references, &"player_actor_id", player_actor_id, ZeliardContentKinds.ACTOR)
	return references


func reference_field_kinds() -> Dictionary:
	return {
		&"region_ids": ZeliardContentKinds.REGION,
		&"starting_region_id": ZeliardContentKinds.REGION,
		&"player_actor_id": ZeliardContentKinds.ACTOR,
	}

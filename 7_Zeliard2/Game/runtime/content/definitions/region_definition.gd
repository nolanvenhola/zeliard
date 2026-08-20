class_name ZeliardRegionDefinition
extends ZeliardContent

@export var room_ids := PackedStringArray()
@export var entry_room_id: StringName = &""
@export var music_asset_id: StringName = &""


func content_kind() -> StringName:
	return ZeliardContentKinds.REGION


func validation_errors() -> PackedStringArray:
	var errors := super()
	if room_ids.is_empty():
		errors.append("region requires at least one room")
	if entry_room_id.is_empty() or not room_ids.has(String(entry_room_id)):
		errors.append("entry_room_id must appear in room_ids")
	return errors


func content_references() -> Array[ZeliardContentReference]:
	var references: Array[ZeliardContentReference] = []
	for room_id: String in room_ids:
		_append_reference(references, &"room_ids", StringName(room_id), ZeliardContentKinds.ROOM)
	_append_reference(references, &"entry_room_id", entry_room_id, ZeliardContentKinds.ROOM)
	_append_reference(references, &"music_asset_id", music_asset_id, ZeliardContentKinds.ASSET)
	return references

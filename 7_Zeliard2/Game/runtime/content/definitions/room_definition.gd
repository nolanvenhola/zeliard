class_name ZeliardRoomDefinition
extends ZeliardContent

@export var region_id: StringName = &""
@export var size_cells: Vector2i = Vector2i(40, 25)
@export var entry_ids := PackedStringArray()
@export var exits: Array[ZeliardRoomExit] = []
@export var actor_placements: Array[ZeliardContentPlacement] = []
@export var enemy_placements: Array[ZeliardContentPlacement] = []
@export var event_ids := PackedStringArray()


func content_kind() -> StringName:
	return ZeliardContentKinds.ROOM


func validation_errors() -> PackedStringArray:
	var errors := super()
	if region_id.is_empty():
		errors.append("region_id is required")
	if size_cells.x <= 0 or size_cells.y <= 0:
		errors.append("size_cells must be positive")
	for exit: ZeliardRoomExit in exits:
		if exit == null or exit.exit_id.is_empty() or exit.destination_room_id.is_empty():
			errors.append("every exit requires exit_id and destination_room_id")
	for placement: ZeliardContentPlacement in actor_placements + enemy_placements:
		if placement == null or placement.definition_id.is_empty():
			errors.append("every placement requires definition_id")
	return errors


func content_references() -> Array[ZeliardContentReference]:
	var references: Array[ZeliardContentReference] = []
	_append_reference(references, &"region_id", region_id, ZeliardContentKinds.REGION)
	for exit: ZeliardRoomExit in exits:
		if exit != null:
			_append_reference(references, &"exits", exit.destination_room_id, ZeliardContentKinds.ROOM)
	for placement: ZeliardContentPlacement in actor_placements:
		if placement != null:
			_append_reference(references, &"actor_placements", placement.definition_id, ZeliardContentKinds.ACTOR)
	for placement: ZeliardContentPlacement in enemy_placements:
		if placement != null:
			_append_reference(references, &"enemy_placements", placement.definition_id, ZeliardContentKinds.ENEMY)
	for event_id: String in event_ids:
		_append_reference(references, &"event_ids", StringName(event_id), ZeliardContentKinds.EVENT)
	return references

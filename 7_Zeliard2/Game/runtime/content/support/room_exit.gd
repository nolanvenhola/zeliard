@tool
class_name ZeliardRoomExit
extends Resource

@export var exit_id: StringName = &""
@export var destination_room_id: StringName = &""
@export var destination_entry_id: StringName = &""
@export var trigger_cell: Vector2i = Vector2i.ZERO


func reference_field_kinds() -> Dictionary:
	return {&"destination_room_id": ZeliardContentKinds.ROOM}

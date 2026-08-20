@tool
class_name ZeliardRoomDefinition
extends Resource

@export var content_id: StringName = &"spike.training_room"
@export var display_name: String = "Training Cavern"
@export_range(8, 32, 8) var tile_size: int = 8
@export var logical_size: Vector2i = Vector2i(320, 200)
@export var spawn_cell: Vector2i = Vector2i(7, 20)
@export_range(4, 24, 1) var ground_row: int = 20
@export var enemy_cells: Array[Vector2i] = [Vector2i(18, 20), Vector2i(28, 20)]


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if content_id.is_empty():
		errors.append("content_id is required")
	if display_name.strip_edges().is_empty():
		errors.append("display_name is required")
	if tile_size <= 0 or logical_size.x % tile_size != 0 or logical_size.y % tile_size != 0:
		errors.append("logical_size must be divisible by tile_size")
	var grid_size := Vector2i(logical_size.x / tile_size, logical_size.y / tile_size)
	if spawn_cell.x < 0 or spawn_cell.x >= grid_size.x:
		errors.append("spawn_cell.x is outside the room")
	if spawn_cell.y != ground_row:
		errors.append("spawn_cell.y must equal ground_row in this spike")
	for enemy_cell: Vector2i in enemy_cells:
		if enemy_cell.x < 0 or enemy_cell.x >= grid_size.x or enemy_cell.y != ground_row:
			errors.append("enemy cell %s is outside the walkable row" % enemy_cell)
	return errors

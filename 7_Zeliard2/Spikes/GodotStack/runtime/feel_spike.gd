extends Node2D

const DEFAULT_ROOM: ZeliardRoomDefinition = preload("res://content/training_room.tres")
const PLAY_FROM_ROOM_FILE: String = "res://.godot/zeliard_play_from_room.txt"

var room: ZeliardRoomDefinition
var model := ZeliardFeelModel.new()
var logical_clock := ZeliardLogicalClock.new()
var enemies: Array[Vector2i] = []
var status_label: Label
var instructions_label: Label


func _ready() -> void:
	room = _load_selected_room()
	var errors := room.validation_errors()
	if not errors.is_empty():
		push_error("Room validation failed: %s" % ", ".join(errors))
	model.configure(room.spawn_cell, room.ground_row, room.logical_size.x / room.tile_size)
	enemies.assign(room.enemy_cells)
	_build_overlay()
	queue_redraw()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_feruza"):
		model.set_feruza_equipped(not model.feruza_equipped)
	var logical_steps := logical_clock.consume_steps(delta)
	for _step_index: int in range(logical_steps):
		var events := model.step(_direction_mask(), Input.is_action_pressed("primary_action"))
		_apply_attack(events)
	_update_overlay()
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(room.logical_size)), Color("101522"))
	_draw_grid()
	_draw_ground()
	for enemy_cell: Vector2i in enemies:
		_draw_actor(enemy_cell, Color("d45b47"), Vector2i(16, 16))
	_draw_actor(model.cell, Color("e8d7a1"), Vector2i(16, 24), model.facing)
	if model.is_attacking():
		for sword_cell: Vector2i in model.sword_cells():
			var sword_rect := Rect2(Vector2(sword_cell * room.tile_size), Vector2(room.tile_size, room.tile_size))
			draw_rect(sword_rect, Color("f3f0d0"))


func _draw_grid() -> void:
	var grid_color := Color("172033")
	for x: int in range(0, room.logical_size.x + 1, room.tile_size):
		draw_line(Vector2(x, 0), Vector2(x, room.logical_size.y), grid_color)
	for y: int in range(0, room.logical_size.y + 1, room.tile_size):
		draw_line(Vector2(0, y), Vector2(room.logical_size.x, y), grid_color)


func _draw_ground() -> void:
	var top := float((room.ground_row + 1) * room.tile_size)
	draw_rect(Rect2(0.0, top, room.logical_size.x, room.logical_size.y - top), Color("334434"))
	for x: int in range(0, room.logical_size.x, room.tile_size * 2):
		draw_rect(Rect2(x, top, room.tile_size, room.tile_size), Color("4c6242"))


func _draw_actor(actor_cell: Vector2i, color: Color, size: Vector2i, facing_direction: int = 0) -> void:
	var bottom_left := Vector2(actor_cell * room.tile_size)
	var top_left := bottom_left - Vector2(0, size.y - room.tile_size)
	draw_rect(Rect2(top_left, Vector2(size)), color)
	if facing_direction != 0:
		var face_x := top_left.x + size.x if facing_direction > 0 else top_left.x - 2.0
		draw_rect(Rect2(face_x, top_left.y + 5.0, 2.0, 6.0), color.lightened(0.18))


func _direction_mask() -> int:
	var mask: int = 0
	if Input.is_action_pressed("move_up"):
		mask |= ZeliardFeelModel.DIR_UP
	if Input.is_action_pressed("move_left"):
		mask |= ZeliardFeelModel.DIR_LEFT
	if Input.is_action_pressed("move_right"):
		mask |= ZeliardFeelModel.DIR_RIGHT
	return mask


func _apply_attack(events: Array[StringName]) -> void:
	if not events.has(&"attack_active"):
		return
	for sword_cell: Vector2i in model.sword_cells():
		var hit_index := enemies.find(sword_cell)
		if hit_index >= 0:
			enemies.remove_at(hit_index)
			break


func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	instructions_label = Label.new()
	instructions_label.position = Vector2(6, 4)
	instructions_label.text = "Move: Left/Right  Jump: Up+direction  Sword: Space  Feruza: F"
	instructions_label.add_theme_font_size_override("font_size", 8)
	layer.add_child(instructions_label)
	status_label = Label.new()
	status_label.position = Vector2(6, 184)
	status_label.add_theme_font_size_override("font_size", 8)
	layer.add_child(status_label)
	_update_overlay()


func _update_overlay() -> void:
	status_label.text = "%s  cell=%s  enemies=%d  jump=%s" % [
		room.display_name,
		model.cell,
		enemies.size(),
		"Feruza" if model.feruza_equipped else "normal",
	]


func _load_selected_room() -> ZeliardRoomDefinition:
	var selected_path: String = ""
	if FileAccess.file_exists(PLAY_FROM_ROOM_FILE):
		var selection_file := FileAccess.open(PLAY_FROM_ROOM_FILE, FileAccess.READ)
		if selection_file != null:
			selected_path = selection_file.get_as_text().strip_edges()
			selection_file.close()
	if not selected_path.is_empty() and ResourceLoader.exists(selected_path):
		var selected := ResourceLoader.load(selected_path) as ZeliardRoomDefinition
		if selected != null:
			return selected
	return DEFAULT_ROOM

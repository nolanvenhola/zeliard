class_name ZeliardFeelModel
extends RefCounted

const DIR_UP: int = 0x01
const DIR_LEFT: int = 0x04
const DIR_RIGHT: int = 0x08

const NORMAL_JUMP_PROFILE: Array[int] = [-1, -1, 1, 1]
const FERUZA_JUMP_PROFILE: Array[int] = [-1, -1, -1, -1, 1, 1, 1, 1]

var cell: Vector2i = Vector2i.ZERO
var ground_row: int = 0
var room_width_cells: int = 40
var facing: int = 1
var feruza_equipped: bool = false
var jump_tick: int = -1
var jump_direction: int = 0
var attack_tick: int = -1


func configure(spawn_cell: Vector2i, floor_row: int, width_cells: int) -> void:
	cell = spawn_cell
	ground_row = floor_row
	room_width_cells = width_cells
	facing = 1
	jump_tick = -1
	jump_direction = 0
	attack_tick = -1


func is_grounded() -> bool:
	return jump_tick < 0 and cell.y == ground_row


func is_attacking() -> bool:
	return attack_tick >= 0


func set_feruza_equipped(value: bool) -> void:
	feruza_equipped = value


func step(direction_mask: int, action_held: bool) -> Array[StringName]:
	var events: Array[StringName] = []

	if action_held and attack_tick < 0:
		attack_tick = 0
		events.append(&"attack_started")

	if is_grounded():
		if direction_mask & DIR_UP:
			_start_jump(direction_mask)
			events.append(&"jump_started")
		else:
			_apply_grounded_horizontal(direction_mask)
	else:
		_advance_jump()

	_advance_attack(events)
	return events


func sword_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if attack_tick != 2:
		return cells
	var forward := 2 if facing > 0 else -1
	cells.append(cell + Vector2i(forward, -1))
	cells.append(cell + Vector2i(forward, 0))
	return cells


func _start_jump(direction_mask: int) -> void:
	jump_tick = 0
	jump_direction = 0
	if direction_mask & DIR_LEFT:
		jump_direction = -1
		facing = -1
	elif direction_mask & DIR_RIGHT:
		jump_direction = 1
		facing = 1
	_apply_jump_tick()


func _advance_jump() -> void:
	jump_tick += 1
	var profile: Array[int] = _jump_profile()
	if jump_tick >= profile.size():
		jump_tick = -1
		jump_direction = 0
		cell.y = ground_row
		return
	_apply_jump_tick()
	if jump_tick == profile.size() - 1:
		jump_tick = -1
		jump_direction = 0
		cell.y = ground_row


func _apply_jump_tick() -> void:
	var profile: Array[int] = _jump_profile()
	cell.y += profile[jump_tick]
	if jump_direction != 0:
		cell.x = clampi(cell.x + jump_direction, 1, room_width_cells - 3)


func _jump_profile() -> Array[int]:
	return FERUZA_JUMP_PROFILE if feruza_equipped else NORMAL_JUMP_PROFILE


func _apply_grounded_horizontal(direction_mask: int) -> void:
	if direction_mask & DIR_LEFT:
		facing = -1
		cell.x = clampi(cell.x - 1, 1, room_width_cells - 3)
	elif direction_mask & DIR_RIGHT:
		facing = 1
		cell.x = clampi(cell.x + 1, 1, room_width_cells - 3)


func _advance_attack(events: Array[StringName]) -> void:
	if attack_tick < 0:
		return
	attack_tick += 1
	if attack_tick == 2:
		events.append(&"attack_active")
	elif attack_tick >= 4:
		attack_tick = -1
		events.append(&"attack_recovered")

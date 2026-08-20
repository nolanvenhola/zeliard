extends SceneTree

const Model = preload("res://runtime/feel_model.gd")
const LogicalClock = preload("res://runtime/logical_clock.gd")
const RoomDefinition = preload("res://content/room_definition.gd")

var failures: int = 0


func _init() -> void:
	_test_room_resource()
	_test_fixed_step_clock()
	_test_grid_movement()
	_test_normal_jump()
	_test_directional_jump()
	_test_feruza_jump()
	_test_committed_sword_event()
	_test_spike_scripts_parse()
	if failures == 0:
		print("PASS: 8 Godot stack spike scenarios")
		quit(0)
	else:
		push_error("FAIL: %d assertion(s)" % failures)
		quit(1)


func _test_room_resource() -> void:
	var room := load("res://content/training_room.tres") as ZeliardRoomDefinition
	_expect(room != null, "typed room resource loads")
	_expect(room.validation_errors().is_empty(), "room resource validates")


func _test_fixed_step_clock() -> void:
	var clock := LogicalClock.new() as ZeliardLogicalClock
	var steps: int = 0
	for frame: int in range(5):
		steps += clock.consume_steps(1.0 / 60.0)
	_expect_equal(steps, 0, "five 60 Hz frames remain below one logical beat")
	steps += clock.consume_steps(1.0 / 60.0)
	_expect_equal(steps, 1, "sixth 60 Hz frame crosses one logical beat")


func _test_grid_movement() -> void:
	var model := _new_model()
	model.step(Model.DIR_RIGHT, false)
	_expect_equal(model.cell, Vector2i(8, 20), "right input advances one logical cell")
	model.step(Model.DIR_LEFT, false)
	_expect_equal(model.cell, Vector2i(7, 20), "left input advances one logical cell")


func _test_normal_jump() -> void:
	var model := _new_model()
	var minimum_y := model.cell.y
	for tick: int in range(4):
		model.step(Model.DIR_UP if tick == 0 else 0, false)
		minimum_y = mini(minimum_y, model.cell.y)
	_expect_equal(minimum_y, 18, "normal jump rises two cells")
	_expect_equal(model.cell, Vector2i(7, 20), "normal jump returns to its origin")
	_expect(model.is_grounded(), "normal jump finishes grounded")


func _test_directional_jump() -> void:
	var model := _new_model()
	for tick: int in range(4):
		model.step(Model.DIR_UP | Model.DIR_RIGHT if tick == 0 else 0, false)
	_expect_equal(model.cell, Vector2i(11, 20), "directional jump commits horizontal motion")


func _test_feruza_jump() -> void:
	var model := _new_model()
	model.set_feruza_equipped(true)
	var minimum_y := model.cell.y
	for tick: int in range(8):
		model.step(Model.DIR_UP if tick == 0 else 0, false)
		minimum_y = mini(minimum_y, model.cell.y)
	_expect_equal(minimum_y, 16, "Feruza jump rises four cells")
	_expect(model.is_grounded(), "Feruza jump finishes grounded")


func _test_committed_sword_event() -> void:
	var model := _new_model()
	var active_events: int = 0
	for tick: int in range(4):
		var events := model.step(0, tick == 0)
		if events.has(&"attack_active"):
			active_events += 1
			_expect_equal(model.sword_cells(), [Vector2i(9, 19), Vector2i(9, 20)], "active sword reach is authored")
	_expect_equal(active_events, 1, "one committed attack has one active event")
	_expect(not model.is_attacking(), "attack reaches recovery")


func _test_spike_scripts_parse() -> void:
	var plugin_script := load("res://addons/zeliard_creator/creator_plugin.gd")
	var inspector_script := load("res://addons/zeliard_creator/room_definition_inspector.gd")
	var scene := load("res://scenes/feel_spike.tscn") as PackedScene
	_expect(plugin_script != null and inspector_script != null, "Creator plugin scripts parse")
	var instance := scene.instantiate() if scene != null else null
	_expect(instance != null, "feel prototype scene instantiates")
	if instance != null:
		instance.free()


func _new_model() -> ZeliardFeelModel:
	var model := Model.new() as ZeliardFeelModel
	model.configure(Vector2i(7, 20), 20, 40)
	return model


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _expect_equal(actual: Variant, expected: Variant, message: String) -> void:
	_expect(actual == expected, "%s: expected %s, got %s" % [message, expected, actual])

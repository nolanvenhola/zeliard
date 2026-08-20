extends SceneTree

var _failures: int = 0


func _init() -> void:
	_test_content_contract()
	_test_content_batch_validation()
	_test_structured_logging()
	_test_main_scene_loads()
	if _failures == 0:
		print("PASS: 4 production scaffold scenarios")
		quit(0)
	else:
		push_error("FAIL: %d assertion(s)" % _failures)
		quit(1)


func _test_content_contract() -> void:
	var content := ZeliardContent.new()
	_expect_equal(ZeliardContentValidator.validate(content), PackedStringArray(["content_id is required"]), "empty content ID is rejected")
	content.content_id = &"Town:Gate"
	_expect_equal(ZeliardContentValidator.validate(content), PackedStringArray(["content_id must use lowercase namespace:name syntax"]), "noncanonical content ID is rejected")
	content.content_id = &"town:gate"
	_expect(ZeliardContentValidator.validate(content).is_empty(), "canonical content ID validates")


func _test_content_batch_validation() -> void:
	var valid := ZeliardContent.new()
	valid.content_id = &"town:gate"
	var invalid := ZeliardContent.new()
	invalid.content_id = &"bad"
	var resources: Array[ZeliardContent] = [valid, invalid]
	var result := ZeliardContentValidator.validate_all(resources)
	_expect_equal(result.size(), 1, "batch validation returns only invalid content")
	_expect(result.has(&"bad"), "batch validation keys errors by stable content ID")


func _test_structured_logging() -> void:
	var records: Array[Dictionary] = []
	ZeliardLog.set_test_sink(func(record: Dictionary) -> void: records.append(record))
	ZeliardLog.info(&"test_event", {"answer": 42})
	ZeliardLog.clear_test_sink()
	_expect_equal(records.size(), 1, "logger emits one record")
	if records.size() == 1:
		_expect_equal(records[0]["level"], "info", "logger records its level")
		_expect_equal(records[0]["event"], "test_event", "logger records a stable event name")
		_expect_equal(records[0]["fields"]["answer"], 42, "logger preserves structured fields")


func _test_main_scene_loads() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	_expect(scene != null, "main scene resource loads")
	if scene != null:
		var instance := scene.instantiate()
		_expect(instance != null, "main scene instantiates")
		instance.free()


func _expect(condition: bool, description: String) -> void:
	if not condition:
		_failures += 1
		printerr("FAIL: %s" % description)


func _expect_equal(actual: Variant, expected: Variant, description: String) -> void:
	_expect(actual == expected, "%s (expected %s, got %s)" % [description, expected, actual])

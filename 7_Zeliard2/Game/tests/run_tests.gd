extends SceneTree

var _failures: int = 0


func _init() -> void:
	_test_content_contract()
	_test_content_batch_validation()
	_test_example_catalog_and_schema_kinds()
	_test_example_graph_validation()
	_test_invalid_graph_references()
	_test_structured_validation_diagnostics()
	_test_resource_round_trip()
	_test_stable_id_survives_file_move()
	_test_deterministic_save_migration()
	_test_save_checksum_integrity()
	_test_atomic_save_rotation()
	_test_corrupt_save_recovery_is_non_destructive()
	_test_structured_logging()
	_test_main_scene_loads()
	if _failures == 0:
		print("PASS: 14 production validation and save scenarios")
		quit(0)
	else:
		push_error("FAIL: %d assertion(s)" % _failures)
		quit(1)


func _test_content_contract() -> void:
	var content := ZeliardContent.new()
	content.display_name = "Test Content"
	_expect_equal(ZeliardContentValidator.validate(content), PackedStringArray(["content_id is required"]), "empty content ID is rejected")
	content.content_id = &"Town:Gate"
	_expect_equal(ZeliardContentValidator.validate(content), PackedStringArray(["content_id must use lowercase namespace:name syntax"]), "noncanonical content ID is rejected")
	content.content_id = &"town:gate"
	_expect(ZeliardContentValidator.validate(content).is_empty(), "canonical content ID validates")


func _test_content_batch_validation() -> void:
	var valid := ZeliardContent.new()
	valid.content_id = &"town:gate"
	valid.display_name = "Gate"
	var invalid := ZeliardContent.new()
	invalid.content_id = &"bad"
	invalid.display_name = "Bad"
	var resources: Array[ZeliardContent] = [valid, invalid]
	var result := ZeliardContentValidator.validate_all(resources)
	_expect_equal(result.size(), 1, "batch validation returns only invalid content")
	_expect(result.has(&"bad"), "batch validation keys errors by stable content ID")


func _test_example_catalog_and_schema_kinds() -> void:
	var catalog := ZeliardContentCatalog.load_directory("res://content/example")
	_expect_equal(catalog.all().size(), 12, "example catalog loads every top-level definition")
	var kinds: Dictionary = {}
	for content: ZeliardContent in catalog.all():
		kinds[content.content_kind()] = true
	var expected_kinds := PackedStringArray([
		"campaign", "region", "room", "actor", "enemy", "item",
		"ability", "dialogue", "quest", "asset", "event",
	])
	for kind: String in expected_kinds:
		_expect(kinds.has(StringName(kind)), "example catalog contains %s schema" % kind)
	_expect(catalog.contains(&"campaign:example"), "catalog resolves stable campaign ID")
	_expect(catalog.get_by_id(&"room:verdant_gate") is ZeliardRoomDefinition, "catalog resolves room independent of path")


func _test_example_graph_validation() -> void:
	var catalog := ZeliardContentCatalog.load_directory("res://content/example")
	var invalid := ZeliardContentValidator.validate_graph(catalog.all())
	_expect(invalid.is_empty(), "representative content graph validates: %s" % invalid)


func _test_invalid_graph_references() -> void:
	var catalog := ZeliardContentCatalog.load_directory("res://content/example")
	var resources := catalog.all()
	var broken := ZeliardCampaignDefinition.new()
	broken.content_id = &"campaign:broken"
	broken.display_name = "Broken Campaign"
	broken.region_ids = PackedStringArray(["region:missing"])
	broken.starting_region_id = &"region:missing"
	broken.player_actor_id = &"item:bronze_key"
	resources.append(broken)
	var duplicate := ZeliardAssetDefinition.new()
	duplicate.content_id = &"asset:hero_placeholder"
	duplicate.display_name = "Duplicate Asset"
	duplicate.source_path = "res://content/example/assets/hero_placeholder.svg"
	resources.append(duplicate)
	var wrong_namespace := ZeliardActorDefinition.new()
	wrong_namespace.content_id = &"item:not_an_actor"
	wrong_namespace.display_name = "Wrong Namespace"
	wrong_namespace.sprite_asset_id = &"asset:hero_placeholder"
	resources.append(wrong_namespace)
	var invalid := ZeliardContentValidator.validate_graph(resources)
	_expect(_errors_contain(invalid, &"campaign:broken", "references missing region ID region:missing"), "missing stable reference is detected")
	_expect(_errors_contain(invalid, &"campaign:broken", "expects actor ID but item:bronze_key is item"), "wrong-kind stable reference is detected")
	_expect(_errors_contain(invalid, &"asset:hero_placeholder", "duplicate content_id"), "duplicate stable ID is detected")
	_expect(_errors_contain(invalid, &"item:not_an_actor", "namespace must match content kind actor"), "ID namespace must match definition kind")


func _test_structured_validation_diagnostics() -> void:
	var catalog := ZeliardContentCatalog.load_directory("res://content/example")
	var resources := catalog.all()
	var broken := load("res://tests/fixtures/content/broken_campaign.tres") as ZeliardCampaignDefinition
	resources.append(broken)
	var diagnostics := ZeliardContentValidator.diagnose_graph(resources)
	var lines := ZeliardContentValidation.format_lines(diagnostics)
	var expected := "ERROR [content.missing_reference] res://tests/fixtures/content/broken_campaign.tres (campaign:broken.region_ids): region_ids references missing region ID region:missing"
	_expect(lines.has(expected), "shared diagnostic links missing reference to owning resource and property")
	resources.reverse()
	var reversed_lines := ZeliardContentValidation.format_lines(ZeliardContentValidator.diagnose_graph(resources))
	_expect_equal(lines, reversed_lines, "editor and CI diagnostics are deterministic regardless of discovery order")


func _test_resource_round_trip() -> void:
	var catalog := ZeliardContentCatalog.load_directory("res://content/example")
	for content: ZeliardContent in catalog.all():
		var file_name := String(content.content_id).replace(":", "_") + ".tres"
		var path := "user://" + file_name
		var save_error := ResourceSaver.save(content, path)
		_expect_equal(save_error, OK, "%s saves as text Resource" % content.content_id)
		if save_error == OK:
			var loaded := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as ZeliardContent
			_expect(loaded != null, "%s reloads after save" % content.content_id)
			if loaded != null:
				_expect_equal(_resource_snapshot(loaded), _resource_snapshot(content), "%s round-trips without semantic loss" % content.content_id)
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _test_stable_id_survives_file_move() -> void:
	var source := load("res://content/example/campaigns/example_campaign.tres") as ZeliardCampaignDefinition
	var first_path := "user://campaign_before_move.tres"
	var moved_path := "user://campaign_after_move.tres"
	var save_error := ResourceSaver.save(source, first_path)
	_expect_equal(save_error, OK, "campaign fixture saves before move")
	if save_error == OK:
		var rename_error := DirAccess.rename_absolute(
			ProjectSettings.globalize_path(first_path),
			ProjectSettings.globalize_path(moved_path)
		)
		_expect_equal(rename_error, OK, "campaign fixture file moves")
		if rename_error == OK:
			var moved := ResourceLoader.load(moved_path, "", ResourceLoader.CACHE_MODE_IGNORE) as ZeliardCampaignDefinition
			_expect(moved != null, "moved campaign reloads")
			if moved != null:
				_expect_equal(moved.content_id, &"campaign:example", "stable ID survives file move and rename")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(first_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(moved_path))


func _test_deterministic_save_migration() -> void:
	var source_text := FileAccess.get_file_as_string("res://tests/fixtures/saves/save_v1.json")
	var expected_text := FileAccess.get_file_as_string("res://tests/fixtures/saves/save_v2_expected.json")
	var expected_result := ZeliardSaveCodec.decode(expected_text)
	var first := ZeliardSaveCodec.decode(source_text)
	var second := ZeliardSaveCodec.decode(source_text)
	_expect(expected_result.success, "expected version 2 save fixture decodes")
	_expect(first.success, "version 1 save fixture migrates")
	_expect(second.success, "version 1 save fixture migrates repeatedly")
	if expected_result.success and first.success and second.success:
		_expect_equal(first.migrated_from_version, 1, "migration reports source schema version")
		_expect_equal(first.data.to_dictionary(), expected_result.data.to_dictionary(), "version 1 fixture matches expected version 2 state")
		_expect_equal(first.data.to_dictionary(), second.data.to_dictionary(), "save migration is deterministic")
		_expect_equal(ZeliardSaveCodec.encode(first.data), ZeliardSaveCodec.encode(second.data), "migrated save encoding is deterministic")


func _test_save_checksum_integrity() -> void:
	var data := _example_save_data(10)
	var encoded := ZeliardSaveCodec.encode(data)
	_expect(ZeliardSaveCodec.decode(encoded).success, "current save integrity envelope decodes")
	var envelope := JSON.parse_string(encoded) as Dictionary
	var payload := envelope["payload"] as Dictionary
	payload["player_health"] = 9
	var tampered := JSON.stringify(envelope, "\t", true)
	var decoded := ZeliardSaveCodec.decode(tampered)
	_expect(not decoded.success, "tampered save payload is rejected")
	_expect(decoded.error_message.contains("checksum"), "tampered save reports checksum failure")


func _test_atomic_save_rotation() -> void:
	var path := "user://zeliard2_atomic_test.save"
	_cleanup_save_paths(path)
	_expect_equal(ZeliardSaveStore.save(path, _example_save_data(10)), OK, "initial atomic save succeeds")
	_expect_equal(ZeliardSaveStore.save(path, _example_save_data(6)), OK, "replacement atomic save succeeds")
	var current := ZeliardSaveStore.load(path)
	var backup := ZeliardSaveCodec.decode(_read_text(path + ".backup"))
	_expect(current.success, "current atomic save loads")
	_expect(backup.success, "rotated backup remains valid")
	if current.success:
		_expect_equal(current.data.player_health, 6, "primary contains replacement state")
	if backup.success:
		_expect_equal(backup.data.player_health, 10, "backup contains previous valid state")
	_expect(not FileAccess.file_exists(path + ".tmp"), "verified temporary file is installed, not abandoned")
	_cleanup_save_paths(path)


func _test_corrupt_save_recovery_is_non_destructive() -> void:
	var path := "user://zeliard2_recovery_test.save"
	_cleanup_save_paths(path)
	ZeliardSaveStore.save(path, _example_save_data(10))
	ZeliardSaveStore.save(path, _example_save_data(6))
	_write_text(path, "{ definitely not valid JSON")
	var corrupt_before := _read_text(path)
	var recovered := ZeliardSaveStore.load(path)
	_expect(recovered.success, "valid backup recovers a corrupt primary")
	_expect(recovered.recovered_from_backup, "load result identifies backup recovery")
	if recovered.success:
		_expect_equal(recovered.data.player_health, 10, "recovery returns last valid backup")
	_expect_equal(_read_text(path), corrupt_before, "recovery does not rewrite corrupt primary")
	var backup_before := _read_text(path + ".backup")
	_expect_equal(ZeliardSaveStore.save(path, _example_save_data(4)), OK, "new save succeeds beside corrupt primary")
	_expect_equal(_read_text(path + ".backup"), backup_before, "new save does not overwrite recoverable backup with corrupt data")
	_expect(FileAccess.file_exists(path + ".corrupt"), "corrupt primary is quarantined")
	_cleanup_save_paths(path)
	_write_text(path, "{ still corrupt")
	var lone_corrupt_before := _read_text(path)
	var failed := ZeliardSaveStore.load(path)
	_expect(not failed.success, "corrupt save without backup fails safely")
	_expect_equal(_read_text(path), lone_corrupt_before, "failed recovery leaves lone corrupt save untouched")
	_cleanup_save_paths(path)


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


func _errors_contain(invalid: Dictionary, owner_id: StringName, fragment: String) -> bool:
	var errors := invalid.get(owner_id, PackedStringArray()) as PackedStringArray
	for message: String in errors:
		if message.contains(fragment):
			return true
	return false


func _resource_snapshot(resource: Resource) -> Dictionary:
	var snapshot: Dictionary = {}
	for property: Dictionary in resource.get_property_list():
		var property_name := StringName(property["name"])
		var usage := int(property["usage"])
		if usage & PROPERTY_USAGE_STORAGE == 0:
			continue
		if property_name in [&"script", &"resource_name", &"resource_local_to_scene"]:
			continue
		snapshot[property_name] = _snapshot_value(resource.get(property_name))
	return snapshot


func _snapshot_value(value: Variant) -> Variant:
	if value is Resource:
		return _resource_snapshot(value as Resource)
	if value is Array:
		var items: Array[Variant] = []
		for item: Variant in value:
			items.append(_snapshot_value(item))
		return items
	if value is PackedStringArray:
		return Array(value as PackedStringArray)
	return value


func _example_save_data(health: int) -> ZeliardSaveData:
	var data := ZeliardSaveData.new()
	data.campaign_id = &"campaign:example"
	data.current_room_id = &"room:verdant_arrival"
	data.player_health = health
	data.inventory_ids = PackedStringArray(["item:bronze_key"])
	data.quest_stages = {"quest:open_gate": 0}
	data.flags = {"gate_seen": true}
	return data


func _read_text(path: String) -> String:
	return FileAccess.get_file_as_string(path)


func _write_text(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	_expect(file != null, "%s opens for test write" % path)
	if file != null:
		file.store_string(text)
		file.close()


func _cleanup_save_paths(path: String) -> void:
	var suffixes := PackedStringArray(["", ".backup", ".tmp", ".corrupt"])
	for index: int in 5:
		suffixes.append(".corrupt.%d" % index)
	for suffix: String in suffixes:
		var candidate := path + suffix
		if FileAccess.file_exists(candidate):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(candidate))


func _expect(condition: bool, description: String) -> void:
	if not condition:
		_failures += 1
		printerr("FAIL: %s" % description)


func _expect_equal(actual: Variant, expected: Variant, description: String) -> void:
	_expect(actual == expected, "%s (expected %s, got %s)" % [description, expected, actual])

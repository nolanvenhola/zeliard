class_name ZeliardSaveMigrator
extends RefCounted


static func migrate(source: Dictionary) -> ZeliardSaveMigrationResult:
	var result := ZeliardSaveMigrationResult.new()
	if not source.has("schema_version"):
		result.error_message = "save payload has no schema_version"
		return result
	var version := int(source["schema_version"])
	result.migrated_from_version = version
	var payload := source.duplicate(true)
	while version < ZeliardSaveData.CURRENT_SCHEMA_VERSION:
		match version:
			1:
				payload = _migrate_v1_to_v2(payload)
				version = 2
			_:
				result.error_message = "no migration from save schema_version %d" % version
				return result
	if version != ZeliardSaveData.CURRENT_SCHEMA_VERSION:
		result.error_message = "save schema_version %d is newer than supported version %d" % [version, ZeliardSaveData.CURRENT_SCHEMA_VERSION]
		return result
	result.success = true
	result.payload = payload
	return result


static func _migrate_v1_to_v2(source: Dictionary) -> Dictionary:
	return {
		"campaign_id": source.get("campaign", ""),
		"current_room_id": source.get("room", ""),
		"flags": (source.get("flags", {}) as Dictionary).duplicate(true),
		"inventory_ids": (source.get("inventory", []) as Array).duplicate(true),
		"player_health": int(source.get("health", 0)),
		"quest_stages": (source.get("quests", {}) as Dictionary).duplicate(true),
		"schema_version": 2,
	}

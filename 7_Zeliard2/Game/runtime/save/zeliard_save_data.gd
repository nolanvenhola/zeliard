class_name ZeliardSaveData
extends RefCounted

const CURRENT_SCHEMA_VERSION: int = 2

var schema_version: int = CURRENT_SCHEMA_VERSION
var campaign_id: StringName = &""
var current_room_id: StringName = &""
var player_health: int = 0
var inventory_ids := PackedStringArray()
var quest_stages: Dictionary = {}
var flags: Dictionary = {}


func to_dictionary() -> Dictionary:
	return {
		"campaign_id": String(campaign_id),
		"current_room_id": String(current_room_id),
		"flags": flags.duplicate(true),
		"inventory_ids": Array(inventory_ids),
		"player_health": player_health,
		"quest_stages": quest_stages.duplicate(true),
		"schema_version": schema_version,
	}


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if schema_version != CURRENT_SCHEMA_VERSION:
		errors.append("unsupported save schema_version %d" % schema_version)
	if not String(campaign_id).begins_with("campaign:"):
		errors.append("campaign_id must identify a campaign")
	if not String(current_room_id).begins_with("room:"):
		errors.append("current_room_id must identify a room")
	if player_health < 0:
		errors.append("player_health cannot be negative")
	for item_id: String in inventory_ids:
		if not item_id.begins_with("item:"):
			errors.append("inventory_ids must identify items")
	return errors


static func from_dictionary(payload: Dictionary) -> ZeliardSaveData:
	var data := ZeliardSaveData.new()
	data.schema_version = int(payload["schema_version"])
	data.campaign_id = StringName(String(payload["campaign_id"]))
	data.current_room_id = StringName(String(payload["current_room_id"]))
	data.player_health = int(payload["player_health"])
	data.inventory_ids = PackedStringArray(payload["inventory_ids"])
	data.quest_stages = (payload["quest_stages"] as Dictionary).duplicate(true)
	data.flags = (payload["flags"] as Dictionary).duplicate(true)
	return data

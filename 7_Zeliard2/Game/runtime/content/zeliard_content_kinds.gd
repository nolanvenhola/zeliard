@tool
class_name ZeliardContentKinds
extends RefCounted

const CONTENT: StringName = &"content"
const CAMPAIGN: StringName = &"campaign"
const REGION: StringName = &"region"
const ROOM: StringName = &"room"
const ACTOR: StringName = &"actor"
const ENEMY: StringName = &"enemy"
const ITEM: StringName = &"item"
const ABILITY: StringName = &"ability"
const DIALOGUE: StringName = &"dialogue"
const QUEST: StringName = &"quest"
const ASSET: StringName = &"asset"
const EVENT: StringName = &"event"


static func all() -> PackedStringArray:
	return PackedStringArray([
		CAMPAIGN, REGION, ROOM, ACTOR, ENEMY, ITEM,
		ABILITY, DIALOGUE, QUEST, ASSET, EVENT,
	])

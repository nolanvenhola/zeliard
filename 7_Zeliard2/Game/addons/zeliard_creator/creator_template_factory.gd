@tool
class_name ZeliardCreatorTemplateFactory
extends RefCounted


static func create(
	kind: StringName,
	content_id: StringName,
	display_name: String,
	catalog: ZeliardContentCatalog
) -> ZeliardContent:
	var content := _instantiate(kind)
	if content == null:
		return null
	content.content_id = content_id
	content.display_name = display_name
	var asset_id := _first_id(catalog, ZeliardContentKinds.ASSET)
	var region_id := _first_id(catalog, ZeliardContentKinds.REGION)
	var room_id := _first_id(catalog, ZeliardContentKinds.ROOM)
	match kind:
		ZeliardContentKinds.ASSET:
			var asset := content as ZeliardAssetDefinition
			asset.source_path = "res://content/example/assets/hero_placeholder.png"
			asset.authoring_source_path = asset.source_path
			asset.frame_size = Vector2i(16, 24)
			asset.pivot = Vector2i(8, 23)
			asset.palette_color_limit = 5
			asset.provenance = _placeholder_provenance()
		ZeliardContentKinds.ACTOR:
			(content as ZeliardActorDefinition).sprite_asset_id = asset_id
		ZeliardContentKinds.ENEMY:
			(content as ZeliardEnemyDefinition).sprite_asset_id = asset_id
		ZeliardContentKinds.ITEM:
			(content as ZeliardItemDefinition).icon_asset_id = asset_id
		ZeliardContentKinds.DIALOGUE:
			var line := ZeliardDialogueLine.new()
			line.line_id = &"opening"
			line.text = "New dialogue line"
			(content as ZeliardDialogueDefinition).lines = [line]
		ZeliardContentKinds.QUEST:
			var stage := ZeliardQuestStage.new()
			stage.stage_id = &"start"
			stage.description = "New quest stage"
			(content as ZeliardQuestDefinition).stages = [stage]
		ZeliardContentKinds.EVENT:
			var step := ZeliardEventStep.new()
			step.action = "set_flag"
			step.flag_id = &"new_event"
			(content as ZeliardEventDefinition).steps = [step]
		ZeliardContentKinds.ROOM:
			(content as ZeliardRoomDefinition).region_id = region_id
		ZeliardContentKinds.REGION:
			var region := content as ZeliardRegionDefinition
			region.room_ids = PackedStringArray([room_id])
			region.entry_room_id = room_id
		ZeliardContentKinds.CAMPAIGN:
			var campaign := content as ZeliardCampaignDefinition
			campaign.region_ids = PackedStringArray([region_id])
			campaign.starting_region_id = region_id
			campaign.player_actor_id = _first_id(catalog, ZeliardContentKinds.ACTOR)
	return content


static func output_path(content: ZeliardContent) -> String:
	var file_name := String(content.content_id).get_slice(":", 1)
	return "res://content/created/%s/%s.tres" % [content.content_kind(), file_name]


static func _instantiate(kind: StringName) -> ZeliardContent:
	match kind:
		ZeliardContentKinds.CAMPAIGN: return ZeliardCampaignDefinition.new()
		ZeliardContentKinds.REGION: return ZeliardRegionDefinition.new()
		ZeliardContentKinds.ROOM: return ZeliardRoomDefinition.new()
		ZeliardContentKinds.ACTOR: return ZeliardActorDefinition.new()
		ZeliardContentKinds.ENEMY: return ZeliardEnemyDefinition.new()
		ZeliardContentKinds.ITEM: return ZeliardItemDefinition.new()
		ZeliardContentKinds.ABILITY: return ZeliardAbilityDefinition.new()
		ZeliardContentKinds.DIALOGUE: return ZeliardDialogueDefinition.new()
		ZeliardContentKinds.QUEST: return ZeliardQuestDefinition.new()
		ZeliardContentKinds.ASSET: return ZeliardAssetDefinition.new()
		ZeliardContentKinds.EVENT: return ZeliardEventDefinition.new()
		_: return null


static func _first_id(catalog: ZeliardContentCatalog, kind: StringName) -> StringName:
	for content: ZeliardContent in catalog.all():
		if content.content_kind() == kind:
			return content.content_id
	return &""


static func _placeholder_provenance() -> ZeliardAssetProvenance:
	var provenance := ZeliardAssetProvenance.new()
	provenance.creator = "Zeliard Project"
	provenance.rights_holder = "Zeliard Project"
	provenance.source_record = "Original placeholder created by the Zeliard Creator template."
	provenance.license_name = "Project-owned original"
	provenance.modification_permitted = true
	provenance.commercial_distribution_permitted = true
	provenance.tools_and_versions = "Zeliard Creator for Godot 4.7.2"
	provenance.creation_date = Time.get_date_string_from_system()
	provenance.placeholder = true
	return provenance

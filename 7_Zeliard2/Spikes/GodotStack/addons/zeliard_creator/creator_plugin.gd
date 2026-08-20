@tool
extends EditorPlugin

const RoomInspector = preload("res://addons/zeliard_creator/room_definition_inspector.gd")
const PLAY_FROM_ROOM_FILE: String = "res://.godot/zeliard_play_from_room.txt"

var room_inspector: EditorInspectorPlugin
var creator_dock: VBoxContainer
var selection_label: Label


func _enter_tree() -> void:
	room_inspector = RoomInspector.new()
	room_inspector.play_requested.connect(_play_room)
	add_inspector_plugin(room_inspector)
	_build_dock()


func _exit_tree() -> void:
	if room_inspector != null:
		remove_inspector_plugin(room_inspector)
	if creator_dock != null:
		remove_control_from_docks(creator_dock)
		creator_dock.queue_free()


func _build_dock() -> void:
	creator_dock = VBoxContainer.new()
	creator_dock.name = "Zeliard Creator"
	var heading := Label.new()
	heading.text = "Zeliard Creator Spike"
	creator_dock.add_child(heading)
	selection_label = Label.new()
	selection_label.text = "Select a ZeliardRoomDefinition resource."
	selection_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	creator_dock.add_child(selection_label)
	var play_button := Button.new()
	play_button.text = "Play From Selected Room"
	play_button.pressed.connect(_play_selected_room)
	creator_dock.add_child(play_button)
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, creator_dock)


func _play_selected_room() -> void:
	var edited_object := get_editor_interface().get_inspector().get_edited_object()
	if edited_object is ZeliardRoomDefinition:
		_play_room(edited_object as ZeliardRoomDefinition)
	else:
		selection_label.text = "Select a ZeliardRoomDefinition resource first."


func _play_room(room: ZeliardRoomDefinition) -> void:
	var errors := room.validation_errors()
	if not errors.is_empty():
		selection_label.text = "Cannot play: %s" % ", ".join(errors)
		return
	if room.resource_path.is_empty():
		selection_label.text = "Save the room resource before playing."
		return
	var selection_file := FileAccess.open(PLAY_FROM_ROOM_FILE, FileAccess.WRITE)
	if selection_file == null:
		selection_label.text = "Could not write the local play-from-here selection."
		return
	selection_file.store_string(room.resource_path)
	selection_file.close()
	selection_label.text = "Playing from %s" % room.content_id
	get_editor_interface().play_main_scene()

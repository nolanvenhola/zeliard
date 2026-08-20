@tool
extends EditorInspectorPlugin

signal play_requested(room: ZeliardRoomDefinition)


func _can_handle(object: Object) -> bool:
	return object is ZeliardRoomDefinition


func _parse_begin(object: Object) -> void:
	var room := object as ZeliardRoomDefinition
	var panel := VBoxContainer.new()
	var title := Label.new()
	title.text = "Zeliard Room: %s" % room.content_id
	panel.add_child(title)
	var validation_label := Label.new()
	validation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(validation_label)
	var validate_button := Button.new()
	validate_button.text = "Validate Room"
	validate_button.pressed.connect(_validate_room.bind(room, validation_label))
	panel.add_child(validate_button)
	var play_button := Button.new()
	play_button.text = "Play From Here"
	play_button.pressed.connect(_request_play.bind(room))
	panel.add_child(play_button)
	add_custom_control(panel)
	_validate_room(room, validation_label)


func _validate_room(room: ZeliardRoomDefinition, label: Label) -> void:
	var errors := room.validation_errors()
	label.text = "Valid" if errors.is_empty() else "Invalid: %s" % ", ".join(errors)


func _request_play(room: ZeliardRoomDefinition) -> void:
	play_requested.emit(room)

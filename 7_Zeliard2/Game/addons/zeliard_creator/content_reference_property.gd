@tool
class_name ZeliardContentReferenceProperty
extends EditorProperty

var _choices: Array[ZeliardContent] = []
var _is_collection: bool = false
var _option: OptionButton
var _items: ItemList
var _updating: bool = false


func configure(choices: Array[ZeliardContent], is_collection: bool) -> void:
	_choices = choices
	_is_collection = is_collection
	if is_collection:
		_build_collection_editor()
	else:
		_build_single_editor()


func _update_property() -> void:
	if _option == null:
		return
	_updating = true
	var value: Variant = get_edited_object().get(get_edited_property())
	if _is_collection:
		_items.clear()
		for content_id: String in value as PackedStringArray:
			_items.add_item(content_id)
		_option.select(0)
	else:
		var selected_id := StringName(value)
		_option.select(0)
		for index: int in _choices.size():
			if _choices[index].content_id == selected_id:
				_option.select(index + 1)
				break
	_updating = false


func _build_single_editor() -> void:
	_option = OptionButton.new()
	_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_populate_options("None")
	_option.item_selected.connect(_on_single_selected)
	add_child(_option)
	add_focusable(_option)


func _build_collection_editor() -> void:
	var container := VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_option = OptionButton.new()
	_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_populate_options("Add reference...")
	_option.item_selected.connect(_on_collection_selected)
	container.add_child(_option)
	_items = ItemList.new()
	_items.custom_minimum_size.y = 72.0
	_items.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(_items)
	var remove_button := Button.new()
	remove_button.text = "Remove selected"
	remove_button.pressed.connect(_on_remove_selected)
	container.add_child(remove_button)
	add_child(container)
	set_bottom_editor(container)
	add_focusable(_option)
	add_focusable(_items)


func _populate_options(empty_label: String) -> void:
	_option.add_item(empty_label)
	for content: ZeliardContent in _choices:
		_option.add_item("%s — %s" % [content.content_id, content.display_name])


func _on_single_selected(index: int) -> void:
	if _updating:
		return
	var value := &"" if index == 0 else _choices[index - 1].content_id
	emit_changed(get_edited_property(), value)


func _on_collection_selected(index: int) -> void:
	if _updating or index == 0:
		return
	var values := get_edited_object().get(get_edited_property()) as PackedStringArray
	var selected_id := String(_choices[index - 1].content_id)
	if not values.has(selected_id):
		values.append(selected_id)
		emit_changed(get_edited_property(), values)
	_option.select(0)


func _on_remove_selected() -> void:
	var selected := _items.get_selected_items()
	if selected.is_empty():
		return
	var values := get_edited_object().get(get_edited_property()) as PackedStringArray
	for index: int in selected:
		values.remove_at(index)
	emit_changed(get_edited_property(), values)

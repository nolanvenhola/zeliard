@tool
class_name ZeliardCreatorDock
extends VBoxContainer

signal refresh_requested
signal validate_requested
signal create_requested(kind: StringName, content_id: StringName, display_name: String)
signal content_activated(content: ZeliardContent)
signal diagnostic_activated(diagnostic: ZeliardDiagnostic)

var _index: ZeliardCreatorCatalogIndex
var _dirty: ZeliardCreatorDirtyTracker
var _search: LineEdit
var _kind_filter: OptionButton
var _content_tree: Tree
var _diagnostic_tree: Tree
var _status: Label
var _new_form: VBoxContainer
var _new_kind: OptionButton
var _new_id: LineEdit
var _new_name: LineEdit
var _diagnostics: Array[ZeliardDiagnostic] = []


func setup(index: ZeliardCreatorCatalogIndex, dirty: ZeliardCreatorDirtyTracker) -> void:
	_index = index
	_dirty = dirty
	name = "Zeliard Creator"
	_build_ui()
	refresh()


func refresh() -> void:
	if _content_tree == null:
		return
	_content_tree.clear()
	var root := _content_tree.create_item()
	var kind := &""
	if _kind_filter.selected > 0:
		kind = StringName(_kind_filter.get_item_text(_kind_filter.selected))
	for content: ZeliardContent in _index.search(_search.text, kind):
		var item := _content_tree.create_item(root)
		item.set_text(0, String(content.content_id))
		item.set_text(1, content.display_name)
		item.set_text(2, String(content.content_kind()))
		item.set_metadata(0, content)
		if _dirty.contains(content.resource_path):
			item.set_text(0, "● " + item.get_text(0))
	var dirty_suffix := ""
	if not _dirty.status_text().is_empty():
		dirty_suffix = " · %s" % _dirty.status_text()
	_status.text = "%d resource(s)%s" % [root.get_child_count(), dirty_suffix]


func show_diagnostics(diagnostics: Array[ZeliardDiagnostic]) -> void:
	_diagnostics = diagnostics
	_diagnostic_tree.clear()
	var root := _diagnostic_tree.create_item()
	for index: int in diagnostics.size():
		var diagnostic := diagnostics[index]
		var item := _diagnostic_tree.create_item(root)
		item.set_text(0, String(diagnostic.severity).to_upper())
		item.set_text(1, "%s: %s" % [diagnostic.owner_id, diagnostic.message])
		item.set_tooltip_text(1, diagnostic.format())
		item.set_metadata(0, index)
	_status.text = "Content is valid" if diagnostics.is_empty() else "%d validation error(s)" % diagnostics.size()


func set_status(message: String) -> void:
	_status.text = message


func _build_ui() -> void:
	var heading := Label.new()
	heading.text = "Zeliard Creator"
	heading.add_theme_font_size_override("font_size", 18)
	add_child(heading)
	var toolbar := HBoxContainer.new()
	var new_button := Button.new()
	new_button.text = "New"
	new_button.pressed.connect(func() -> void: _new_form.visible = not _new_form.visible)
	toolbar.add_child(new_button)
	var refresh_button := Button.new()
	refresh_button.text = "Refresh"
	refresh_button.pressed.connect(func() -> void: refresh_requested.emit())
	toolbar.add_child(refresh_button)
	var validate_button := Button.new()
	validate_button.text = "Validate"
	validate_button.pressed.connect(func() -> void: validate_requested.emit())
	toolbar.add_child(validate_button)
	add_child(toolbar)
	_build_new_form()
	_search = LineEdit.new()
	_search.placeholder_text = "Search ID, name, or kind..."
	_search.text_changed.connect(func(_value: String) -> void: refresh())
	add_child(_search)
	_kind_filter = OptionButton.new()
	_kind_filter.add_item("All kinds")
	for kind: String in ZeliardContentKinds.all():
		_kind_filter.add_item(kind)
	_kind_filter.item_selected.connect(func(_selected: int) -> void: refresh())
	add_child(_kind_filter)
	_content_tree = Tree.new()
	_content_tree.columns = 3
	_content_tree.column_titles_visible = true
	_content_tree.set_column_title(0, "Stable ID")
	_content_tree.set_column_title(1, "Name")
	_content_tree.set_column_title(2, "Kind")
	_content_tree.hide_root = true
	_content_tree.custom_minimum_size.y = 220.0
	_content_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_tree.item_activated.connect(_on_content_activated)
	add_child(_content_tree)
	var validation_heading := Label.new()
	validation_heading.text = "Validation"
	add_child(validation_heading)
	_diagnostic_tree = Tree.new()
	_diagnostic_tree.columns = 2
	_diagnostic_tree.hide_root = true
	_diagnostic_tree.custom_minimum_size.y = 120.0
	_diagnostic_tree.set_column_expand(0, false)
	_diagnostic_tree.set_column_custom_minimum_width(0, 64)
	_diagnostic_tree.item_activated.connect(_on_diagnostic_activated)
	add_child(_diagnostic_tree)
	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.text = "Ready"
	add_child(_status)


func _build_new_form() -> void:
	_new_form = VBoxContainer.new()
	_new_form.visible = false
	_new_kind = OptionButton.new()
	for kind: String in ZeliardContentKinds.all():
		_new_kind.add_item(kind)
	_new_form.add_child(_new_kind)
	_new_id = LineEdit.new()
	_new_id.placeholder_text = "Stable ID, for example room:crystal_gate"
	_new_form.add_child(_new_id)
	_new_name = LineEdit.new()
	_new_name.placeholder_text = "Display name"
	_new_form.add_child(_new_name)
	var create_button := Button.new()
	create_button.text = "Create valid resource"
	create_button.pressed.connect(_on_create_pressed)
	_new_form.add_child(create_button)
	add_child(_new_form)


func _on_create_pressed() -> void:
	var kind := StringName(_new_kind.get_item_text(_new_kind.selected))
	create_requested.emit(kind, StringName(_new_id.text.strip_edges()), _new_name.text.strip_edges())


func _on_content_activated() -> void:
	var item := _content_tree.get_selected()
	if item != null:
		content_activated.emit(item.get_metadata(0) as ZeliardContent)


func _on_diagnostic_activated() -> void:
	var item := _diagnostic_tree.get_selected()
	if item == null:
		return
	var index := int(item.get_metadata(0))
	if index >= 0 and index < _diagnostics.size():
		diagnostic_activated.emit(_diagnostics[index])

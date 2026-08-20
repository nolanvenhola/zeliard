@tool
class_name ZeliardCreatorCatalogIndex
extends RefCounted

var _resources: Array[ZeliardContent] = []


func rebuild(catalog: ZeliardContentCatalog) -> void:
	_resources = catalog.all()
	_resources.sort_custom(_sort_content)


func search(query: String = "", kind: StringName = &"") -> Array[ZeliardContent]:
	var results: Array[ZeliardContent] = []
	var needle := query.strip_edges().to_lower()
	for content: ZeliardContent in _resources:
		if not kind.is_empty() and content.content_kind() != kind:
			continue
		if not needle.is_empty():
			var haystack := "%s\n%s\n%s" % [content.content_id, content.display_name, content.content_kind()]
			if not haystack.to_lower().contains(needle):
				continue
		results.append(content)
	return results


func choices(kind: StringName) -> Array[ZeliardContent]:
	return search("", kind)


static func _sort_content(left: ZeliardContent, right: ZeliardContent) -> bool:
	var left_key := "%s\n%s" % [left.content_kind(), left.content_id]
	var right_key := "%s\n%s" % [right.content_kind(), right.content_id]
	return left_key < right_key

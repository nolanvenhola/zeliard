# Zeliard Creator Workflow

Zeliard Creator is the content-authoring dock included with the production Godot project. It keeps everyday work in stable, searchable game concepts instead of asking creators to navigate raw folders or type cross-resource identifiers.

## Find and edit content

Open the **Zeliard Creator** dock on the right side of the Godot editor. Search matches stable ID, display name, and content kind. Use the kind filter to narrow the catalog, then double-click a result to select its file and open it in the Inspector.

A filled circle beside a stable ID marks a resource changed since its last save. Godot's normal **Save All** command saves these external resources, and the editor warns when tracked Zeliard content remains unsaved.

## Create content

Select **New**, choose one of the eleven content kinds, and enter a canonical stable ID such as `room:crystal_gate` plus a display name. **Create valid resource** writes a modern `.tres` file beneath `content/created/<kind>/` and opens it for editing.

Templates include the minimum valid structure for their kind. Required cross-resource fields begin with compatible entries from the existing catalog, so the new resource passes both local and graph validation before it is written. Duplicate IDs, malformed IDs, missing required values, and invalid graphs are rejected without creating a file.

## Select references

Stable-ID fields use Creator pickers in the Inspector. Single references are dropdowns; reference collections provide an add picker and removable list. Choices are filtered to the required content kind, so an actor field cannot accidentally receive an item ID. Nested dialogue lines, quest stages, room exits, and event steps expose the same metadata where their target kind is known.

## Validate and navigate

Select **Validate** to run the same graph validator used by headless tests and CI. Double-click an error to select its owning resource and focus the relevant Inspector property. This keeps editor and automated diagnostics deterministic and prevents a separate set of Creator-only rules.

## Specialized editor extensions

Future visual room, dialogue, quest, animation, and audio tools can register a handler with `register_specialized_editor(kind, handler)` on the Creator plugin. Catalog activation invokes that handler for the registered kind; all other resources continue through the standard Inspector. Unregister the handler when the extension leaves the editor tree.

@tool
extends Node3D

@export var reference_terminal_path: NodePath = NodePath("CubicleGrid/Cubicle02/Desk/ComputerTerminal")
@export var auto_sync_on_ready := true

var _sync_now_state := false
var _pending_sync := false

@export var sync_now: bool:
	set(value):
		if value:
			if is_inside_tree():
				call_deferred("apply_reference_layout")
			else:
				_pending_sync = true
		_sync_now_state = false
		notify_property_list_changed()
	get:
		return _sync_now_state

func _ready() -> void:
	if auto_sync_on_ready or _pending_sync:
		_pending_sync = false
		call_deferred("apply_reference_layout")

func apply_reference_layout() -> void:
	var reference_terminal := get_node_or_null(reference_terminal_path) as Node3D
	if reference_terminal == null:
		push_warning("Reference computer terminal not found: %s" % reference_terminal_path)
		return

	var terminals := _collect_terminals(self)
	if terminals.is_empty():
		push_warning("No computer terminals found to sync.")
		return

	var reference_area := reference_terminal.get_node_or_null("InteractArea") as Area3D
	var reference_shape := reference_area.get_node_or_null("InteractShape") as CollisionShape3D if reference_area != null else null
	var reference_screen_white := reference_terminal.get_node_or_null("ScreenWhite") as MeshInstance3D

	for terminal in terminals:
		if terminal == reference_terminal:
			continue

		terminal.transform = reference_terminal.transform

		var area := terminal.get_node_or_null("InteractArea") as Area3D
		var shape := area.get_node_or_null("InteractShape") as CollisionShape3D if area != null else null
		if area != null and reference_area != null:
			area.transform = reference_area.transform
		if shape != null and reference_shape != null and reference_shape.shape is BoxShape3D:
			var reference_box := reference_shape.shape as BoxShape3D
			var box := shape.shape as BoxShape3D
			if box == null:
				box = BoxShape3D.new()
			box.size = reference_box.size
			shape.shape = box

		_sync_screen_white(terminal, reference_screen_white)

func _sync_screen_white(target_terminal: Node3D, reference_screen_white: MeshInstance3D) -> void:
	var existing := target_terminal.get_node_or_null("ScreenWhite")
	if reference_screen_white == null:
		if existing != null:
			existing.queue_free()
		return

	var screen_white: MeshInstance3D = existing as MeshInstance3D
	if screen_white == null:
		if existing != null:
			existing.queue_free()
		screen_white = MeshInstance3D.new()
		screen_white.name = "ScreenWhite"
		target_terminal.add_child(screen_white)
		screen_white.owner = target_terminal.owner

	screen_white.transform = reference_screen_white.transform
	screen_white.cast_shadow = reference_screen_white.cast_shadow
	screen_white.material_override = reference_screen_white.material_override
	screen_white.mesh = reference_screen_white.mesh

func _collect_terminals(root: Node) -> Array[Node3D]:
	var terminals: Array[Node3D] = []
	for child in root.get_children():
		if child is Node3D and String(child.name) == "ComputerTerminal":
			terminals.append(child)
		terminals.append_array(_collect_terminals(child))
	return terminals

extends Node3D

signal opened

@export var prompt_text := "E - открыть дверь"
@export var interaction_radius := 2.2
@export var sign_text := "ВЫХОДА НЕТ"

@onready var _area: Area3D = _ensure_interact_area()
@onready var _sign_label: Label3D = get_node_or_null("ExitDoorSign") as Label3D

var _interaction_locked := false

func _ready() -> void:
	add_to_group("player_interactable")
	add_to_group("exit_door_interactable")
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	_set_area_enabled(false)
	if _sign_label != null:
		_sign_label.text = sign_text
	_set_sign_visible(false)

func get_prompt_text() -> String:
	return prompt_text

func can_interact_from(world_position: Vector3) -> bool:
	if not visible or _interaction_locked:
		return false
	var target_position := get_interaction_target_position()
	target_position.y = world_position.y
	return target_position.distance_to(world_position) <= interaction_radius

func interact() -> bool:
	if not visible or _interaction_locked:
		return false
	opened.emit()
	return true

func get_interaction_target_position() -> Vector3:
	return global_position + Vector3.UP * 1.0

func get_screen_forward() -> Vector3:
	return global_transform.basis.z.normalized()

func requires_front_interaction() -> bool:
	return false

func requires_clear_interaction_path() -> bool:
	return false

func requires_facing_interaction() -> bool:
	return false

func set_interactable_enabled(enabled: bool) -> void:
	visible = enabled
	_interaction_locked = false
	process_mode = Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED
	_set_area_enabled(enabled)
	_set_sign_visible(enabled)

func set_interaction_locked(locked: bool) -> void:
	_interaction_locked = locked
	if visible:
		_set_area_enabled(not locked)

func _ensure_interact_area() -> Area3D:
	var existing := get_node_or_null("InteractArea") as Area3D
	if existing != null:
		return existing

	var area := Area3D.new()
	area.name = "InteractArea"
	area.collision_layer = 1 << 9
	area.collision_mask = 0
	add_child(area)
	area.owner = owner

	var shape := CollisionShape3D.new()
	shape.name = "InteractShape"
	var box := BoxShape3D.new()
	box.size = Vector3(2.8, 2.6, 2.0)
	shape.shape = box
	shape.position = Vector3(0.0, 1.1, 0.0)
	area.add_child(shape)
	shape.owner = owner
	return area

func _set_area_enabled(enabled: bool) -> void:
	if _area == null:
		return
	_area.monitoring = enabled
	_area.monitorable = enabled

func _set_sign_visible(enabled: bool) -> void:
	if _sign_label == null:
		return
	_sign_label.visible = enabled

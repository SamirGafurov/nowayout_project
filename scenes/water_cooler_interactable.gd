extends Node3D

signal fill_requested(cooler: Node3D)

@export var prompt_text := "E - набрать воды"
@export var interaction_radius := 2.15
@export var interaction_height := 1.0

var _interaction_locked := true

func _ready() -> void:
	add_to_group("player_interactable")

func get_prompt_text() -> String:
	return prompt_text

func can_interact_from(world_position: Vector3) -> bool:
	if _interaction_locked or not is_visible_in_tree():
		return false
	var target_position := get_interaction_target_position()
	target_position.y = world_position.y
	return target_position.distance_to(world_position) <= interaction_radius

func interact() -> bool:
	if _interaction_locked or not is_visible_in_tree():
		return false
	fill_requested.emit(self)
	return true

func get_interaction_target_position() -> Vector3:
	var cooler_model := get_node_or_null("water_cooler") as Node3D
	if cooler_model != null:
		return cooler_model.global_position + Vector3.UP * interaction_height
	return global_position + Vector3.UP * interaction_height

func requires_front_interaction() -> bool:
	return false

func requires_clear_interaction_path() -> bool:
	return false

func requires_facing_interaction() -> bool:
	return false

func set_interaction_locked(locked: bool) -> void:
	_interaction_locked = locked

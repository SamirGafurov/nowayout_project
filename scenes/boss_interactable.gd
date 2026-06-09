extends Node3D

signal talk_requested

@export var prompt_text := "E - поговорить с боссом"
@export var interaction_radius := 10.0

var _interaction_locked := false

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
	talk_requested.emit()
	return true

func get_interaction_target_position() -> Vector3:
	return global_position

func requires_front_interaction() -> bool:
	return false

func requires_clear_interaction_path() -> bool:
	return false

func requires_facing_interaction() -> bool:
	return false

func set_interaction_locked(locked: bool) -> void:
	_interaction_locked = locked

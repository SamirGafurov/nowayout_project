extends Node3D

signal power_off_completed(power_off_count: int, terminal: Node3D)

@export var interaction_radius := 2.0
@export var prompt_text := "E - выключить компьютер"
@export var interaction_half_width := 0.55
@export var interaction_front_depth := 0.12
@export var interaction_vertical_tolerance := 1.4
@export var second_shutdown_message := "НЕ ДЕЛАЙ\nЭТОГО"
@export var second_shutdown_delay := 0.55
@export var fifth_shutdown_prompt_text := "E - нажать ещё раз"
@export var fifth_shutdown_first_message := "НАЖМИ\nЕЩЁ РАЗ"
@export var fifth_shutdown_second_message := "УХОДИ"
@export var fifth_shutdown_delay := 0.5
@export var sixth_shutdown_message := "ВЫХОДА НЕТ"
@export var sixth_shutdown_delay := 1.5

@onready var screen: MeshInstance3D = _find_screen()

var is_on := true
var is_transitioning := false
var is_fifth_shutdown_pending := false
var pending_power_off_count := 0
var warning_timer: SceneTreeTimer = null
var warning_label: Label3D = null

func _ready() -> void:
	add_to_group("computer_terminal")
	add_to_group("player_interactable")
	warning_label = _ensure_warning_label()
	apply_state()

func is_powered_on() -> bool:
	return is_on

func can_interact_from(world_position: Vector3) -> bool:
	if not is_visible_in_tree():
		return false
	if ((not is_on) and not is_fifth_shutdown_pending) or is_transitioning or _is_locked_by_other_pending_fifth_terminal():
		return false
	if get_interaction_target_position().distance_to(world_position) > interaction_radius:
		return false
	return is_player_in_interaction_zone(world_position)

func interact() -> bool:
	if _is_locked_by_other_pending_fifth_terminal() or is_transitioning:
		return false

	if is_fifth_shutdown_pending:
		_confirm_fifth_shutdown()
		return true

	if not is_on:
		return false

	pending_power_off_count = _get_reserved_power_off_count() + 1
	if pending_power_off_count == 2:
		_reserve_power_off_count(pending_power_off_count)
		is_transitioning = true
		_show_second_shutdown_warning()
	elif pending_power_off_count == 5:
		_begin_fifth_shutdown_confirmation()
	elif pending_power_off_count == 6:
		_reserve_power_off_count(pending_power_off_count)
		_begin_sixth_shutdown_warning()
	else:
		_reserve_power_off_count(pending_power_off_count)
		is_transitioning = true
		_finish_power_off(pending_power_off_count)
	return true

func get_prompt_text() -> String:
	if is_fifth_shutdown_pending:
		return fifth_shutdown_prompt_text
	return prompt_text

func apply_state() -> void:
	if screen == null:
		return

	var source_material := screen.get_active_material(0)
	if source_material == null or not source_material is StandardMaterial3D:
		source_material = StandardMaterial3D.new()

	var screen_material: StandardMaterial3D = source_material.duplicate()
	screen_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	screen_material.albedo_color = Color(0.96, 0.97, 1.0) if is_on else Color(0.01, 0.01, 0.01)
	screen_material.emission_enabled = true
	screen_material.emission = Color(0.95, 0.97, 1.0) if is_on else Color.BLACK
	screen_material.emission_energy_multiplier = 1.35 if is_on else 0.0
	screen_material.roughness = 0.08
	screen_material.metallic = 0.0
	screen.material_override = screen_material
	if warning_label != null:
		warning_label.visible = false

func _find_screen() -> MeshInstance3D:
	var manual_screen := get_node_or_null("ScreenWhite") as MeshInstance3D
	if manual_screen != null:
		return manual_screen

	return get_node_or_null("Screen") as MeshInstance3D

func get_interaction_target_position() -> Vector3:
	if screen != null:
		return screen.global_position

	var interact_area := get_node_or_null("InteractArea") as Node3D
	if interact_area != null:
		return interact_area.global_position

	return global_position

func get_screen_forward() -> Vector3:
	if screen != null:
		return screen.global_transform.basis.z.normalized()

	var interact_area := get_node_or_null("InteractArea") as Node3D
	if interact_area != null:
		return interact_area.global_transform.basis.z.normalized()

	return global_transform.basis.z.normalized()

func is_player_in_interaction_zone(world_position: Vector3) -> bool:
	var local_position := to_local(world_position)
	if abs(local_position.x) > interaction_half_width:
		return false
	if local_position.z < interaction_front_depth:
		return false
	if abs(local_position.y) > interaction_vertical_tolerance:
		return false
	return true

func _get_current_power_off_count() -> int:
	return int(get_tree().get_meta("powered_off_terminals", 0))

func _get_reserved_power_off_count() -> int:
	return int(get_tree().get_meta("reserved_power_off_terminals", _get_current_power_off_count()))

func _reserve_power_off_count(power_off_count: int) -> void:
	var current_reserved := _get_reserved_power_off_count()
	get_tree().set_meta("reserved_power_off_terminals", max(current_reserved, power_off_count))

func _show_second_shutdown_warning() -> void:
	_emit_audio_event("play_scare_hit")
	if screen != null:
		var warning_material := _create_screen_material(Color(0.97, 0.97, 0.97), Color(0.95, 0.18, 0.18), 0.6)
		screen.material_override = warning_material

	if warning_label != null:
		warning_label.text = second_shutdown_message
		warning_label.modulate = Color(1.0, 0.24, 0.24, 1.0)
		warning_label.visible = true

	warning_timer = get_tree().create_timer(second_shutdown_delay)
	warning_timer.timeout.connect(func() -> void:
		_finish_power_off(pending_power_off_count)
	)

func _begin_fifth_shutdown_confirmation() -> void:
	is_fifth_shutdown_pending = true
	_set_pending_fifth_terminal_id(get_instance_id())
	_emit_audio_event("play_scare_hit")
	if screen != null:
		screen.material_override = _create_screen_material(Color(0.85, 0.06, 0.06), Color(0.55, 0.02, 0.02), 0.55)
	if warning_label != null:
		warning_label.text = fifth_shutdown_first_message
		warning_label.modulate = Color(0.0, 0.0, 0.0, 1.0)
		warning_label.visible = true

func _confirm_fifth_shutdown() -> void:
	is_transitioning = true
	_emit_audio_event("play_whisper")
	if screen != null:
		screen.material_override = _create_screen_material(Color(0.65, 0.0, 0.0), Color(0.18, 0.0, 0.0), 0.1)
	if warning_label != null:
		warning_label.text = fifth_shutdown_second_message
		warning_label.modulate = Color(0.0, 0.0, 0.0, 1.0)
		warning_label.visible = true

	warning_timer = get_tree().create_timer(fifth_shutdown_delay)
	warning_timer.timeout.connect(func() -> void:
		_finish_power_off(pending_power_off_count)
	)

func _begin_sixth_shutdown_warning() -> void:
	is_transitioning = true
	if screen != null:
		screen.material_override = _create_screen_material(Color(0.96, 0.96, 0.96), Color(0.82, 0.82, 0.82), 0.28)
	if warning_label != null:
		warning_label.text = sixth_shutdown_message
		warning_label.modulate = Color(0.0, 0.0, 0.0, 1.0)
		warning_label.visible = true

	warning_timer = get_tree().create_timer(sixth_shutdown_delay)
	warning_timer.timeout.connect(func() -> void:
		_finish_power_off(pending_power_off_count)
	)

func _finish_power_off(power_off_count: int) -> void:
	get_tree().set_meta("powered_off_terminals", max(_get_current_power_off_count(), power_off_count))
	_reserve_power_off_count(power_off_count)
	_clear_pending_fifth_terminal_id()
	is_on = false
	is_fifth_shutdown_pending = false
	is_transitioning = false
	pending_power_off_count = power_off_count
	apply_state()
	power_off_completed.emit(pending_power_off_count, self)

func _get_pending_fifth_terminal_id() -> int:
	return int(get_tree().get_meta("pending_fifth_terminal_id", -1))

func _set_pending_fifth_terminal_id(terminal_id: int) -> void:
	get_tree().set_meta("pending_fifth_terminal_id", terminal_id)

func _clear_pending_fifth_terminal_id() -> void:
	var pending_id := _get_pending_fifth_terminal_id()
	if pending_id == get_instance_id():
		get_tree().set_meta("pending_fifth_terminal_id", -1)

func _is_locked_by_other_pending_fifth_terminal() -> bool:
	var pending_id := _get_pending_fifth_terminal_id()
	return pending_id != -1 and pending_id != get_instance_id()

func _create_screen_material(albedo: Color, emission: Color, emission_energy: float) -> StandardMaterial3D:
	var source_material := screen.get_active_material(0)
	if source_material == null or not source_material is StandardMaterial3D:
		source_material = StandardMaterial3D.new()

	var screen_material: StandardMaterial3D = source_material.duplicate()
	screen_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	screen_material.albedo_color = albedo
	screen_material.emission_enabled = true
	screen_material.emission = emission
	screen_material.emission_energy_multiplier = emission_energy
	screen_material.roughness = 0.08
	screen_material.metallic = 0.0
	return screen_material

func _ensure_warning_label() -> Label3D:
	var existing := get_node_or_null("WarningLabel") as Label3D
	if existing != null:
		return existing

	if screen == null:
		return null

	var label := Label3D.new()
	label.name = "WarningLabel"
	label.text = second_shutdown_message
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	label.no_depth_test = true
	label.font_size = 56
	label.outline_size = 8
	label.modulate = Color(1.0, 0.24, 0.24, 1.0)
	label.position = Vector3(0.0, 0.0, 0.008)
	label.pixel_size = 0.0023
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.visible = false
	screen.add_child(label)
	label.owner = owner
	return label

func set_display_visible(visible_state: bool) -> void:
	if screen != null:
		screen.visible = visible_state
	if warning_label != null and not visible_state:
		warning_label.visible = false

func _emit_audio_event(method_name: StringName) -> void:
	get_tree().call_group("game_audio_host", method_name)

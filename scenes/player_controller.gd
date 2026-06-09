extends CharacterBody3D

const FOOTSTEPS_STREAM := preload("res://audio/footsteps.mp3")
const FIRST_CYCLE_VIGNETTE_STRENGTH := 0.72
const NON_FIRST_CYCLE_VIGNETTE_STRENGTH := 0.0

@export var walk_speed := 2.3
@export var sprint_speed := 3.8
@export var mouse_sensitivity := 0.0025
@export var eye_height := 1.65
@export var acceleration := 14.0
@export var deceleration := 18.0
@export var bob_frequency := 1.15
@export var bob_amplitude := 0.012
@export var strafe_tilt := 0.012
@export var interact_distance := 2.8
@export var interact_collision_mask := 1 << 9
@export var interact_facing_threshold := 0.15
@export var interact_blocker_mask := 1
@export var interact_front_threshold := 0.35

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var post_process: ColorRect = $PostProcessLayer/PostProcess
@onready var interact_prompt: Label = $PostProcessLayer/InteractPrompt
@onready var progress_label: Label = $PostProcessLayer/ProgressLabel
@onready var subtitle_label: Label = $PostProcessLayer/SubtitleLabel
@onready var water_fill_panel: Panel = $PostProcessLayer/WaterFillPanel
@onready var water_fill_current_key: Label = $PostProcessLayer/WaterFillPanel/WaterFillCurrentKey
@onready var water_fill_progress_bar: ProgressBar = $PostProcessLayer/WaterFillPanel/WaterFillProgressBar
@onready var liminal_challenge_panel: Panel = $PostProcessLayer/LiminalChallengePanel
@onready var liminal_challenge_timer: Label = $PostProcessLayer/LiminalChallengePanel/LiminalChallengeTimer
@onready var liminal_challenge_counter: Label = $PostProcessLayer/LiminalChallengePanel/LiminalChallengeCounter
@onready var liminal_result_panel: Panel = $PostProcessLayer/LiminalResultPanel
@onready var liminal_result_title: Label = $PostProcessLayer/LiminalResultPanel/LiminalResultTitle
@onready var liminal_result_body: Label = $PostProcessLayer/LiminalResultPanel/LiminalResultBody
@onready var liminal_result_menu_button: Button = $PostProcessLayer/LiminalResultPanel/LiminalResultMenuButton

var _post_process_material: ShaderMaterial = null
var _yaw := 0.0
var _pitch := 0.0
var _bob_time := 0.0
var _head_origin := Vector3.ZERO
var _current_interactable: Node = null
var _interaction_enabled := true
var _cutscene_locked := false
var _footsteps_player: AudioStreamPlayer = null
var _subtitle_timer: SceneTreeTimer = null
var _cached_exit_door: Node = null
var _cheat_buffer := ""
var _movement_bounds_enabled := true

func _ready() -> void:
	_yaw = rotation.y
	_pitch = head.rotation.x
	_head_origin = head.position
	_setup_audio()
	_post_process_material = post_process.material as ShaderMaterial if post_process != null else null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	interact_prompt.visible = false
	subtitle_label.visible = false
	if water_fill_panel != null:
		water_fill_panel.visible = false
	if liminal_challenge_panel != null:
		liminal_challenge_panel.visible = false
	if liminal_result_panel != null:
		liminal_result_panel.visible = false
	if liminal_result_menu_button != null and not liminal_result_menu_button.pressed.is_connected(_on_liminal_result_menu_pressed):
		liminal_result_menu_button.pressed.connect(_on_liminal_result_menu_pressed)
	_update_progress_text(0, 6)

func _unhandled_input(event: InputEvent) -> void:
	_capture_cheat_code(event)

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not _cutscene_locked:
		_yaw -= event.relative.x * mouse_sensitivity
		_pitch -= event.relative.y * mouse_sensitivity
		_pitch = clamp(_pitch, deg_to_rad(-75.0), deg_to_rad(75.0))
		rotation.y = _yaw
		head.rotation.x = _pitch

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseButton and event.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("interact") and _interaction_enabled and not _cutscene_locked and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and _current_interactable != null:
		if _current_interactable.has_method("interact") and _current_interactable.interact():
			_play_interaction_click()
			_update_interaction_target()

func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if _cutscene_locked:
		input_vector = Vector2.ZERO
	var move_direction: Vector3 = (transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()
	var target_speed: float = sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	var target_velocity: Vector3 = move_direction * target_speed
	var blend: float = acceleration if input_vector.length() > 0.0 else deceleration

	velocity.x = move_toward(velocity.x, target_velocity.x, blend * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, blend * delta)

	move_and_slide()
	var horizontal_speed: float = Vector2(velocity.x, velocity.z).length()
	_update_head_motion(delta, input_vector)
	_update_footstep_audio(horizontal_speed, input_vector)
	_update_interaction_target()

	if _movement_bounds_enabled:
		position.x = clamp(position.x, -11.2, 11.2)
		position.z = clamp(position.z, -8.2, 8.2)

func _update_head_motion(delta: float, input_vector: Vector2) -> void:
	var horizontal_speed: float = Vector2(velocity.x, velocity.z).length()
	var move_ratio: float = clamp(horizontal_speed / sprint_speed, 0.0, 1.0)

	if move_ratio > 0.05:
		_bob_time += delta * horizontal_speed * bob_frequency
	else:
		_bob_time = lerp(_bob_time, 0.0, delta * 8.0)

	var bob_offset: Vector3 = Vector3.ZERO
	bob_offset.y = sin(_bob_time * TAU) * bob_amplitude * move_ratio
	bob_offset.x = cos(_bob_time * TAU * 0.5) * bob_amplitude * 0.2 * move_ratio
	head.position = _head_origin + bob_offset

	var target_roll: float = -input_vector.x * strafe_tilt * move_ratio
	camera.rotation.z = lerp(camera.rotation.z, target_roll, delta * 10.0)

func _update_interaction_target() -> void:
	if not _interaction_enabled:
		_current_interactable = null
		interact_prompt.visible = false
		return

	var eye_position := camera.global_position
	var forward := -camera.global_transform.basis.z.normalized()
	var priority_exit_door := _find_priority_exit_door(eye_position)
	if priority_exit_door != null:
		_current_interactable = priority_exit_door
		interact_prompt.visible = true
		if _current_interactable.has_method("get_prompt_text"):
			interact_prompt.text = _current_interactable.get_prompt_text()
		return

	var target_position := eye_position + (forward * interact_distance)
	var query := PhysicsRayQueryParameters3D.create(eye_position, target_position)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = interact_collision_mask

	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	var interactable: Node = null
	if not hit.is_empty():
		interactable = _find_interactable_from_node(hit.get("collider"))
		if interactable != null and interactable.has_method("can_interact_from") and not interactable.can_interact_from(eye_position):
			interactable = null
		elif interactable != null and (not _has_clear_interaction_path(interactable, eye_position) or not _is_in_front_of_terminal(interactable, eye_position)):
			interactable = null

	if interactable == null:
		interactable = _find_nearby_interactable(eye_position, forward)

	_current_interactable = interactable
	interact_prompt.visible = _current_interactable != null
	if _current_interactable != null and _current_interactable.has_method("get_prompt_text"):
		interact_prompt.text = _current_interactable.get_prompt_text()

func _find_priority_exit_door(eye_position: Vector3) -> Node:
	var direct_exit_door := _get_exit_door_node()
	if direct_exit_door != null and direct_exit_door.has_method("can_interact_from") and direct_exit_door.can_interact_from(eye_position):
		return direct_exit_door

	for candidate in get_tree().get_nodes_in_group("exit_door_interactable"):
		if not candidate.has_method("can_interact_from"):
			continue
		if candidate.can_interact_from(eye_position):
			return candidate
	return null

func _get_exit_door_node() -> Node:
	if is_instance_valid(_cached_exit_door):
		return _cached_exit_door

	_cached_exit_door = get_node_or_null("../OfficeLevel/ExitDoor")
	if is_instance_valid(_cached_exit_door):
		return _cached_exit_door

	_cached_exit_door = get_tree().get_first_node_in_group("exit_door_interactable")
	return _cached_exit_door

func _find_interactable_from_node(node: Variant) -> Node:
	if not node is Node:
		return null

	var current: Node = node
	while current != null:
		if current.is_in_group("computer_terminal") or current.is_in_group("player_interactable"):
			return current
		current = current.get_parent()

	return null

func _find_nearby_interactable(eye_position: Vector3, forward: Vector3) -> Node:
	var best_interactable: Node = null
	var best_score := -INF

	var candidates: Array[Node] = []
	for candidate in get_tree().get_nodes_in_group("computer_terminal"):
		candidates.append(candidate)
	for candidate in get_tree().get_nodes_in_group("player_interactable"):
		if not candidates.has(candidate):
			candidates.append(candidate)

	for candidate in candidates:
		if not candidate.has_method("can_interact_from") or not candidate.can_interact_from(eye_position):
			continue

		var direction_to_terminal := eye_position.direction_to(candidate.global_position)
		var facing := forward.dot(direction_to_terminal)
		if candidate.has_method("requires_facing_interaction") and not candidate.requires_facing_interaction():
			facing = max(facing, interact_facing_threshold)
		elif facing < interact_facing_threshold:
			continue

		var distance := eye_position.distance_to(candidate.global_position)
		var score := facing * 3.0 - distance
		if score > best_score and _has_clear_interaction_path(candidate, eye_position) and _is_in_front_of_terminal(candidate, eye_position):
			best_score = score
			best_interactable = candidate

	return best_interactable

func _has_clear_interaction_path(terminal: Node, eye_position: Vector3) -> bool:
	if terminal.has_method("requires_clear_interaction_path") and not terminal.requires_clear_interaction_path():
		return true

	var target: Vector3 = terminal.global_position
	if terminal.has_method("get_interaction_target_position"):
		target = terminal.get_interaction_target_position()

	var query := PhysicsRayQueryParameters3D.create(eye_position, target)
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.collision_mask = interact_blocker_mask
	query.exclude = [get_rid()]

	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return hit.is_empty()

func _is_in_front_of_terminal(terminal: Node, eye_position: Vector3) -> bool:
	if terminal.has_method("requires_front_interaction") and not terminal.requires_front_interaction():
		return true

	if not terminal.has_method("get_interaction_target_position") or not terminal.has_method("get_screen_forward"):
		return true

	var target: Vector3 = terminal.get_interaction_target_position()
	var screen_forward: Vector3 = terminal.get_screen_forward()
	var direction_to_player := target.direction_to(eye_position)
	return screen_forward.dot(direction_to_player) >= interact_front_threshold

func set_interaction_enabled(enabled: bool) -> void:
	_interaction_enabled = enabled
	if not _interaction_enabled:
		_current_interactable = null
		interact_prompt.visible = false

func set_cutscene_locked(locked: bool) -> void:
	_cutscene_locked = locked
	if locked:
		velocity = Vector3.ZERO
		_current_interactable = null
		if interact_prompt != null:
			interact_prompt.visible = false

func set_progress(current: int, total: int) -> void:
	_update_progress_text(current, total)

func set_movement_bounds_enabled(enabled: bool) -> void:
	_movement_bounds_enabled = enabled

func set_progress_visible(visible_state: bool) -> void:
	if progress_label != null:
		progress_label.visible = visible_state

func set_postprocess_enabled(enabled: bool) -> void:
	if post_process != null:
		post_process.visible = enabled

func set_postprocess_vignette_enabled(enabled: bool) -> void:
	if _post_process_material == null:
		return
	_post_process_material.set_shader_parameter(
		"vignette_strength",
		FIRST_CYCLE_VIGNETTE_STRENGTH if enabled else NON_FIRST_CYCLE_VIGNETTE_STRENGTH
	)

func reset_ui_for_liminal() -> void:
	if interact_prompt != null:
		interact_prompt.visible = false
	if progress_label != null:
		progress_label.visible = false
	if subtitle_label != null:
		subtitle_label.visible = false
		subtitle_label.text = ""
	if water_fill_panel != null:
		water_fill_panel.visible = false
	if liminal_challenge_panel != null:
		liminal_challenge_panel.visible = false
	if liminal_result_panel != null:
		liminal_result_panel.visible = false
	if post_process != null:
		post_process.visible = true

func show_subtitle(text: String, duration: float) -> void:
	if subtitle_label == null:
		return

	subtitle_label.text = text
	subtitle_label.visible = true
	_subtitle_timer = get_tree().create_timer(max(duration, 0.1))
	_subtitle_timer.timeout.connect(func() -> void:
		if subtitle_label != null and subtitle_label.text == text:
			subtitle_label.visible = false
			subtitle_label.text = ""
	)

func show_water_fill_minigame(progress: float, expecting_shift: bool) -> void:
	if water_fill_panel == null:
		return
	water_fill_panel.visible = true
	update_water_fill_minigame(progress, expecting_shift)

func update_water_fill_minigame(progress: float, expecting_shift: bool) -> void:
	if water_fill_panel == null:
		return
	water_fill_panel.visible = true
	if water_fill_progress_bar != null:
		water_fill_progress_bar.value = clamp(progress, 0.0, 1.0) * 100.0
	if water_fill_current_key != null:
		water_fill_current_key.text = "СЕЙЧАС: SHIFT" if expecting_shift else "СЕЙЧАС: ЛКМ"
		water_fill_current_key.modulate = Color(0.82, 0.92, 1.0, 1.0) if expecting_shift else Color(1.0, 0.86, 0.82, 1.0)

func hide_water_fill_minigame() -> void:
	if water_fill_panel != null:
		water_fill_panel.visible = false

func show_liminal_challenge(time_left: float, current: int, total: int) -> void:
	if liminal_challenge_panel == null:
		return
	liminal_challenge_panel.visible = true
	if liminal_result_panel != null:
		liminal_result_panel.visible = false
	update_liminal_challenge(time_left, current, total)

func update_liminal_challenge(time_left: float, current: int, total: int) -> void:
	if liminal_challenge_panel == null:
		return
	liminal_challenge_panel.visible = true
	if liminal_challenge_timer != null:
		liminal_challenge_timer.text = _format_liminal_time(time_left)
		liminal_challenge_timer.modulate = Color(1.0, 0.48, 0.44, 1.0) if time_left <= 10.0 else Color(1.0, 0.92, 0.84, 1.0)
	if liminal_challenge_counter != null:
		liminal_challenge_counter.text = "%d/%d КУЛЕРОВ" % [current, total]

func hide_liminal_challenge() -> void:
	if liminal_challenge_panel != null:
		liminal_challenge_panel.visible = false

func show_liminal_result(title: String, body: String, success: bool) -> void:
	if liminal_result_panel == null:
		return
	liminal_result_panel.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if liminal_challenge_panel != null:
		liminal_challenge_panel.visible = false
	if liminal_result_title != null:
		liminal_result_title.text = title
		liminal_result_title.modulate = Color(0.80, 1.0, 0.86, 1.0) if success else Color(1.0, 0.60, 0.56, 1.0)
	if liminal_result_body != null:
		liminal_result_body.text = body
	if liminal_result_menu_button != null:
		liminal_result_menu_button.text = "В ГЛАВНОЕ МЕНЮ"

func hide_liminal_result() -> void:
	if liminal_result_panel != null:
		liminal_result_panel.visible = false

func _on_liminal_result_menu_pressed() -> void:
	get_tree().call_group("app_shell", "return_to_main_menu")

func _update_progress_text(current: int, total: int) -> void:
	if progress_label == null:
		return
	progress_label.text = "%d/%d КОМПЬЮТЕРОВ" % [current, total]

func _format_liminal_time(time_left: float) -> String:
	var clamped_time: float = max(time_left, 0.0)
	var total_seconds := int(ceil(clamped_time))
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]

func _setup_audio() -> void:
	_footsteps_player = AudioStreamPlayer.new()
	_footsteps_player.name = "FootstepsPlayer"
	_footsteps_player.stream = _make_looping_stream(FOOTSTEPS_STREAM)
	_footsteps_player.volume_db = -6.0
	add_child(_footsteps_player)

func _make_looping_stream(stream: AudioStream) -> AudioStream:
	if stream == null:
		return null

	var duplicated: AudioStream = stream.duplicate()
	if duplicated is AudioStreamMP3:
		(duplicated as AudioStreamMP3).loop = true
	elif duplicated is AudioStreamOggVorbis:
		(duplicated as AudioStreamOggVorbis).loop = true
	elif duplicated is AudioStreamWAV:
		(duplicated as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	return duplicated

func _update_footstep_audio(horizontal_speed: float, input_vector: Vector2) -> void:
	if _footsteps_player == null:
		return

	var should_play: bool = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and input_vector.length() > 0.05 and horizontal_speed > 0.08
	if should_play:
		_footsteps_player.pitch_scale = 1.08 if Input.is_action_pressed("sprint") else 1.0
		if not _footsteps_player.playing:
			_footsteps_player.play()
	else:
		if _footsteps_player.playing:
			_footsteps_player.stop()

func _play_interaction_click() -> void:
	get_tree().call_group("game_audio_host", "play_interaction_click")

func _capture_cheat_code(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	var input_char := ""
	if key_event.unicode > 0:
		input_char = char(key_event.unicode).to_lower()

	if input_char.is_empty() or input_char.length() != 1 or input_char < "a" or input_char > "z":
		return

	_cheat_buffer += input_char
	if _cheat_buffer.length() > 5:
		_cheat_buffer = _cheat_buffer.substr(_cheat_buffer.length() - 5, 5)

	if _cheat_buffer == "solid":
		_cheat_buffer = ""
		get_tree().call_group("game_audio_host", "trigger_liminal_cheat")

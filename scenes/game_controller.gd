extends Node3D

signal loop_restart_requested

const BOSS_OFFICE_ROOM_SCENE := preload("res://scenes/boss_office_room.tscn")
const LIMINAL_SPACE_ROOM_SCENE := preload("res://scenes/liminal_space_room.tscn")
const RUNNER_WOMAN_SCENE := preload("res://scenes/runner_woman_preview.tscn")
const AMBIENT_NOISE_STREAM := preload("res://audio/ambient_noise.mp3")
const OFFICE_NOISE_STREAM := preload("res://audio/office_noise.MP3")
const CHAIR_SLIDE_STREAM := preload("res://audio/chair_slide.mp3")
const CHAIRS_SCARY_HIT_STREAM := preload("res://audio/chairs_scary_hit.mp3")
const INTERACTION_CLICK_STREAM := preload("res://audio/computer_shutdown.mp3")
const MELODY_STREAM := preload("res://audio/melody.mp3")
const LIMINAL_SOUND_STREAM := preload("res://audio/liminal_sound.MP3")
const LIMINAL_TIMER_STREAM := preload("res://audio/liminal_timer.mp3")
const RUNNER_FOOTSTEPS_STREAM := preload("res://audio/runner_footsteps.mp3")
const RUNNER_SCREAM_STREAM := preload("res://audio/runner_scream.mp3")
const SCARE_HIT_STREAM := preload("res://audio/scare_hit.mp3")
const WIN_SOUND_STREAM := preload("res://audio/win_sound.mp3")
const WHISPER_STREAM := preload("res://audio/whisper.MP3")
const PLAYER_EVENT_2_STREAM := preload("res://audio/voice/player_event_2.mp3")
const PLAYER_EVENT_3_STREAM := preload("res://audio/voice/player_event_3.mp3")
const PLAYER_EVENT_4_STREAM := preload("res://audio/voice/player_event_4.mp3")
const PLAYER_EVENT_5_STREAM := preload("res://audio/voice/player_event_5.mp3")
const PLAYER_EVENT_6_STREAM := preload("res://audio/voice/player_event_6.mp3")
const PLAYER_CYCLE2_1_STREAM := preload("res://audio/voice/second_cycle/player_cycle2_1.mp3")
const PLAYER_CYCLE2_2_STREAM := preload("res://audio/voice/second_cycle/player_cycle2_2.mp3")
const PLAYER_CYCLE2_3_STREAM := preload("res://audio/voice/second_cycle/player_cycle2_3.mp3")
const PLAYER_CYCLE2_4_STREAM := preload("res://audio/voice/second_cycle/player_cycle2_4.mp3")
const LIMINAL_SPAWN_STREAM := preload("res://audio/voice/liminal/spawn.mp3")
const LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS := [
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_1.mp3",
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_2.mp3",
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_3.mp3",
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_4.mp3",
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_5.mp3",
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_6.mp3",
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_7.mp3",
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_8.mp3",
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_9.mp3",
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_10.mp3",
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_11.mp3",
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_12.mp3",
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_13.mp3",
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_14.mp3",
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_15.mp3",
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_16.mp3",
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_17.mp3",
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_18.mp3",
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_19.mp3",
	"res://audio/voice/liminal_boss_dialogue/liminal_boss_dialogue_20.mp3",
]
const BOSS_DIALOGUE_AUDIO_PATHS := [
	"res://audio/voice/boss_dialogue/boss_dialogue_1.mp3",
	"res://audio/voice/boss_dialogue/boss_dialogue_2.mp3",
	"res://audio/voice/boss_dialogue/boss_dialogue_3.mp3",
	"res://audio/voice/boss_dialogue/boss_dialogue_4.mp3",
	"res://audio/voice/boss_dialogue/boss_dialogue_5.mp3",
	"res://audio/voice/boss_dialogue/boss_dialogue_6.mp3",
	"res://audio/voice/boss_dialogue/boss_dialogue_7.mp3",
	"res://audio/voice/boss_dialogue/boss_dialogue_8.mp3",
]
const PLAYER_EVENT_VOICE_DELAY := 1.0
const SECOND_CYCLE_INTRO_DELAY := 1.0
const BOSS_DIALOGUE_LINE_GAP := 0.12
const WATER_FILL_START_DELAY := 0.2
const WATER_FILL_GAIN_SLOW := 0.051
const WATER_FILL_GAIN_FAST := 0.097
const WATER_FILL_DECAY := 0.315
const WATER_FILL_IDLE_DECAY := 0.84
const WATER_FILL_TEMPO_WINDOW := 0.245
const WATER_FILL_WRONG_INPUT_PENALTY := 0.18
const WATER_FILL_SUCCESS_PAUSE := 0.35
const LIMINAL_SPAWN_VOICE_DELAY := 1.0
const LIMINAL_CHALLENGE_DURATION := 50.0
const LIMINAL_CHALLENGE_TOTAL_COOLERS := 3
const LIMINAL_RUNNER_SPEED := 6.2
const LIMINAL_RUNNER_TARGET_REACHED_DISTANCE := 1.6
const LIMINAL_RUNNER_COOLER_OFFSET := 4.0

const THIRD_SHUTDOWN_BLACKOUT_DURATION := 1.0
const THIRD_SHUTDOWN_CHAOS_DURATION := 2.0
const THIRD_SHUTDOWN_FINAL_BLACKOUT_DURATION := 0.35
const CHAIR_CEILING_HEIGHT := 3.18
const FOURTH_SHUTDOWN_SPAWN_DELAY := 0.12
const FOURTH_SHUTDOWN_RUN_DURATION := 4.2
const RUNNER_ANIMATION_NAME := "Armature|running"
const RUNNER_ANIMATION_SPEED := 0.42
const RUNNER_PATH_START := Vector3(0.0, 0.0, 8.8)
const RUNNER_PATH_END := Vector3(0.0, 0.0, -8.8)
const RUNNER_PLAYER_OFFSET := 0.0
const RUNNER_CHASE_SPEED := 4.2
const RUNNER_MAX_CHASE_TIME := 6.0
const RUNNER_COLLISION_RADIUS := 0.24
const RUNNER_COLLISION_HEIGHT := 1.8
const RUNNER_CONTACT_DISTANCE := 1.35
const RUNNER_MIN_CHASE_TIME := 2.4
const RUNNER_MIN_CHASE_DISTANCE := 4.5
const RUNNER_X_LANES: Array[float] = [-9.6, -4.8, 0.0, 4.8, 9.6]
const RUNNER_ROW_ENTRY_Z_LANES: Array[float] = [-8.2, -3.2, 1.8, 6.8]
const CUBICLE_CENTER_XS: Array[float] = [-7.2, -2.4, 2.4, 7.2]
const CUBICLE_CENTER_ZS: Array[float] = [-5.0, 0.0, 5.0]
const CUBICLE_HALF_EXTENT := 1.55
const CUBICLE_ENTRY_OFFSET_Z := 2.05
const SIXTH_SHUTDOWN_INTERIOR_HIDE_NODES := ["SunPivot", "HallRunner", "CubicleGrid", "OfficeProps"]
const SIXTH_SHUTDOWN_FADE_DURATION := 0.8
const SECOND_CYCLE_HIDE_NODE_PATHS := [
	"OfficeLevel/CubicleGrid/Cubicle02/Desk",
	"OfficeLevel/CubicleGrid/Cubicle02/Chair",
	"OfficeLevel/CubicleGrid/Cubicle05/Desk",
	"OfficeLevel/CubicleGrid/Cubicle05/Chair",
	"OfficeLevel/CubicleGrid/Cubicle06/Desk",
	"OfficeLevel/CubicleGrid/Cubicle06/Chair",
]
const OFFICE_WORKER_ANIMATION_BY_NAME := {
	"OfficeWorker01": "OW_1",
	"OfficeWorker02": "OW_2",
	"OfficeWorker03": "typing",
	"OfficeWorker04": "idle",
}

@onready var office: Node3D = $OfficeLevel
@onready var player: Node = $Player
@onready var world_environment: WorldEnvironment = $OfficeLevel/WorldEnvironment
@onready var exit_door: Node3D = $OfficeLevel/ExitDoor
@onready var office_workers: Node3D = $OfficeLevel/OfficeProps/OfficeWorkers
@onready var exit_door_sign: Label3D = $OfficeLevel/ExitDoor/ExitDoorSign

var _terminals: Array[Node] = []
var _lights: Array[SpotLight3D] = []
var _chairs: Array[Dictionary] = []
var _sequence_running := false
var _chair_chaos_active := false
var _chair_chaos_time := 0.0
var _environment_state: Dictionary = {}
var _light_states: Array[Dictionary] = []
var _runner_woman: Node3D = null
var _runner_route: Array[Vector3] = []
var _fade_rect: ColorRect = null
var _ambient_player: AudioStreamPlayer = null
var _office_noise_player: AudioStreamPlayer = null
var _chair_slide_player: AudioStreamPlayer = null
var _chairs_scary_hit_player: AudioStreamPlayer = null
var _interaction_click_player: AudioStreamPlayer = null
var _melody_player: AudioStreamPlayer = null
var _liminal_sound_player: AudioStreamPlayer = null
var _liminal_timer_player: AudioStreamPlayer = null
var _runner_footsteps_player: AudioStreamPlayer = null
var _runner_scream_player: AudioStreamPlayer = null
var _scare_hit_player: AudioStreamPlayer = null
var _win_sound_player: AudioStreamPlayer = null
var _whisper_player: AudioStreamPlayer = null
var _player_event_voice_player: AudioStreamPlayer = null
var _second_cycle_intro_player: AudioStreamPlayer = null
var _boss_dialogue_player: AudioStreamPlayer = null
var _player_event_voice_streams := {}
var _player_event_subtitles := {}
var _second_cycle_intro_lines := []
var _boss_dialogue_lines := []
var _liminal_boss_dialogue_lines := []
var _second_cycle_intro_started := false
var _boss_room: Node3D = null
var _boss_room_spawn: Marker3D = null
var _boss_talk_trigger: Node3D = null
var _boss_cutscene_camera: Camera3D = null
var _office_environment_resource: Environment = null
var _boss_environment_resource: Environment = null
var _liminal_environment_resource: Environment = null
var _boss_dialogue_running := false
var _boss_dialogue_completed := false
var _liminal_boss_dialogue_running := false
var _liminal_boss_dialogue_completed := false
var _boss_coolers: Array[Node3D] = []
var _liminal_room: Node3D = null
var _liminal_room_spawn: Marker3D = null
var _liminal_boss_talk_trigger: Node3D = null
var _liminal_boss_cutscene_camera: Camera3D = null
var _liminal_boss: Node3D = null
var _liminal_boss_rest_transform := Transform3D.IDENTITY
var _liminal_coolers: Array[Node3D] = []
var _liminal_challenge_active := false
var _liminal_challenge_completed := false
var _liminal_time_left := 0.0
var _liminal_coolers_disabled := 0
var _liminal_runner_woman: CharacterBody3D = null
var _liminal_runner_target: Vector3 = Vector3.ZERO
var _liminal_runner_target_index := -1
var _water_fill_active := false
var _water_fill_completed := false
var _water_fill_progress := 0.0
var _water_fill_expect_shift := true
var _water_fill_last_input_time := -1.0

func _ready() -> void:
	add_to_group("game_audio_host")
	_office_environment_resource = world_environment.environment
	_player_event_voice_streams = {
		2: PLAYER_EVENT_2_STREAM,
		3: PLAYER_EVENT_3_STREAM,
		4: PLAYER_EVENT_4_STREAM,
		5: PLAYER_EVENT_5_STREAM,
		6: PLAYER_EVENT_6_STREAM
	}
	_player_event_subtitles = {
		2: "Стажер: Здесь что-то происходит...",
		3: "Стажер: Мне стоило выпить таблетки...",
		4: "Стажер: Я слишком давно не спал...",
		5: "Стажер: Спокойно, это просто усталость...",
		6: "Стажер: Мне это не кажется, я точно это видел"
	}
	_second_cycle_intro_lines = [
		{"stream": PLAYER_CYCLE2_1_STREAM, "subtitle": "Стажер: ...Что?"},
		{"stream": PLAYER_CYCLE2_2_STREAM, "subtitle": "Стажер: Я снова здесь???"},
		{"stream": PLAYER_CYCLE2_3_STREAM, "subtitle": "Стажер: Нет... Этого не может быть"},
		{"stream": PLAYER_CYCLE2_4_STREAM, "subtitle": "Стажер: Мне нужно зайти к боссу"},
	]
	_boss_dialogue_lines = [
		{"path": BOSS_DIALOGUE_AUDIO_PATHS[0], "subtitle": "Босс: Стажер.. Ты снова меня подводишь", "duration": 2.4},
		{"path": BOSS_DIALOGUE_AUDIO_PATHS[1], "subtitle": "Босс: Я поручил тебе выключить компьютеры", "duration": 2.5},
		{"path": BOSS_DIALOGUE_AUDIO_PATHS[2], "subtitle": "Босс: Почему сегодня утром они все еще работали?", "duration": 2.9},
		{"path": BOSS_DIALOGUE_AUDIO_PATHS[3], "subtitle": "Стажер: Но я... Я точно помню что все выключил", "duration": 2.7},
		{"path": BOSS_DIALOGUE_AUDIO_PATHS[4], "subtitle": "Босс: Хватит, мне не нужны оправдания", "duration": 2.5},
		{"path": BOSS_DIALOGUE_AUDIO_PATHS[5], "subtitle": "Босс: Еще раз оступишься - вылетишь отсюда!", "duration": 2.7},
		{"path": BOSS_DIALOGUE_AUDIO_PATHS[6], "subtitle": "Босс: А теперь принеси мне воды. Быстро!", "duration": 2.4},
		{"path": BOSS_DIALOGUE_AUDIO_PATHS[7], "subtitle": "Стажер: ...Хорошо", "duration": 1.4},
	]
	_liminal_boss_dialogue_lines = [
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[0], "subtitle": "Стажёр: Босс?.. Я ничего не понимаю.", "duration": 2.4},
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[1], "subtitle": "Босс: Я был на твоём месте.", "duration": 2.2},
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[2], "subtitle": "Босс: Они заметили меня.", "duration": 2.0},
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[3], "subtitle": "Босс: Теперь заметили и тебя.", "duration": 2.2},
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[4], "subtitle": "Стажёр: Кто “они”?..", "duration": 1.8},
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[5], "subtitle": "Босс: Те, из которых все мы пьем воду.", "duration": 2.8},
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[6], "subtitle": "Стажёр: ...Что? Кулеры?", "duration": 2.0},
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[7], "subtitle": "Босс: Они самые.", "duration": 1.7},
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[8], "subtitle": "Босс: Это не просто кулеры.", "duration": 2.0},
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[9], "subtitle": "Босс: Сначала через воду они пускают галлюцинации в наше сознание.", "duration": 4.6},
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[10], "subtitle": "Босс: А потом мы оказываемся здесь.", "duration": 2.4},
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[11], "subtitle": "Стажёр: И как всё это остановить?", "duration": 2.2},
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[12], "subtitle": "Босс: В этом слое спрятаны три главных кулера.", "duration": 3.1},
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[13], "subtitle": "Босс: Они не похожи на обычные. Они чёрные.", "duration": 3.0},
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[14], "subtitle": "Босс: Пока они работают, выхода не будет.", "duration": 2.7},
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[15], "subtitle": "Босс: Отключи все три. И сделай это быстро.", "duration": 2.9},
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[16], "subtitle": "Босс: Я пытался это сделать, но слишком долго тянул...", "duration": 3.2},
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[17], "subtitle": "Босс: И теперь не могу уйти...", "duration": 2.4},
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[18], "subtitle": "Босс: Ищи кулеры!", "duration": 1.8},
		{"path": LIMINAL_BOSS_DIALOGUE_AUDIO_PATHS[19], "subtitle": "Босс: Пока это место и тебя здесь не оставило.", "duration": 3.0},
	]
	get_tree().set_meta("powered_off_terminals", 0)
	get_tree().set_meta("reserved_power_off_terminals", 0)
	get_tree().set_meta("pending_fifth_terminal_id", -1)
	_setup_audio()
	_apply_cycle_state()
	_cache_environment_state()
	_cache_light_states()
	_cache_chair_states()
	_connect_terminals()
	_setup_boss_room()
	_setup_liminal_room()
	_prepare_exit_door()
	_ensure_fade_rect()
	_update_player_progress(0)
	_play_looped(_ambient_player)

func _apply_cycle_state() -> void:
	var loop_cycle_index := int(get_tree().get_meta("loop_cycle_index", 1))
	_apply_active_environment(_office_environment_resource)
	if office_workers != null:
		_set_node3d_visible_with_collisions(office_workers, loop_cycle_index >= 2)
		if loop_cycle_index >= 2:
			_play_office_worker_animations()
	if exit_door_sign != null:
		exit_door_sign.text = "БОСС" if loop_cycle_index >= 2 else "ВЫХОДА НЕТ"
	if exit_door != null:
		exit_door.visible = loop_cycle_index >= 2
		exit_door.prompt_text = "E - зайти к боссу" if loop_cycle_index >= 2 else "E - открыть дверь"
		if exit_door.has_method("set_interactable_enabled"):
			exit_door.set_interactable_enabled(loop_cycle_index >= 2)
	if player != null and player.has_method("set_progress_visible"):
		player.set_progress_visible(loop_cycle_index < 2)
	if player != null and player.has_method("set_postprocess_enabled"):
		player.set_postprocess_enabled(true)
	if player != null and player.has_method("set_postprocess_vignette_enabled"):
		player.set_postprocess_vignette_enabled(loop_cycle_index < 2)
	_apply_second_cycle_cubicle_overrides(loop_cycle_index >= 2)
	if _office_noise_player != null:
		if loop_cycle_index >= 2:
			_office_noise_player.volume_db = -14.0
			_play_looped(_office_noise_player)
		else:
			_stop_player(_office_noise_player)
	if loop_cycle_index == 2 and not _second_cycle_intro_started:
		_second_cycle_intro_started = true
		call_deferred("_start_second_cycle_intro_sequence")

func _apply_second_cycle_cubicle_overrides(enabled: bool) -> void:
	for node_path in SECOND_CYCLE_HIDE_NODE_PATHS:
		var node := get_node_or_null(NodePath(node_path))
		if node is Node3D:
			_set_node3d_visible_with_collisions(node as Node3D, not enabled)

func _set_node3d_visible_with_collisions(root: Node3D, visible_state: bool) -> void:
	root.visible = visible_state
	for child in root.find_children("*", "CollisionShape3D", true, false):
		var collision_shape := child as CollisionShape3D
		if collision_shape != null:
			collision_shape.disabled = not visible_state
	for child in root.find_children("*", "CollisionPolygon3D", true, false):
		var collision_polygon := child as CollisionPolygon3D
		if collision_polygon != null:
			collision_polygon.disabled = not visible_state

func _play_office_worker_animations() -> void:
	if office_workers == null:
		return
	for worker in office_workers.get_children():
		var worker_node := worker as Node
		if worker_node == null:
			continue
		var animation_player := worker_node.find_child("AnimationPlayer", true, false) as AnimationPlayer
		if animation_player == null:
			continue
		var animation_name := OFFICE_WORKER_ANIMATION_BY_NAME.get(worker_node.name, "") as String
		if animation_name.is_empty() or not animation_player.has_animation(animation_name):
			for candidate in animation_player.get_animation_list():
				var candidate_name := String(candidate)
				if candidate_name.to_lower() != "t-pose":
					animation_name = candidate_name
					break
		if animation_name.is_empty():
			continue
		var animation := animation_player.get_animation(animation_name)
		if animation != null:
			animation.loop_mode = Animation.LOOP_LINEAR
		animation_player.play(animation_name)

func _start_second_cycle_intro_sequence() -> void:
	await get_tree().create_timer(SECOND_CYCLE_INTRO_DELAY).timeout
	for line_data in _second_cycle_intro_lines:
		var stream := line_data.get("stream") as AudioStream
		var subtitle := line_data.get("subtitle", "") as String
		if stream == null or _second_cycle_intro_player == null:
			continue
		_second_cycle_intro_player.stream = stream
		if player != null and player.has_method("show_subtitle") and not subtitle.is_empty():
			player.show_subtitle(subtitle, stream.get_length())
		_play_one_shot(_second_cycle_intro_player)
		await _second_cycle_intro_player.finished

func _process(delta: float) -> void:
	if _chair_chaos_active:
		_chair_chaos_time += delta
		for chair_state in _chairs:
			var chair := chair_state["node"] as Node3D
			if chair == null:
				continue

			var phase: float = chair_state["phase"]
			var anchor: Vector3 = chair_state["ceiling_anchor"]
			var original_rotation: Vector3 = chair_state["rotation"]
			var drift_x: float = chair_state["drift_x"]
			var drift_z: float = chair_state["drift_z"]
			var bob_amplitude: float = chair_state["bob_amplitude"]
			var orbit_speed_x: float = chair_state["orbit_speed_x"]
			var orbit_speed_z: float = chair_state["orbit_speed_z"]
			var bob_speed: float = chair_state["bob_speed"]
			var spin_speed: float = chair_state["spin_speed"]
			var roll_amplitude: float = chair_state["roll_amplitude"]
			var yaw_offset: float = chair_state["yaw_offset"]
			var sway_mix: float = chair_state["sway_mix"]

			chair.position = Vector3(
				anchor.x + sin(_chair_chaos_time * orbit_speed_x + phase) * drift_x + cos(_chair_chaos_time * (orbit_speed_z * 0.7) + phase * 0.5) * drift_x * sway_mix,
				anchor.y + sin(_chair_chaos_time * bob_speed + phase * 1.7) * bob_amplitude,
				anchor.z + cos(_chair_chaos_time * orbit_speed_z + phase) * drift_z + sin(_chair_chaos_time * (orbit_speed_x * 0.6) + phase * 0.3) * drift_z * (1.0 - sway_mix) * 0.65
			)
			chair.rotation_degrees = Vector3(
				180.0 + sin(_chair_chaos_time * (bob_speed * 0.45) + phase) * 6.0,
				original_rotation.y + yaw_offset + (_chair_chaos_time * spin_speed),
				sin(_chair_chaos_time * (orbit_speed_x * 1.1) + phase) * roll_amplitude
			)

	if _water_fill_active:
		_process_water_fill(delta)

	if _liminal_challenge_active:
		_process_liminal_challenge(delta)
		_process_liminal_runner(delta)

func _unhandled_input(event: InputEvent) -> void:
	if not _water_fill_active:
		return
	if event.is_echo():
		return

	if event.is_action_pressed("sprint"):
		_handle_water_fill_input(true)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_water_fill_input(false)
		get_viewport().set_input_as_handled()

func _connect_terminals() -> void:
	_terminals = get_tree().get_nodes_in_group("computer_terminal")
	for terminal in _terminals:
		if terminal.has_signal("power_off_completed"):
			var callable := Callable(self, "_on_terminal_power_off_completed")
			if not terminal.is_connected("power_off_completed", callable):
				terminal.connect("power_off_completed", callable)

func _on_terminal_power_off_completed(power_off_count: int, _terminal: Node3D) -> void:
	_update_player_progress(power_off_count)
	if power_off_count == 3 and not _sequence_running:
		_run_third_shutdown_sequence()
	elif power_off_count == 4 and not _sequence_running:
		_run_fourth_shutdown_sequence()
	elif power_off_count == 6 and not _sequence_running:
		_run_sixth_shutdown_sequence()
	elif power_off_count == 2 or power_off_count == 5:
		queue_player_event_voice(power_off_count)

func _run_third_shutdown_sequence() -> void:
	_sequence_running = true
	_set_player_interaction_enabled(false)
	_set_all_terminal_displays_visible(false)
	_apply_blackout_lighting()
	_play_one_shot(_chairs_scary_hit_player)

	await get_tree().create_timer(THIRD_SHUTDOWN_BLACKOUT_DURATION).timeout

	_activate_chair_chaos()
	_restore_environment_state()
	_restore_light_states()

	await get_tree().create_timer(THIRD_SHUTDOWN_CHAOS_DURATION).timeout

	_apply_blackout_lighting()
	_deactivate_chair_chaos()

	await get_tree().create_timer(THIRD_SHUTDOWN_FINAL_BLACKOUT_DURATION).timeout

	_restore_environment_state()
	_restore_light_states()
	_set_all_terminal_displays_visible(true)
	_set_player_interaction_enabled(true)
	queue_player_event_voice(3)
	_sequence_running = false

func _run_fourth_shutdown_sequence() -> void:
	_sequence_running = true
	_set_player_interaction_enabled(false)

	await get_tree().create_timer(FOURTH_SHUTDOWN_SPAWN_DELAY).timeout

	var runner := _spawn_runner_woman()
	if runner != null:
		var runner_model := runner.find_child("RunnerModel", true, false) as Node3D
		if runner_model != null:
			_play_runner_animation(runner_model)
		_play_looped(_runner_footsteps_player)
		var reached_player: bool = await _animate_runner_woman(runner)
		_stop_player(_runner_footsteps_player)
		if reached_player:
			_play_one_shot(_runner_scream_player)
	_clear_runner_woman()

	_set_player_interaction_enabled(true)
	queue_player_event_voice(4)
	_sequence_running = false

func _run_sixth_shutdown_sequence() -> void:
	_sequence_running = true
	_set_player_interaction_enabled(false)
	_clear_runner_woman()
	_deactivate_chair_chaos()
	_hide_office_interior()
	_play_one_shot(_melody_player)
	_prepare_exit_door()
	if exit_door != null:
		exit_door.visible = true
	if exit_door != null and exit_door.has_method("set_interactable_enabled"):
		exit_door.set_interactable_enabled(true)
	_set_player_interaction_enabled(true)
	queue_player_event_voice(6)
	_sequence_running = false

func _cache_environment_state() -> void:
	var environment := world_environment.environment
	_environment_state = {
		"background_color": environment.background_color,
		"ambient_light_color": environment.ambient_light_color,
		"ambient_light_energy": environment.ambient_light_energy,
		"fog_enabled": environment.fog_enabled,
		"fog_light_color": environment.fog_light_color,
		"fog_density": environment.fog_density
	}

func _cache_light_states() -> void:
	_lights.clear()
	_light_states.clear()

	for node in office.find_children("*", "SpotLight3D", true, false):
		var light := node as SpotLight3D
		if light == null:
			continue
		_lights.append(light)
		_light_states.append({
			"node": light,
			"energy": light.light_energy,
			"color": light.light_color
		})

func _cache_chair_states() -> void:
	_chairs.clear()

	for node in office.find_children("Chair", "Node3D", true, false):
		var chair := node as Node3D
		if chair == null:
			continue

		var phase := randf() * TAU
		_chairs.append({
			"node": chair,
			"position": chair.position,
			"rotation": chair.rotation_degrees,
			"phase": phase,
			"ceiling_anchor": Vector3(chair.position.x, CHAIR_CEILING_HEIGHT, chair.position.z),
			"drift_x": randf_range(0.38, 0.95),
			"drift_z": randf_range(0.24, 0.82),
			"bob_amplitude": randf_range(0.015, 0.085),
			"orbit_speed_x": randf_range(5.5, 10.8),
			"orbit_speed_z": randf_range(4.8, 9.1),
			"bob_speed": randf_range(9.5, 18.0),
			"spin_speed": randf_range(140.0, 320.0),
			"roll_amplitude": randf_range(8.0, 24.0),
			"yaw_offset": randf_range(-35.0, 35.0),
			"sway_mix": randf_range(0.15, 0.55)
		})

func _apply_blackout_lighting() -> void:
	var environment := world_environment.environment
	environment.background_color = Color.BLACK
	environment.ambient_light_color = Color.BLACK
	environment.ambient_light_energy = 0.0
	environment.fog_density = 0.0
	environment.fog_enabled = false

	for light in _lights:
		light.light_energy = 0.0

func _restore_environment_state() -> void:
	var environment := world_environment.environment
	environment.background_color = _environment_state["background_color"]
	environment.ambient_light_color = _environment_state["ambient_light_color"]
	environment.ambient_light_energy = _environment_state["ambient_light_energy"]
	environment.fog_enabled = _environment_state["fog_enabled"]
	environment.fog_light_color = _environment_state["fog_light_color"]
	environment.fog_density = _environment_state["fog_density"]

func _restore_light_states() -> void:
	for light_state in _light_states:
		var light := light_state["node"] as SpotLight3D
		if light == null:
			continue
		light.light_energy = light_state["energy"]
		light.light_color = light_state["color"]

func _activate_chair_chaos() -> void:
	_chair_chaos_time = 0.0
	_chair_chaos_active = true
	_play_looped(_chair_slide_player)
	for chair_state in _chairs:
		var chair := chair_state["node"] as Node3D
		if chair == null:
			continue
		var anchor: Vector3 = chair_state["ceiling_anchor"]
		var original_rotation: Vector3 = chair_state["rotation"]
		chair.position = anchor
		chair.rotation_degrees = Vector3(180.0, original_rotation.y, 0.0)

func _deactivate_chair_chaos() -> void:
	_chair_chaos_active = false
	_stop_player(_chair_slide_player)
	for chair_state in _chairs:
		var chair := chair_state["node"] as Node3D
		if chair == null:
			continue
		chair.position = chair_state["position"]
		chair.rotation_degrees = chair_state["rotation"]

func _set_all_terminal_displays_visible(visible_state: bool) -> void:
	for terminal in _terminals:
		if terminal.has_method("set_display_visible"):
			terminal.set_display_visible(visible_state)

func _set_player_interaction_enabled(enabled: bool) -> void:
	if player != null and player.has_method("set_interaction_enabled"):
		player.set_interaction_enabled(enabled)

func _prepare_exit_door() -> void:
	if exit_door == null:
		return
	var callable := Callable(self, "_on_exit_door_opened")
	if exit_door.has_signal("opened") and not exit_door.is_connected("opened", callable):
		exit_door.connect("opened", callable)
	var loop_cycle_index := int(get_tree().get_meta("loop_cycle_index", 1))
	if exit_door.has_method("set_interactable_enabled"):
		exit_door.set_interactable_enabled(loop_cycle_index >= 2)

func _setup_boss_room() -> void:
	if BOSS_OFFICE_ROOM_SCENE == null or _boss_room != null:
		return
	_boss_room = BOSS_OFFICE_ROOM_SCENE.instantiate() as Node3D
	if _boss_room == null:
		return
	_boss_room.name = "BossOfficeRoom"
	add_child(_boss_room)
	_set_node3d_visible_with_collisions(_boss_room, false)
	var boss_world_environment := _boss_room.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if boss_world_environment != null:
		_boss_environment_resource = boss_world_environment.environment
		boss_world_environment.environment = null
	_boss_room_spawn = _boss_room.get_node_or_null("PlayerSpawn") as Marker3D
	_boss_talk_trigger = _boss_room.get_node_or_null("BossTalkTrigger") as Node3D
	_boss_cutscene_camera = _boss_room.get_node_or_null("BossCutsceneCamera") as Camera3D
	_boss_coolers.clear()
	if _boss_talk_trigger != null:
		var talk_callable := Callable(self, "_on_boss_talk_requested")
		if _boss_talk_trigger.has_signal("talk_requested") and not _boss_talk_trigger.is_connected("talk_requested", talk_callable):
			_boss_talk_trigger.connect("talk_requested", talk_callable)
	for cooler_name in ["Cooler01", "Cooler02", "Cooler03"]:
		var cooler := _boss_room.get_node_or_null(NodePath(cooler_name)) as Node3D
		if cooler == null:
			continue
		_boss_coolers.append(cooler)
		var fill_callable := Callable(self, "_on_boss_cooler_requested")
		if cooler.has_signal("fill_requested") and not cooler.is_connected("fill_requested", fill_callable):
			cooler.connect("fill_requested", fill_callable)
		if cooler.has_method("set_interaction_locked"):
			cooler.set_interaction_locked(true)
	_set_boss_rest_pose()

func _setup_liminal_room() -> void:
	if LIMINAL_SPACE_ROOM_SCENE == null or _liminal_room != null:
		return
	_liminal_room = LIMINAL_SPACE_ROOM_SCENE.instantiate() as Node3D
	if _liminal_room == null:
		return
	_liminal_room.name = "LiminalSpaceRoom"
	add_child(_liminal_room)
	_set_node3d_visible_with_collisions(_liminal_room, false)
	var liminal_world_environment := _liminal_room.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if liminal_world_environment != null:
		_liminal_environment_resource = liminal_world_environment.environment
		liminal_world_environment.environment = null
	_liminal_room_spawn = _liminal_room.get_node_or_null("PlayerSpawn") as Marker3D
	_liminal_boss = _liminal_room.get_node_or_null("LiminalBoss") as Node3D
	if _liminal_boss != null:
		_liminal_boss_rest_transform = _liminal_boss.transform
	_liminal_boss_talk_trigger = _liminal_room.get_node_or_null("LiminalBossTalkTrigger") as Node3D
	_liminal_boss_cutscene_camera = _liminal_room.get_node_or_null("LiminalBossCutsceneCamera") as Camera3D
	if _liminal_boss_talk_trigger != null:
		var talk_callable := Callable(self, "_on_liminal_boss_talk_requested")
		if _liminal_boss_talk_trigger.has_signal("talk_requested") and not _liminal_boss_talk_trigger.is_connected("talk_requested", talk_callable):
			_liminal_boss_talk_trigger.connect("talk_requested", talk_callable)
	_liminal_coolers.clear()
	for cooler_name in ["LiminalBlackCooler", "LiminalBlackCooler2", "LiminalBlackCooler3"]:
		var cooler := _liminal_room.get_node_or_null(NodePath(cooler_name)) as Node3D
		if cooler == null:
			continue
		_liminal_coolers.append(cooler)
		var shutdown_callable := Callable(self, "_on_liminal_cooler_shutdown_requested")
		if cooler.has_signal("shutdown_requested") and not cooler.is_connected("shutdown_requested", shutdown_callable):
			cooler.connect("shutdown_requested", shutdown_callable)
		if cooler.has_method("set_interaction_locked"):
			cooler.set_interaction_locked(true)
	_build_liminal_collisions()
	_hide_node3d_with_collisions(_liminal_room)

func _apply_active_environment(environment_resource: Environment) -> void:
	if world_environment == null or environment_resource == null:
		return
	world_environment.environment = environment_resource

func _build_liminal_collisions() -> void:
	if _liminal_room == null:
		return
	var liminal_geometry := _liminal_room.get_node_or_null("LiminalSpace") as Node3D
	if liminal_geometry == null:
		return
	for mesh_instance in liminal_geometry.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := mesh_instance as MeshInstance3D
		if mesh_node == null or mesh_node.mesh == null:
			continue
		var existing := mesh_node.get_node_or_null("AutoCollider") as StaticBody3D
		if existing != null:
			existing.queue_free()
		var shape := mesh_node.mesh.create_trimesh_shape()
		if shape == null:
			continue
		var body := StaticBody3D.new()
		body.name = "AutoCollider"
		mesh_node.add_child(body)
		body.owner = _liminal_room
		var collision_shape := CollisionShape3D.new()
		collision_shape.shape = shape
		body.add_child(collision_shape)
		collision_shape.owner = _liminal_room
		collision_shape.disabled = true

func _ensure_fade_rect() -> void:
	if player == null:
		return
	var layer := player.get_node_or_null("PostProcessLayer") as CanvasLayer
	if layer == null:
		return
	_fade_rect = layer.get_node_or_null("FadeRect") as ColorRect
	if _fade_rect != null:
		return

	_fade_rect = ColorRect.new()
	_fade_rect.name = "FadeRect"
	_fade_rect.anchors_preset = Control.PRESET_FULL_RECT
	_fade_rect.anchor_right = 1.0
	_fade_rect.anchor_bottom = 1.0
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.color = Color(0, 0, 0, 0)
	layer.add_child(_fade_rect)

func _hide_office_interior() -> void:
	for node_name in SIXTH_SHUTDOWN_INTERIOR_HIDE_NODES:
		var node := office.get_node_or_null(NodePath(node_name))
		if node is Node3D:
			_hide_node3d_with_collisions(node as Node3D)

func _hide_node3d_with_collisions(root: Node3D) -> void:
	root.visible = false
	for child in root.find_children("*", "CollisionShape3D", true, false):
		var collision_shape := child as CollisionShape3D
		if collision_shape != null:
			collision_shape.disabled = true
	for child in root.find_children("*", "CollisionPolygon3D", true, false):
		var collision_polygon := child as CollisionPolygon3D
		if collision_polygon != null:
			collision_polygon.disabled = true

func _on_exit_door_opened() -> void:
	var loop_cycle_index := int(get_tree().get_meta("loop_cycle_index", 1))
	if loop_cycle_index >= 2:
		await _enter_boss_room()
		return
	_set_player_interaction_enabled(false)
	if exit_door != null and exit_door.has_method("set_interaction_locked"):
		exit_door.set_interaction_locked(true)
	await _play_fade_out()
	loop_restart_requested.emit()

func trigger_boss_room_cheat() -> void:
	if _boss_dialogue_running or _water_fill_active:
		return
	if _boss_room != null and _boss_room.visible:
		return
	call_deferred("_run_boss_room_cheat")

func _run_boss_room_cheat() -> void:
	await _enter_boss_room()

func trigger_liminal_cheat() -> void:
	if _boss_dialogue_running or _water_fill_active:
		return
	if _liminal_room != null and _liminal_room.visible:
		return
	call_deferred("_run_liminal_cheat")

func _run_liminal_cheat() -> void:
	await _enter_liminal_space()

func _enter_boss_room() -> void:
	_set_player_interaction_enabled(false)
	if player != null and player.has_method("set_movement_bounds_enabled"):
		player.set_movement_bounds_enabled(false)
	if exit_door != null and exit_door.has_method("set_interaction_locked"):
		exit_door.set_interaction_locked(true)
	await _fade_out_audio_player(_office_noise_player, 0.6)
	await _play_fade_out()
	_hide_node3d_with_collisions(office)
	if _boss_room != null:
		_set_node3d_visible_with_collisions(_boss_room, true)
		_apply_active_environment(_boss_environment_resource)
		_set_boss_rest_pose()
		if _boss_talk_trigger != null and _boss_talk_trigger.has_method("set_interaction_locked"):
			_boss_talk_trigger.set_interaction_locked(false)
		_set_boss_coolers_interaction_locked(true)
	if player is Node3D and _boss_room_spawn != null:
		(player as Node3D).global_position = _boss_room_spawn.global_position
	await _play_fade_in()
	_set_player_interaction_enabled(true)

func _on_boss_talk_requested() -> void:
	if _boss_dialogue_running or _boss_dialogue_completed:
		return
	_boss_dialogue_running = true

	if _boss_talk_trigger != null and _boss_talk_trigger.has_method("set_interaction_locked"):
		_boss_talk_trigger.set_interaction_locked(true)
	if player != null and player.has_method("set_cutscene_locked"):
		player.set_cutscene_locked(true)
	if player != null and player.has_method("set_interaction_enabled"):
		player.set_interaction_enabled(false)

	var player_camera := player.get_node_or_null("Head/Camera3D") as Camera3D if player != null else null
	if player_camera != null:
		player_camera.current = false
	if _boss_cutscene_camera != null:
		_boss_cutscene_camera.current = true

	_play_boss_animation()
	await _play_boss_dialogue_sequence()
	_set_boss_rest_pose()

	if _boss_cutscene_camera != null:
		_boss_cutscene_camera.current = false
	if player_camera != null:
		player_camera.current = true
	if player != null and player.has_method("set_cutscene_locked"):
		player.set_cutscene_locked(false)
	if player != null and player.has_method("set_interaction_enabled"):
		player.set_interaction_enabled(true)

	_boss_dialogue_completed = true
	_set_boss_coolers_interaction_locked(false)
	_boss_dialogue_running = false

func _on_boss_cooler_requested(_cooler: Node3D) -> void:
	if _water_fill_active or _water_fill_completed or not _boss_dialogue_completed:
		return
	_water_fill_active = true
	_water_fill_progress = 0.0
	_water_fill_expect_shift = true
	_water_fill_last_input_time = -1.0
	_set_boss_coolers_interaction_locked(true)
	if player != null and player.has_method("set_cutscene_locked"):
		player.set_cutscene_locked(true)
	if player != null and player.has_method("set_interaction_enabled"):
		player.set_interaction_enabled(false)
	if player != null and player.has_method("show_water_fill_minigame"):
		player.show_water_fill_minigame(_water_fill_progress, _water_fill_expect_shift)
	await get_tree().create_timer(WATER_FILL_START_DELAY).timeout
	_water_fill_last_input_time = Time.get_ticks_msec() / 1000.0

func _set_boss_coolers_interaction_locked(locked: bool) -> void:
	for cooler in _boss_coolers:
		if cooler != null and cooler.has_method("set_interaction_locked"):
			cooler.set_interaction_locked(locked)

func _set_liminal_coolers_interaction_locked(locked: bool) -> void:
	for cooler in _liminal_coolers:
		if cooler != null and cooler.has_method("set_interaction_locked"):
			cooler.set_interaction_locked(locked)

func _process_water_fill(delta: float) -> void:
	var current_time := Time.get_ticks_msec() / 1000.0
	var idle_decay := WATER_FILL_IDLE_DECAY if (_water_fill_last_input_time < 0.0 or current_time - _water_fill_last_input_time > WATER_FILL_TEMPO_WINDOW) else WATER_FILL_DECAY
	_water_fill_progress = max(_water_fill_progress - idle_decay * delta, 0.0)
	if player != null and player.has_method("update_water_fill_minigame"):
		player.update_water_fill_minigame(_water_fill_progress, _water_fill_expect_shift)

func _handle_water_fill_input(is_shift: bool) -> void:
	if not _water_fill_active:
		return

	if is_shift != _water_fill_expect_shift:
		_water_fill_progress = max(_water_fill_progress - WATER_FILL_WRONG_INPUT_PENALTY, 0.0)
		if player != null and player.has_method("update_water_fill_minigame"):
			player.update_water_fill_minigame(_water_fill_progress, _water_fill_expect_shift)
		return

	var now: float = Time.get_ticks_msec() / 1000.0
	var tempo_gap: float = 0.0 if _water_fill_last_input_time < 0.0 else now - _water_fill_last_input_time
	var tempo_factor: float = 1.0 if _water_fill_last_input_time < 0.0 else clamp(1.0 - (tempo_gap / WATER_FILL_TEMPO_WINDOW), 0.0, 1.0)
	var gain: float = lerp(WATER_FILL_GAIN_SLOW, WATER_FILL_GAIN_FAST, tempo_factor)
	_water_fill_progress = min(_water_fill_progress + gain, 1.0)
	_water_fill_expect_shift = not _water_fill_expect_shift
	_water_fill_last_input_time = now

	if player != null and player.has_method("update_water_fill_minigame"):
		player.update_water_fill_minigame(_water_fill_progress, _water_fill_expect_shift)

	if _water_fill_progress >= 1.0:
		call_deferred("_complete_water_fill_minigame")

func _complete_water_fill_minigame() -> void:
	if not _water_fill_active:
		return
	_water_fill_active = false
	_water_fill_completed = true
	if player != null and player.has_method("hide_water_fill_minigame"):
		player.hide_water_fill_minigame()
	_play_one_shot(_scare_hit_player)
	call_deferred("_enter_liminal_space")

func _enter_liminal_space() -> void:
	if player != null and player.has_method("set_cutscene_locked"):
		player.set_cutscene_locked(true)
	if player != null and player.has_method("set_interaction_enabled"):
		player.set_interaction_enabled(false)
	if player != null and player.has_method("set_movement_bounds_enabled"):
		player.set_movement_bounds_enabled(false)
	_set_boss_coolers_interaction_locked(true)
	if _boss_talk_trigger != null and _boss_talk_trigger.has_method("set_interaction_locked"):
		_boss_talk_trigger.set_interaction_locked(true)
	if _boss_room != null:
		_set_node3d_visible_with_collisions(_boss_room, false)
	if office != null:
		_set_node3d_visible_with_collisions(office, false)
	_stop_player(_ambient_player)
	_stop_player(_office_noise_player)
	_ambient_player.volume_db = -9.0
	_play_looped(_ambient_player)
	_play_looped(_liminal_sound_player)
	_reset_liminal_challenge_state()
	if _liminal_room != null:
		_set_node3d_visible_with_collisions(_liminal_room, true)
		_apply_active_environment(_liminal_environment_resource)
		_set_liminal_boss_rest_pose()
		if _liminal_boss_talk_trigger != null and _liminal_boss_talk_trigger.has_method("set_interaction_locked"):
			_liminal_boss_talk_trigger.set_interaction_locked(false)
		_set_liminal_coolers_interaction_locked(true)
	if player is Node3D and _liminal_room_spawn != null:
		(player as Node3D).global_position = _liminal_room_spawn.global_position
	if player != null and player.has_method("reset_ui_for_liminal"):
		player.reset_ui_for_liminal()
	if player != null and player.has_method("set_postprocess_enabled"):
		player.set_postprocess_enabled(true)
	if player != null and player.has_method("set_postprocess_vignette_enabled"):
		player.set_postprocess_vignette_enabled(false)
	if player != null and player.has_method("set_cutscene_locked"):
		player.set_cutscene_locked(false)
	if player != null and player.has_method("set_interaction_enabled"):
		player.set_interaction_enabled(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await get_tree().create_timer(LIMINAL_SPAWN_VOICE_DELAY).timeout
	if _second_cycle_intro_player != null:
		_second_cycle_intro_player.stream = LIMINAL_SPAWN_STREAM
		if player != null and player.has_method("show_subtitle"):
			player.show_subtitle("Стажер: Нет... Черт, что это за место???", LIMINAL_SPAWN_STREAM.get_length())
		_play_one_shot(_second_cycle_intro_player)
		await _second_cycle_intro_player.finished

func _on_liminal_boss_talk_requested() -> void:
	if _liminal_boss_dialogue_running or _liminal_boss_dialogue_completed:
		return
	_liminal_boss_dialogue_running = true

	if _liminal_boss_talk_trigger != null and _liminal_boss_talk_trigger.has_method("set_interaction_locked"):
		_liminal_boss_talk_trigger.set_interaction_locked(true)
	if player != null and player.has_method("set_cutscene_locked"):
		player.set_cutscene_locked(true)
	if player != null and player.has_method("set_interaction_enabled"):
		player.set_interaction_enabled(false)

	var player_camera := player.get_node_or_null("Head/Camera3D") as Camera3D if player != null else null
	if player_camera != null:
		player_camera.current = false
	if _liminal_boss_cutscene_camera != null:
		_liminal_boss_cutscene_camera.current = true

	_play_liminal_boss_animation()
	await _play_dialogue_sequence(_liminal_boss_dialogue_lines)
	_set_liminal_boss_rest_pose()

	if _liminal_boss_cutscene_camera != null:
		_liminal_boss_cutscene_camera.current = false
	if player_camera != null:
		player_camera.current = true
	if player != null and player.has_method("set_cutscene_locked"):
		player.set_cutscene_locked(false)
	if player != null and player.has_method("set_interaction_enabled"):
		player.set_interaction_enabled(true)

	_liminal_boss_dialogue_completed = true
	_liminal_boss_dialogue_running = false
	_start_liminal_challenge()

func _on_liminal_cooler_shutdown_requested(cooler: Node3D) -> void:
	if not _liminal_challenge_active or _liminal_challenge_completed:
		return
	if cooler != null and cooler.has_method("set_interaction_locked"):
		cooler.set_interaction_locked(true)
	_liminal_coolers_disabled += 1
	if player != null and player.has_method("update_liminal_challenge"):
		player.update_liminal_challenge(_liminal_time_left, _liminal_coolers_disabled, LIMINAL_CHALLENGE_TOTAL_COOLERS)
	if _liminal_coolers_disabled >= LIMINAL_CHALLENGE_TOTAL_COOLERS:
		_complete_liminal_challenge(true)

func _start_liminal_challenge() -> void:
	if _liminal_challenge_completed:
		return
	_liminal_challenge_active = true
	_liminal_time_left = LIMINAL_CHALLENGE_DURATION
	_liminal_coolers_disabled = 0
	_set_liminal_coolers_interaction_locked(false)
	_spawn_liminal_runner_woman()
	_play_looped(_liminal_timer_player)
	if player != null and player.has_method("hide_liminal_result"):
		player.hide_liminal_result()
	if player != null and player.has_method("show_liminal_challenge"):
		player.show_liminal_challenge(_liminal_time_left, _liminal_coolers_disabled, LIMINAL_CHALLENGE_TOTAL_COOLERS)

func _process_liminal_challenge(delta: float) -> void:
	_liminal_time_left = max(_liminal_time_left - delta, 0.0)
	if player != null and player.has_method("update_liminal_challenge"):
		player.update_liminal_challenge(_liminal_time_left, _liminal_coolers_disabled, LIMINAL_CHALLENGE_TOTAL_COOLERS)
	if _liminal_time_left <= 0.0 and _liminal_coolers_disabled < LIMINAL_CHALLENGE_TOTAL_COOLERS:
		_complete_liminal_challenge(false)

func _complete_liminal_challenge(success: bool) -> void:
	if not _liminal_challenge_active and _liminal_challenge_completed:
		return
	_liminal_challenge_active = false
	_liminal_challenge_completed = true
	_set_liminal_coolers_interaction_locked(true)
	_clear_liminal_runner_woman()
	_stop_player(_liminal_timer_player)
	if player != null and player.has_method("hide_liminal_challenge"):
		player.hide_liminal_challenge()
	if player != null and player.has_method("set_cutscene_locked"):
		player.set_cutscene_locked(true)
	if player != null and player.has_method("set_interaction_enabled"):
		player.set_interaction_enabled(false)
	if success:
		_play_one_shot(_win_sound_player)
		if player != null and player.has_method("show_liminal_result"):
			player.show_liminal_result(
				"ТЫ СМОГ ВЫЙТИ ИЗ ПЕТЛИ",
				"ЧЁРНЫЕ КУЛЕРЫ УНИЧТОЖЕНЫ. ЭТО МЕСТО БОЛЬШЕ НЕ ДЕРЖИТ ТЕБЯ ЗДЕСЬ.",
				true
			)
	else:
		_play_one_shot(_scare_hit_player)
		if player != null and player.has_method("show_liminal_result"):
			player.show_liminal_result(
				"ТЫ НЕ СМОГ ВЫБРАТЬСЯ",
				"ТЫ НАВЕЧНО ОСТАЛСЯ В ЭТОМ ЦИКЛЕ. ЧЁРНЫЕ КУЛЕРЫ ПОБЕДИЛИ.",
				false
			)

func _reset_liminal_challenge_state() -> void:
	_liminal_boss_dialogue_running = false
	_liminal_boss_dialogue_completed = false
	_liminal_challenge_active = false
	_liminal_challenge_completed = false
	_liminal_time_left = LIMINAL_CHALLENGE_DURATION
	_liminal_coolers_disabled = 0
	_stop_player(_liminal_timer_player)
	_clear_liminal_runner_woman()
	if player != null and player.has_method("hide_liminal_challenge"):
		player.hide_liminal_challenge()
	if player != null and player.has_method("hide_liminal_result"):
		player.hide_liminal_result()

func _process_liminal_runner(delta: float) -> void:
	if _liminal_runner_woman == null or not is_instance_valid(_liminal_runner_woman):
		return
	var current_position := _liminal_runner_woman.global_position
	var motion := _liminal_runner_target - current_position
	motion.y = 0.0
	if motion.length() <= LIMINAL_RUNNER_TARGET_REACHED_DISTANCE:
		_liminal_runner_target = _advance_liminal_runner_target(current_position)
		motion = _liminal_runner_target - current_position
		motion.y = 0.0
	if motion.length() <= 0.1:
		_liminal_runner_woman.velocity = Vector3.ZERO
		_liminal_runner_woman.move_and_slide()
		return
	var direction := motion.normalized()
	_liminal_runner_woman.look_at(_liminal_runner_woman.global_position + direction, Vector3.UP)
	_liminal_runner_woman.velocity.x = direction.x * LIMINAL_RUNNER_SPEED
	_liminal_runner_woman.velocity.z = direction.z * LIMINAL_RUNNER_SPEED
	_liminal_runner_woman.velocity.y = -3.5
	_liminal_runner_woman.move_and_slide()

func _spawn_liminal_runner_woman() -> void:
	_clear_liminal_runner_woman()
	if _liminal_room == null or _liminal_room_spawn == null:
		return
	var runner_wrapper := CharacterBody3D.new()
	runner_wrapper.name = "LiminalRunnerWoman"
	runner_wrapper.collision_layer = 0
	runner_wrapper.collision_mask = 1
	runner_wrapper.floor_snap_length = 2.0
	_liminal_room.add_child(runner_wrapper)

	var collision_shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = RUNNER_COLLISION_RADIUS
	capsule.height = RUNNER_COLLISION_HEIGHT
	collision_shape.shape = capsule
	collision_shape.position = Vector3(0.0, RUNNER_COLLISION_HEIGHT * 0.5 + RUNNER_COLLISION_RADIUS, 0.0)
	runner_wrapper.add_child(collision_shape)

	var runner_model := RUNNER_WOMAN_SCENE.instantiate() as Node3D
	if runner_model == null:
		runner_wrapper.queue_free()
		return
	runner_wrapper.add_child(runner_model)
	_play_runner_animation(runner_model)

	var first_target_center := _get_liminal_cooler_center(1 if _liminal_coolers.size() > 1 else 0)
	var spawn_position := _get_liminal_cooler_route_point(0, first_target_center)
	runner_wrapper.global_position = spawn_position
	_liminal_runner_target_index = 0
	_liminal_runner_target = _advance_liminal_runner_target(spawn_position)
	runner_wrapper.look_at(runner_wrapper.global_position + (_liminal_runner_target - spawn_position).normalized(), Vector3.UP)
	_liminal_runner_woman = runner_wrapper

func _clear_liminal_runner_woman() -> void:
	if _liminal_runner_woman != null and is_instance_valid(_liminal_runner_woman):
		_liminal_runner_woman.queue_free()
	_liminal_runner_woman = null
	_liminal_runner_target = Vector3.ZERO
	_liminal_runner_target_index = -1

func _advance_liminal_runner_target(from_position: Vector3) -> Vector3:
	if _liminal_coolers.is_empty():
		return _liminal_room_spawn.global_position if _liminal_room_spawn != null else Vector3.ZERO
	var candidate_indices: Array[int] = []
	for index in range(_liminal_coolers.size()):
		if index != _liminal_runner_target_index:
			candidate_indices.append(index)
	if candidate_indices.is_empty():
		return from_position
	_liminal_runner_target_index = candidate_indices[randi() % candidate_indices.size()]
	return _get_liminal_cooler_route_point(_liminal_runner_target_index, from_position)

func _get_liminal_cooler_route_point(index: int, approach_from: Vector3) -> Vector3:
	if _liminal_coolers.is_empty():
		return _liminal_room_spawn.global_position if _liminal_room_spawn != null else Vector3.ZERO
	var safe_index := posmod(index, _liminal_coolers.size())
	var cooler := _liminal_coolers[safe_index]
	if cooler == null:
		return _liminal_room_spawn.global_position if _liminal_room_spawn != null else Vector3.ZERO
	var center := cooler.global_position
	var offset_direction := approach_from - center
	offset_direction.y = 0.0
	if offset_direction.length() < 0.001:
		offset_direction = Vector3.FORWARD
	else:
		offset_direction = offset_direction.normalized()
	var point := center + (offset_direction * LIMINAL_RUNNER_COOLER_OFFSET)
	point.y += 0.08
	return point

func _get_liminal_cooler_center(index: int) -> Vector3:
	if _liminal_coolers.is_empty():
		return _liminal_room_spawn.global_position if _liminal_room_spawn != null else Vector3.ZERO
	var safe_index := posmod(index, _liminal_coolers.size())
	var cooler := _liminal_coolers[safe_index]
	if cooler == null:
		return _liminal_room_spawn.global_position if _liminal_room_spawn != null else Vector3.ZERO
	return cooler.global_position

func _play_boss_dialogue_sequence() -> void:
	await _play_dialogue_sequence(_boss_dialogue_lines)

func _play_dialogue_sequence(dialogue_lines: Array) -> void:
	for line_data in dialogue_lines:
		await _play_dialogue_line(line_data)
		await get_tree().create_timer(BOSS_DIALOGUE_LINE_GAP).timeout

func _play_dialogue_line(line_data: Dictionary) -> void:
	var subtitle := line_data.get("subtitle", "") as String
	var fallback_duration := float(line_data.get("duration", 2.0))
	var stream_path := line_data.get("path", "") as String
	var stream := load(stream_path) as AudioStream if not stream_path.is_empty() else null
	var duration := fallback_duration

	if player != null and player.has_method("show_subtitle") and not subtitle.is_empty():
		if stream != null and stream.get_length() > 0.05:
			duration = stream.get_length()
		player.show_subtitle(subtitle, duration)

	if stream == null or _boss_dialogue_player == null:
		await get_tree().create_timer(duration).timeout
		return

	_boss_dialogue_player.stream = stream
	duration = max(stream.get_length(), fallback_duration)
	_play_one_shot(_boss_dialogue_player)
	await _boss_dialogue_player.finished

func _play_boss_animation() -> void:
	var animation_player := _get_boss_animation_player()
	if animation_player == null or not animation_player.has_animation("Armaturetalking"):
		return
	var animation := animation_player.get_animation("Armaturetalking")
	if animation != null:
		animation.loop_mode = Animation.LOOP_LINEAR
	animation_player.play("Armaturetalking")

func _set_boss_rest_pose() -> void:
	var animation_player := _get_boss_animation_player()
	if animation_player == null:
		return
	animation_player.stop()

func _get_boss_animation_player() -> AnimationPlayer:
	if _boss_room == null:
		return null
	var boss_character := _boss_room.get_node_or_null("BossCharacter")
	if boss_character == null:
		return null
	var animation_player := boss_character.find_child("AnimationPlayer", true, false) as AnimationPlayer
	return animation_player

func _play_liminal_boss_animation() -> void:
	var animation_player := _get_liminal_boss_animation_player()
	if animation_player == null or not animation_player.has_animation("Armaturetalking"):
		return
	var animation := animation_player.get_animation("Armaturetalking")
	if animation != null:
		animation.loop_mode = Animation.LOOP_LINEAR
	animation_player.play("Armaturetalking")

func _set_liminal_boss_rest_pose() -> void:
	if _liminal_boss != null:
		_liminal_boss.transform = _liminal_boss_rest_transform
	var animation_player := _get_liminal_boss_animation_player()
	if animation_player == null:
		return
	animation_player.stop()

func _get_liminal_boss_animation_player() -> AnimationPlayer:
	if _liminal_room == null:
		return null
	var boss_character := _liminal_room.get_node_or_null("LiminalBoss")
	if boss_character == null:
		return null
	var animation_player := boss_character.find_child("AnimationPlayer", true, false) as AnimationPlayer
	return animation_player

func _play_fade_out() -> void:
	if _fade_rect == null:
		return
	var tween := create_tween()
	tween.tween_property(_fade_rect, "color", Color(0, 0, 0, 1), SIXTH_SHUTDOWN_FADE_DURATION)
	await tween.finished

func _play_fade_in() -> void:
	if _fade_rect == null:
		return
	var tween := create_tween()
	tween.tween_property(_fade_rect, "color", Color(0, 0, 0, 0), SIXTH_SHUTDOWN_FADE_DURATION * 0.9)
	await tween.finished

func _update_player_progress(current: int) -> void:
	if player != null and player.has_method("set_progress"):
		player.set_progress(current, 6)

func _spawn_runner_woman() -> Node3D:
	_clear_runner_woman()
	_runner_route.clear()

	var runner_wrapper := CharacterBody3D.new()
	runner_wrapper.name = "RunnerWomanEvent"
	runner_wrapper.collision_layer = 0
	runner_wrapper.collision_mask = 1
	office.add_child(runner_wrapper)

	var collision_shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = RUNNER_COLLISION_RADIUS
	capsule.height = RUNNER_COLLISION_HEIGHT
	collision_shape.shape = capsule
	collision_shape.position = Vector3(0.0, RUNNER_COLLISION_HEIGHT * 0.5 + RUNNER_COLLISION_RADIUS, 0.0)
	runner_wrapper.add_child(collision_shape)

	var runner_model := RUNNER_WOMAN_SCENE.instantiate() as Node3D
	if runner_model == null:
		runner_wrapper.queue_free()
		return null

	runner_wrapper.add_child(runner_model)

	runner_wrapper.global_position = RUNNER_PATH_START
	_initialize_runner_route(runner_wrapper.global_position)
	runner_wrapper.look_at(_get_active_runner_target(runner_wrapper.global_position), Vector3.UP)
	_runner_woman = runner_wrapper
	return runner_wrapper

func _animate_runner_woman(runner_wrapper: Node3D) -> bool:
	var runner_body := runner_wrapper as CharacterBody3D
	if runner_body == null:
		return false

	var elapsed := 0.0
	var distance_travelled := 0.0
	var previous_position := runner_body.global_position
	var reached_player := false
	while is_instance_valid(runner_body) and elapsed < RUNNER_MAX_CHASE_TIME:
		await get_tree().physics_frame
		var delta := get_physics_process_delta_time()
		elapsed += delta

		var target_position := _get_active_runner_target(runner_body.global_position)
		var final_target := _get_runner_target_position(runner_body.global_position)
		var motion := target_position - runner_body.global_position
		motion.y = 0.0

		if motion.length() <= 0.6 and not _runner_route.is_empty():
			_runner_route.pop_front()
			target_position = _get_active_runner_target(runner_body.global_position)
			final_target = _get_runner_target_position(runner_body.global_position)
			motion = target_position - runner_body.global_position
			motion.y = 0.0

		var chasing_final_target := _runner_route.is_empty()
		runner_body.collision_mask = 0 if chasing_final_target else 1
		if chasing_final_target and motion.length() <= RUNNER_CONTACT_DISTANCE and elapsed >= RUNNER_MIN_CHASE_TIME and distance_travelled >= RUNNER_MIN_CHASE_DISTANCE:
			reached_player = true
			break

		var travel_direction := motion.normalized()
		runner_body.look_at(runner_body.global_position + travel_direction, Vector3.UP)
		runner_body.velocity = travel_direction * RUNNER_CHASE_SPEED
		runner_body.move_and_slide()
		distance_travelled += runner_body.global_position.distance_to(previous_position)
		previous_position = runner_body.global_position

		if _runner_collided_with_player(runner_body):
			reached_player = true
			break

		if chasing_final_target and _distance_to_player(runner_body.global_position) <= RUNNER_CONTACT_DISTANCE and elapsed >= RUNNER_MIN_CHASE_TIME and distance_travelled >= RUNNER_MIN_CHASE_DISTANCE:
			reached_player = true
			break

	runner_body.velocity = Vector3.ZERO
	runner_body.collision_mask = 1
	return reached_player

func _initialize_runner_route(from_position: Vector3) -> void:
	_runner_route = _build_runner_path(from_position)
	_trim_runner_route(from_position)

func _get_active_runner_target(from_position: Vector3) -> Vector3:
	if not _runner_route.is_empty():
		return _runner_route[0]
	return _get_runner_target_position(from_position)

func _get_runner_target_position(from_position: Vector3) -> Vector3:
	var fallback_target := RUNNER_PATH_END
	var player_node := player as Node3D
	if player_node == null:
		return fallback_target

	var target_position := player_node.global_position
	target_position.y = from_position.y
	var travel_direction := (target_position - from_position)
	if travel_direction.length() < 0.001:
		return fallback_target

	target_position -= travel_direction.normalized() * RUNNER_PLAYER_OFFSET
	return target_position

func _get_runner_navigation_target(from_position: Vector3, path: Array[Vector3]) -> Vector3:
	for waypoint in path:
		var flat_distance := Vector2(from_position.x, from_position.z).distance_to(Vector2(waypoint.x, waypoint.z))
		if flat_distance > 0.35:
			return waypoint
	return _get_runner_target_position(from_position)

func _build_runner_path(from_position: Vector3) -> Array[Vector3]:
	var path: Array[Vector3] = []
	var direct_target: Vector3 = _get_runner_target_position(from_position)
	var current_lane_x: float = _get_nearest_lane_value(from_position.x, RUNNER_X_LANES)
	var player_lane_z: float = _get_nearest_lane_value(direct_target.z, RUNNER_ROW_ENTRY_Z_LANES)
	var cubicle_center: Variant = _get_player_cubicle_center(direct_target)
	var turn_x: float = _get_player_access_lane_x(direct_target.x)

	path.append(Vector3(current_lane_x, from_position.y, player_lane_z))
	path.append(Vector3(turn_x, from_position.y, player_lane_z))

	if cubicle_center != null:
		var cubicle_center_vec := cubicle_center as Vector3
		var safe_entry := Vector3(cubicle_center_vec.x, from_position.y, cubicle_center_vec.z + CUBICLE_ENTRY_OFFSET_Z)
		path.append(safe_entry)
	else:
		var cubicle_entry: Variant = _get_player_cubicle_entry_position(from_position.y)
		if cubicle_entry != null:
			path.append(cubicle_entry)

	return path

func _trim_runner_route(from_position: Vector3) -> void:
	while not _runner_route.is_empty():
		var waypoint := _runner_route[0]
		var flat_distance := Vector2(from_position.x, from_position.z).distance_to(Vector2(waypoint.x, waypoint.z))
		if flat_distance > 0.35:
			return
		_runner_route.pop_front()

func _get_player_access_lane_x(player_x: float) -> float:
	if player_x <= -4.8:
		return -9.6
	if player_x < 0.0:
		return -4.8
	if player_x <= 4.8:
		return 4.8
	return 9.6

func _get_player_cubicle_entry_position(height: float) -> Variant:
	var player_node := player as Node3D
	if player_node == null:
		return null

	var cubicle_center: Variant = _get_player_cubicle_center(player_node.global_position)
	if cubicle_center == null:
		return null

	var entry_x: float = _get_nearest_lane_value(player_node.global_position.x, RUNNER_X_LANES)
	return Vector3(entry_x, height, cubicle_center.z + CUBICLE_ENTRY_OFFSET_Z)

func _get_player_cubicle_center(player_position: Vector3) -> Variant:
	for center_z in CUBICLE_CENTER_ZS:
		for center_x in CUBICLE_CENTER_XS:
			if abs(player_position.x - center_x) <= CUBICLE_HALF_EXTENT and abs(player_position.z - center_z) <= CUBICLE_HALF_EXTENT:
				return Vector3(center_x, player_position.y, center_z)
	return null

func _get_nearest_lane_value(value: float, lanes: Array[float]) -> float:
	var nearest: float = lanes[0]
	var nearest_distance: float = abs(value - nearest)
	for lane: float in lanes:
		var distance: float = abs(value - lane)
		if distance < nearest_distance:
			nearest = lane
			nearest_distance = distance
	return nearest

func _distance_to_player(from_position: Vector3) -> float:
	var player_node := player as Node3D
	if player_node == null:
		return INF

	var target_position := player_node.global_position
	target_position.y = from_position.y
	return from_position.distance_to(target_position)

func _runner_collided_with_player(runner_body: CharacterBody3D) -> bool:
	for collision_index in runner_body.get_slide_collision_count():
		var collision := runner_body.get_slide_collision(collision_index)
		if collision == null:
			continue
		if collision.get_collider() == player:
			return true
	return false

func _clear_runner_woman() -> void:
	_stop_player(_runner_footsteps_player)
	if _runner_woman != null:
		_runner_woman.queue_free()
		_runner_woman = null
	_runner_route.clear()

func _play_runner_animation(runner_model: Node) -> void:
	var animation_player := runner_model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if animation_player == null:
		return

	var animation := animation_player.get_animation(RUNNER_ANIMATION_NAME)
	if animation != null:
		animation.loop_mode = Animation.LOOP_LINEAR

	animation_player.play(RUNNER_ANIMATION_NAME, -1.0, RUNNER_ANIMATION_SPEED)

func play_interaction_click() -> void:
	_play_one_shot(_interaction_click_player)

func play_scare_hit() -> void:
	_play_one_shot(_scare_hit_player)

func play_whisper() -> void:
	_play_one_shot(_whisper_player)

func play_player_event_voice(power_off_count: int) -> void:
	var voice_stream := _player_event_voice_streams.get(power_off_count) as AudioStream
	if voice_stream == null or _player_event_voice_player == null:
		return
	_player_event_voice_player.stream = voice_stream
	var subtitle := _player_event_subtitles.get(power_off_count, "") as String
	if player != null and player.has_method("show_subtitle") and not subtitle.is_empty():
		player.show_subtitle(subtitle, voice_stream.get_length())
	_play_one_shot(_player_event_voice_player)

func queue_player_event_voice(power_off_count: int) -> void:
	var timer := get_tree().create_timer(PLAYER_EVENT_VOICE_DELAY)
	timer.timeout.connect(func() -> void:
		play_player_event_voice(power_off_count)
	)

func _setup_audio() -> void:
	_ambient_player = _create_audio_player("AmbientNoisePlayer", _make_looping_stream(AMBIENT_NOISE_STREAM), -16.0)
	_office_noise_player = _create_audio_player("OfficeNoisePlayer", _make_looping_stream(OFFICE_NOISE_STREAM), -14.0)
	_chair_slide_player = _create_audio_player("ChairSlidePlayer", _make_looping_stream(CHAIR_SLIDE_STREAM), -7.0)
	_chairs_scary_hit_player = _create_audio_player("ChairsScaryHitPlayer", CHAIRS_SCARY_HIT_STREAM, -4.0)
	_interaction_click_player = _create_audio_player("InteractionClickPlayer", INTERACTION_CLICK_STREAM, -6.0)
	_melody_player = _create_audio_player("MelodyPlayer", MELODY_STREAM, -10.0)
	_liminal_sound_player = _create_audio_player("LiminalSoundPlayer", _make_looping_stream(LIMINAL_SOUND_STREAM), -12.0)
	_liminal_timer_player = _create_audio_player("LiminalTimerPlayer", _make_looping_stream(LIMINAL_TIMER_STREAM), -13.5)
	_runner_footsteps_player = _create_audio_player("RunnerFootstepsPlayer", _make_looping_stream(RUNNER_FOOTSTEPS_STREAM), -5.0)
	_runner_scream_player = _create_audio_player("RunnerScreamPlayer", RUNNER_SCREAM_STREAM, -2.0)
	_scare_hit_player = _create_audio_player("ScareHitPlayer", SCARE_HIT_STREAM, -3.0)
	_win_sound_player = _create_audio_player("WinSoundPlayer", WIN_SOUND_STREAM, -5.0)
	_whisper_player = _create_audio_player("WhisperPlayer", WHISPER_STREAM, -7.5)
	_player_event_voice_player = _create_audio_player("PlayerEventVoicePlayer", PLAYER_EVENT_2_STREAM, -4.0)
	_second_cycle_intro_player = _create_audio_player("SecondCycleIntroPlayer", PLAYER_CYCLE2_1_STREAM, -4.0)
	_boss_dialogue_player = _create_audio_player("BossDialoguePlayer", null, -3.0)

func _create_audio_player(player_name: String, stream: AudioStream, volume_db: float) -> AudioStreamPlayer:
	var player_node := AudioStreamPlayer.new()
	player_node.name = player_name
	player_node.stream = stream
	player_node.volume_db = volume_db
	add_child(player_node)
	return player_node

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

func _play_one_shot(player_node: AudioStreamPlayer) -> void:
	if player_node == null or player_node.stream == null:
		return
	player_node.stop()
	player_node.play()

func _play_looped(player_node: AudioStreamPlayer) -> void:
	if player_node == null or player_node.stream == null:
		return
	if not player_node.playing:
		player_node.play()

func _stop_player(player_node: AudioStreamPlayer) -> void:
	if player_node == null:
		return
	if player_node.playing:
		player_node.stop()

func _fade_out_audio_player(player_node: AudioStreamPlayer, duration: float) -> void:
	if player_node == null or not player_node.playing:
		return
	var initial_volume := player_node.volume_db
	var tween := create_tween()
	tween.tween_property(player_node, "volume_db", -40.0, duration)
	await tween.finished
	player_node.stop()
	player_node.volume_db = initial_volume

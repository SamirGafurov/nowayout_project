extends Node

const GAME_SCENE_PATH := "res://scenes/game.tscn"
const UI_CLICK_STREAM := preload("res://audio/computer_shutdown.mp3")
const TYPING_MACHINE_STREAM := preload("res://audio/typing_machine.mp3")
const INTRO_PHRASES := [
	"23:47",
	"ты один в пустом офисе",
	"начальник попросил отключить компьютеры",
	"это должно занять всего пару минут",
	"..."
]
const INTRO_HOLD_DURATIONS := [0.85, 1.15, 1.25, 1.15, 0.9]
const INTRO_FADE_IN := 0.42
const INTRO_FADE_OUT := 0.32
const INTRO_GAP := 0.08
const INTRO_REFERENCE_FPS := 60.0

@onready var game_mount: Node = $GameMount
@onready var ui_layer: CanvasLayer = $UILayer
@onready var menu_root: Control = $UILayer/MenuRoot
@onready var loading_root: Control = $UILayer/LoadingRoot
@onready var intro_root: Control = $UILayer/IntroRoot
@onready var intro_label: Label = $UILayer/IntroRoot/IntroLabel
@onready var pause_root: Control = $UILayer/PauseRoot
@onready var start_button: Button = $UILayer/MenuRoot/MenuPanel/StartButton
@onready var loading_label: Label = $UILayer/LoadingRoot/LoadingPanel/LoadingLabel
@onready var loading_status: Label = $UILayer/LoadingRoot/LoadingPanel/LoadingStatus
@onready var loading_bar: ProgressBar = $UILayer/LoadingRoot/LoadingPanel/LoadingBar
@onready var resume_button: Button = $UILayer/PauseRoot/PausePanel/ResumeButton
@onready var menu_button: Button = $UILayer/PauseRoot/PausePanel/MenuButton

var _current_game: Node = null
var _game_scene_resource: PackedScene = null
var _is_loading := false
var _intro_running := false
var _intro_index := 0
var _intro_stage := ""
var _intro_stage_ticks := 0
var _loading_progress := []
var _loading_message := "ИНИЦИАЛИЗАЦИЯ ОФИСА"
var _ui_click_player: AudioStreamPlayer = null
var _typing_machine_player: AudioStreamPlayer = null
var _loop_cycle_index := 1

func _ready() -> void:
	add_to_group("app_shell")
	process_mode = Node.PROCESS_MODE_ALWAYS
	game_mount.process_mode = Node.PROCESS_MODE_PAUSABLE
	ui_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)
	_setup_audio()
	_style_interface()
	_show_main_menu()

func _process(delta: float) -> void:
	if _intro_running:
		_process_intro(delta)

	if not _is_loading:
		return

	var status := ResourceLoader.load_threaded_get_status(GAME_SCENE_PATH, _loading_progress)
	if _loading_progress.size() > 0:
		loading_bar.value = clampf(float(_loading_progress[0]) * 100.0, 0.0, 100.0)
		loading_status.text = "%s %d%%" % [_loading_message, int(round(loading_bar.value))]

	if status == ResourceLoader.THREAD_LOAD_LOADED:
		_game_scene_resource = ResourceLoader.load_threaded_get(GAME_SCENE_PATH) as PackedScene
		_is_loading = false
		loading_bar.value = 100.0
		loading_status.text = "%s 100%%" % _loading_message
		_instantiate_game()
		call_deferred("_play_intro_and_start_game")
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		_is_loading = false
		loading_status.text = "ЗАГРУЗКА НЕ УДАЛАСЬ"
		start_button.disabled = false

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if event.keycode != KEY_ESCAPE:
		return
	if _current_game == null or _is_loading or menu_root.visible:
		return

	if pause_root.visible:
		resume_game()
	else:
		toggle_pause_menu()

func start_game() -> void:
	if _is_loading:
		return

	_loop_cycle_index = 1
	start_button.disabled = true
	menu_root.visible = false
	pause_root.visible = false
	intro_root.visible = false
	loading_root.visible = true
	loading_label.text = "ВЫХОДА НЕТ"
	loading_status.text = _loading_message
	loading_bar.value = 0.0
	_loading_message = "ИНИЦИАЛИЗАЦИЯ ОФИСА"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if _game_scene_resource != null:
		loading_bar.value = 100.0
		loading_status.text = "%s 100%%" % _loading_message
		_instantiate_game()
		call_deferred("_play_intro_and_start_game")
		return

	var request_result := ResourceLoader.load_threaded_request(GAME_SCENE_PATH)
	if request_result != OK:
		loading_status.text = "ЗАГРУЗКА НЕ УДАЛАСЬ"
		menu_root.visible = true
		loading_root.visible = false
		start_button.disabled = false
		return

	_is_loading = true

func toggle_pause_menu() -> void:
	if _current_game == null:
		return
	var should_pause := not pause_root.visible
	get_tree().paused = should_pause
	pause_root.visible = should_pause
	if should_pause:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func resume_game() -> void:
	get_tree().paused = false
	pause_root.visible = false
	if _current_game != null:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func return_to_main_menu() -> void:
	get_tree().paused = false
	pause_root.visible = false
	_stop_player(_typing_machine_player)
	_free_current_game()
	_show_main_menu()

func _instantiate_game() -> void:
	_free_current_game()
	if _game_scene_resource == null:
		return

	get_tree().set_meta("loop_cycle_index", _loop_cycle_index)
	_current_game = _game_scene_resource.instantiate()
	_current_game.process_mode = Node.PROCESS_MODE_INHERIT
	game_mount.add_child(_current_game)
	if _current_game.has_signal("loop_restart_requested"):
		var callable := Callable(self, "_on_game_loop_restart_requested")
		if not _current_game.is_connected("loop_restart_requested", callable):
			_current_game.connect("loop_restart_requested", callable)

	get_tree().paused = false
	loading_root.visible = false
	intro_root.visible = false
	menu_root.visible = false
	pause_root.visible = false
	start_button.disabled = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_set_game_interaction_enabled(false)

func _on_start_pressed() -> void:
	_play_ui_click()
	start_game()

func _on_resume_pressed() -> void:
	_play_ui_click()
	resume_game()

func _on_menu_pressed() -> void:
	_play_ui_click()
	return_to_main_menu()

func _on_game_loop_restart_requested() -> void:
	get_tree().paused = false
	pause_root.visible = false
	_loop_cycle_index += 1
	loading_root.visible = true
	intro_root.visible = false
	loading_label.text = "ВЫХОДА НЕТ"
	loading_status.text = "ПЕТЛЯ ПЕРЕЗАПУСКАЕТСЯ 100%"
	loading_bar.value = 100.0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	call_deferred("_restart_loop_cycle_game")

func _restart_loop_cycle_game() -> void:
	_instantiate_game()
	loading_root.visible = false
	intro_root.visible = false
	_set_game_interaction_enabled(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _free_current_game() -> void:
	if _current_game != null:
		_current_game.queue_free()
		_current_game = null

func _show_main_menu() -> void:
	_loop_cycle_index = 1
	menu_root.visible = true
	loading_root.visible = false
	intro_root.visible = false
	pause_root.visible = false
	start_button.disabled = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _style_interface() -> void:
	for button in [start_button, resume_button, menu_button]:
		_apply_button_style(button)

	for panel in [
		$UILayer/MenuRoot/MenuPanel,
		$UILayer/LoadingRoot/LoadingPanel,
		$UILayer/PauseRoot/PausePanel
	]:
		_apply_panel_style(panel)

	_apply_progress_bar_style(loading_bar)
	_apply_intro_style()

func _apply_button_style(button: Button) -> void:
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(0.0, 74.0)
	button.add_theme_font_size_override("font_size", 30)
	button.add_theme_color_override("font_color", Color(0.9, 0.93, 0.98, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.96, 0.96, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.96, 0.96, 1.0))
	button.add_theme_color_override("font_focus_color", Color(1.0, 0.96, 0.96, 1.0))
	button.add_theme_color_override("font_outline_color", Color(0.03, 0.03, 0.04, 1.0))
	button.add_theme_constant_override("outline_size", 10)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.1, 0.14, 0.88)
	normal.border_width_left = 2
	normal.border_width_top = 2
	normal.border_width_right = 2
	normal.border_width_bottom = 2
	normal.border_color = Color(0.38, 0.1, 0.1, 0.95)
	normal.corner_radius_top_left = 10
	normal.corner_radius_top_right = 10
	normal.corner_radius_bottom_right = 10
	normal.corner_radius_bottom_left = 10
	normal.shadow_size = 10
	normal.shadow_color = Color(0, 0, 0, 0.35)

	var hover := normal.duplicate()
	hover.bg_color = Color(0.12, 0.14, 0.18, 0.94)
	hover.border_color = Color(0.72, 0.18, 0.16, 1.0)

	var pressed := hover.duplicate()
	pressed.bg_color = Color(0.2, 0.08, 0.08, 0.96)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)

func _apply_panel_style(panel: Panel) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.05, 0.08, 0.92)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.32, 0.08, 0.09, 0.95)
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_right = 18
	style.corner_radius_bottom_left = 18
	style.shadow_size = 18
	style.shadow_color = Color(0, 0, 0, 0.38)
	panel.add_theme_stylebox_override("panel", style)

func _apply_progress_bar_style(bar: ProgressBar) -> void:
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.06, 0.07, 0.1, 0.95)
	background.border_width_left = 2
	background.border_width_top = 2
	background.border_width_right = 2
	background.border_width_bottom = 2
	background.border_color = Color(0.24, 0.08, 0.08, 0.95)
	background.corner_radius_top_left = 8
	background.corner_radius_top_right = 8
	background.corner_radius_bottom_right = 8
	background.corner_radius_bottom_left = 8

	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.63, 0.14, 0.14, 0.96)
	fill.corner_radius_top_left = 8
	fill.corner_radius_top_right = 8
	fill.corner_radius_bottom_right = 8
	fill.corner_radius_bottom_left = 8

	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)

func _apply_intro_style() -> void:
	var intro_font := SystemFont.new()
	intro_font.font_names = PackedStringArray(["American Typewriter", "Georgia", "Times New Roman", "Noto Serif"])
	intro_label.add_theme_font_override("font", intro_font)
	intro_label.add_theme_font_size_override("font_size", 50)
	intro_label.add_theme_color_override("font_color", Color(0.94, 0.95, 0.98, 1.0))
	intro_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.96))
	intro_label.add_theme_constant_override("outline_size", 10)

func _play_intro_and_start_game() -> void:
	if _intro_running:
		return
	_intro_running = true
	_intro_index = 0
	_intro_stage = "fade_in"
	_intro_stage_ticks = 0
	loading_root.visible = false
	intro_root.visible = true
	intro_label.text = INTRO_PHRASES[0]
	intro_label.modulate = Color(1, 1, 1, 0)
	_play_looped(_typing_machine_player)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process_intro(_delta: float) -> void:
	_intro_stage_ticks += 1

	if _intro_stage == "fade_in":
		var fade_in_frames: int = _seconds_to_intro_frames(INTRO_FADE_IN)
		var fade_in_t: float = minf(float(_intro_stage_ticks) / float(fade_in_frames), 1.0)
		intro_label.modulate = Color(1, 1, 1, fade_in_t)
		if fade_in_t >= 1.0:
			_intro_stage = "hold"
			_intro_stage_ticks = 0
		return

	if _intro_stage == "hold":
		if _intro_stage_ticks >= _seconds_to_intro_frames(INTRO_HOLD_DURATIONS[_intro_index]):
			_intro_stage = "fade_out"
			_intro_stage_ticks = 0
		return

	if _intro_stage == "fade_out":
		var fade_out_frames: int = _seconds_to_intro_frames(INTRO_FADE_OUT)
		var fade_out_t: float = minf(float(_intro_stage_ticks) / float(fade_out_frames), 1.0)
		intro_label.modulate = Color(1, 1, 1, 1.0 - fade_out_t)
		if fade_out_t >= 1.0:
			if _intro_index >= INTRO_PHRASES.size() - 1:
				_finish_intro_sequence()
			else:
				_intro_stage = "gap"
				_intro_stage_ticks = 0
		return

	if _intro_stage == "gap" and _intro_stage_ticks >= _seconds_to_intro_frames(INTRO_GAP):
		_intro_index += 1
		intro_label.text = INTRO_PHRASES[_intro_index]
		intro_label.modulate = Color(1, 1, 1, 0)
		_intro_stage = "fade_in"
		_intro_stage_ticks = 0

func _finish_intro_sequence() -> void:
	intro_root.visible = false
	_intro_running = false
	_intro_stage = ""
	_intro_stage_ticks = 0
	_stop_player(_typing_machine_player)
	_set_game_interaction_enabled(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _seconds_to_intro_frames(seconds: float) -> int:
	return maxi(1, int(round(seconds * INTRO_REFERENCE_FPS)))

func _setup_audio() -> void:
	_ui_click_player = AudioStreamPlayer.new()
	_ui_click_player.name = "UIClickPlayer"
	_ui_click_player.stream = UI_CLICK_STREAM
	_ui_click_player.volume_db = -5.0
	add_child(_ui_click_player)

	_typing_machine_player = AudioStreamPlayer.new()
	_typing_machine_player.name = "TypingMachinePlayer"
	_typing_machine_player.stream = _make_looping_stream(TYPING_MACHINE_STREAM)
	_typing_machine_player.volume_db = -9.0
	add_child(_typing_machine_player)

func _play_ui_click() -> void:
	if _ui_click_player == null or _ui_click_player.stream == null:
		return
	_ui_click_player.stop()
	_ui_click_player.play()

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

func _set_game_interaction_enabled(enabled: bool) -> void:
	if _current_game == null:
		return
	var player := _current_game.get_node_or_null("Player")
	if player != null and player.has_method("set_interaction_enabled"):
		player.set_interaction_enabled(enabled)

extends SceneTree

const GAME_SCENE := preload("res://scenes/game.tscn")

func _initialize() -> void:
	var game := GAME_SCENE.instantiate()
	get_root().add_child(game)

	assert_true(game.has_node("OfficeLevel"), "Game scene should instance the office")
	assert_true(game.has_node("Player"), "Game scene should instance the player")
	assert_true(game.has_node("Player/Head/Camera3D"), "Player should provide the active camera")
	assert_true(game.has_node("Player/PostProcessLayer/PostProcess"), "Player should include the horror post-process overlay")
	assert_true(game.has_node("Player/PostProcessLayer/InteractPrompt"), "Player should include the interaction prompt")

	var camera: Camera3D = game.get_node("Player/Head/Camera3D")
	assert_true(camera.current, "Player camera should be current during play")

	var player: CharacterBody3D = game.get_node("Player")
	assert_true(is_equal_approx(player.position.z, 7.1), "Player should spawn near the front aisle")

	quit()

func assert_true(condition: bool, message: String) -> void:
	if condition:
		print("ASSERT PASS: %s" % message)
		return

	push_error("ASSERT FAIL: %s" % message)
	quit(1)

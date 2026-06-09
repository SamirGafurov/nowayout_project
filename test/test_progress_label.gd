extends SceneTree

const GAME_SCENE := preload("res://scenes/game.tscn")

func _initialize() -> void:
	var game := GAME_SCENE.instantiate()
	get_root().add_child(game)
	await process_frame

	var progress_label := game.get_node("Player/PostProcessLayer/ProgressLabel") as Label
	assert_true(progress_label != null, "Player should include the progress label")
	assert_equal(progress_label.text, "0/6 КОМПЬЮТЕРОВ", "Progress label should start at zero")

	var first_terminal := game.get_node("OfficeLevel/CubicleGrid/Cubicle02/Desk/ComputerTerminal")
	assert_true(first_terminal.interact(), "First terminal should be interactable for progress test")
	await process_frame
	assert_equal(progress_label.text, "1/6 КОМПЬЮТЕРОВ", "Progress label should update after the first shutdown")

	quit()

func assert_true(condition: bool, message: String) -> void:
	if condition:
		print("ASSERT PASS: %s" % message)
		return
	push_error("ASSERT FAIL: %s" % message)
	quit(1)

func assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	assert_true(actual == expected, "%s (expected %s, got %s)" % [message, expected, actual])

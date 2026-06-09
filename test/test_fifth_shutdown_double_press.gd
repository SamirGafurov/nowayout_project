extends SceneTree

const GAME_SCENE := preload("res://scenes/game.tscn")

func _initialize() -> void:
	var game := GAME_SCENE.instantiate()
	get_root().add_child(game)
	await process_frame

	var terminal_paths := [
		"OfficeLevel/CubicleGrid/Cubicle02/Desk/ComputerTerminal",
		"OfficeLevel/CubicleGrid/Cubicle04/Desk/ComputerTerminal",
		"OfficeLevel/CubicleGrid/Cubicle05/Desk/ComputerTerminal",
		"OfficeLevel/CubicleGrid/Cubicle06/Desk/ComputerTerminal",
		"OfficeLevel/CubicleGrid/Cubicle08/Desk/ComputerTerminal",
		"OfficeLevel/CubicleGrid/Cubicle12/Desk/ComputerTerminal"
	]

	for index in range(4):
		var terminal := game.get_node(terminal_paths[index])
		assert_true(terminal.interact(), "First four terminals should be interactable")

	await create_timer(7.2).timeout

	var fifth_terminal := game.get_node(terminal_paths[4])
	var sixth_terminal := game.get_node(terminal_paths[5])

	assert_true(fifth_terminal.interact(), "Fifth terminal should accept the first press")
	assert_true(fifth_terminal.is_powered_on(), "Fifth terminal should remain on after the first press")
	assert_equal(fifth_terminal.get_prompt_text(), "E - нажать ещё раз", "Fifth terminal should ask for the second press")
	assert_true(not sixth_terminal.interact(), "Sixth terminal should stay blocked until the fifth terminal is pressed again")

	assert_true(fifth_terminal.interact(), "Fifth terminal should accept the second press")
	await create_timer(0.7).timeout

	assert_true(not fifth_terminal.is_powered_on(), "Fifth terminal should power off after the second press")
	assert_equal(int(game.get_tree().get_meta("powered_off_terminals", 0)), 5, "Powered off counter should reach five only after the second press")
	assert_true(sixth_terminal.interact(), "Sixth terminal should unlock after the fifth terminal fully powers off")

	quit()

func assert_true(condition: bool, message: String) -> void:
	if condition:
		print("ASSERT PASS: %s" % message)
		return

	push_error("ASSERT FAIL: %s" % message)
	quit(1)

func assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	assert_true(actual == expected, "%s (expected %s, got %s)" % [message, expected, actual])

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
		assert_true(terminal.interact(), "Terminal %d should be interactable" % (index + 1))

	await create_timer(7.2).timeout

	var fifth_terminal := game.get_node(terminal_paths[4])
	assert_true(fifth_terminal.interact(), "Fifth terminal should accept the first press")
	assert_true(fifth_terminal.interact(), "Fifth terminal should accept the second press")
	await create_timer(0.8).timeout

	var sixth_terminal := game.get_node(terminal_paths[5])
	assert_true(sixth_terminal.interact(), "Sixth terminal should accept interaction")
	await create_timer(1.8).timeout

	var office := game.get_node("OfficeLevel")
	assert_true(not (office.get_node("CubicleGrid") as Node3D).visible, "Cubicle grid should disappear after the sixth terminal")
	assert_true(not (office.get_node("OfficeProps") as Node3D).visible, "Office props should disappear after the sixth terminal")
	assert_true((office.get_node("PerimeterWalls") as Node3D).visible, "Perimeter walls should remain visible")

	var exit_door := office.get_node("ExitDoor")
	assert_true(exit_door.visible, "Exit door should appear after the sixth terminal")
	assert_equal(exit_door.get_prompt_text(), "E - открыть дверь", "Exit door should expose the door prompt")

	quit()

func assert_true(condition: bool, message: String) -> void:
	if condition:
		print("ASSERT PASS: %s" % message)
		return
	push_error("ASSERT FAIL: %s" % message)
	quit(1)

func assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	assert_true(actual == expected, "%s (expected %s, got %s)" % [message, expected, actual])

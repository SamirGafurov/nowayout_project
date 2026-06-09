extends SceneTree

const GAME_SCENE := preload("res://scenes/game.tscn")

func _initialize() -> void:
	var game := GAME_SCENE.instantiate()
	get_root().add_child(game)
	await process_frame

	var terminal_paths := [
		"OfficeLevel/CubicleGrid/Cubicle02/Desk/ComputerTerminal",
		"OfficeLevel/CubicleGrid/Cubicle04/Desk/ComputerTerminal",
		"OfficeLevel/CubicleGrid/Cubicle05/Desk/ComputerTerminal"
	]

	for path in terminal_paths:
		var terminal := game.get_node(path)
		assert_true(terminal.interact(), "Terminal should accept scripted interaction for %s" % path)

	await create_timer(0.05).timeout
	assert_true(_all_lights_off(game), "Third shutdown should start with full blackout")

	await create_timer(1.1).timeout
	assert_true(_lights_restored(game), "Normal office lighting should return during the chair reveal")
	assert_true(_chairs_are_on_ceiling(game), "Chairs should move to the ceiling during the reveal")

	await create_timer(2.4).timeout
	assert_true(_lights_restored(game), "Lights should return to normal after the event")
	assert_true(_chairs_restored(game), "Chairs should return to their original places after the event")

	quit()

func _all_lights_off(game: Node) -> bool:
	for node in game.find_children("*", "SpotLight3D", true, false):
		var light := node as SpotLight3D
		if light != null and light.light_energy > 0.01:
			return false
	return true

func _chairs_are_on_ceiling(game: Node) -> bool:
	for node in game.find_children("Chair", "Node3D", true, false):
		var chair := node as Node3D
		if chair != null and chair.position.y > 2.5:
			return true
	return false

func _lights_restored(game: Node) -> bool:
	for node in game.find_children("*", "SpotLight3D", true, false):
		var light := node as SpotLight3D
		if light != null and light.light_energy > 1.4 and light.light_color.b > 0.8:
			return true
	return false

func _chairs_restored(game: Node) -> bool:
	for node in game.find_children("Chair", "Node3D", true, false):
		var chair := node as Node3D
		if chair != null and is_equal_approx(chair.position.y, 0.0):
			return true
	return false

func assert_true(condition: bool, message: String) -> void:
	if condition:
		print("ASSERT PASS: %s" % message)
		return

	push_error("ASSERT FAIL: %s" % message)
	quit(1)

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
		"OfficeLevel/CubicleGrid/Cubicle06/Desk/ComputerTerminal"
	]

	for index in range(3):
		var terminal := game.get_node(terminal_paths[index])
		assert_true(terminal.interact(), "Terminal should accept scripted interaction for %s" % terminal_paths[index])

	await create_timer(3.8).timeout

	var fourth_terminal := game.get_node(terminal_paths[3])
	assert_true(fourth_terminal.interact(), "Fourth terminal should trigger the runner event")

	await create_timer(0.2).timeout
	var runner := game.get_node_or_null("OfficeLevel/RunnerWomanEvent") as Node3D
	assert_true(runner != null, "Fourth shutdown should spawn the runner apparition")
	var runner_bounds := _get_combined_mesh_aabb(runner)
	assert_true(runner_bounds.size.y > 6.2, "Runner apparition should be large enough to read clearly")

	await create_timer(6.8).timeout
	assert_true(game.get_node_or_null("OfficeLevel/RunnerWomanEvent") == null, "Runner apparition should disappear after the sprint")

	quit()

func assert_true(condition: bool, message: String) -> void:
	if condition:
		print("ASSERT PASS: %s" % message)
		return

	push_error("ASSERT FAIL: %s" % message)
	quit(1)

func _get_combined_mesh_aabb(root: Node3D) -> AABB:
	var has_aabb := false
	var combined := AABB()

	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue

		var transformed_aabb: AABB = mesh_instance.global_transform * mesh_instance.mesh.get_aabb()
		if not has_aabb:
			combined = transformed_aabb
			has_aabb = true
		else:
			combined = combined.merge(transformed_aabb)

	return combined

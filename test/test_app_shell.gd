extends SceneTree

const APP_SCENE := preload("res://scenes/app.tscn")

func _initialize() -> void:
	var app := APP_SCENE.instantiate()
	get_root().add_child(app)
	await process_frame

	assert_true(app.get_node("UILayer/MenuRoot").visible, "Main menu should be visible on boot")
	assert_true(not app.get_node("UILayer/LoadingRoot").visible, "Loading screen should start hidden")
	assert_true(not app.get_node("UILayer/PauseRoot").visible, "Pause screen should start hidden")

	app.start_game()
	assert_true(app.get_node("UILayer/LoadingRoot").visible, "Loading screen should appear after starting the game")

	var timeout_frames := 0
	while app.get_node_or_null("GameMount/Game") == null and timeout_frames < 1200:
		await process_frame
		timeout_frames += 1

	assert_true(app.get_node_or_null("GameMount/Game") != null, "Game should load into the shell")
	assert_true(not app.get_node("UILayer/MenuRoot").visible, "Main menu should hide after the game loads")

	var intro_timeout_frames := 0
	while app.get_node("UILayer/IntroRoot").visible and intro_timeout_frames < 1200:
		await process_frame
		intro_timeout_frames += 1

	assert_true(not app.get_node("UILayer/IntroRoot").visible, "Intro should finish before the game becomes interactive")

	app.toggle_pause_menu()
	assert_true(app.get_tree().paused, "Pause should freeze the scene tree")
	assert_true(app.get_node("UILayer/PauseRoot").visible, "Pause menu should become visible")

	app.resume_game()
	assert_true(not app.get_tree().paused, "Resume should unpause the scene tree")
	assert_true(not app.get_node("UILayer/PauseRoot").visible, "Pause menu should hide after resume")

	app.return_to_main_menu()
	await process_frame
	assert_true(app.get_node("UILayer/MenuRoot").visible, "Returning should bring the user back to the main menu")
	assert_true(app.get_node_or_null("GameMount/Game") == null, "Game instance should be removed when returning to menu")

	quit()

func assert_true(condition: bool, message: String) -> void:
	if condition:
		print("ASSERT PASS: %s" % message)
		return
	push_error("ASSERT FAIL: %s" % message)
	quit(1)

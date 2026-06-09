extends SceneTree

const RUNNER_WOMAN_SCENE := preload("res://assets/models/office_runner_woman.glb")
const ANIMATION_NAME := "Armature|running"

func _initialize() -> void:
	var runner := RUNNER_WOMAN_SCENE.instantiate()
	get_root().add_child(runner)
	await process_frame

	var animation_player := runner.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if animation_player == null:
		push_error("No AnimationPlayer found")
		quit(1)
		return

	var animation := animation_player.get_animation(ANIMATION_NAME)
	if animation == null:
		push_error("Animation not found: %s" % ANIMATION_NAME)
		quit(1)
		return

	print("TRACK_COUNT=%d" % animation.get_track_count())
	for i in range(animation.get_track_count()):
		var track_type: int = animation.track_get_type(i)
		var track_path: NodePath = animation.track_get_path(i)
		print("TRACK %d TYPE=%s PATH=%s" % [i, track_type, track_path])
		var key_count: int = animation.track_get_key_count(i)
		var limit: int = min(key_count, 3)
		for key_index in range(limit):
			print("  KEY %d TIME=%.3f VAL=%s" % [
				key_index,
				animation.track_get_key_time(i, key_index),
				animation.track_get_key_value(i, key_index)
			])

	quit()

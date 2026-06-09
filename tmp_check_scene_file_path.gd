extends SceneTree
const DESK := preload("res://assets/models/office_desk.glb")
const CHAIR := preload("res://assets/models/office_chair.glb")
func _initialize() -> void:
	var d = DESK.instantiate()
	var c = CHAIR.instantiate()
	print('desk root', d.name, ' scene_file_path=', d.scene_file_path)
	for child in d.get_children():
		print(' desk child', child.name, ' scene_file_path=', child.scene_file_path)
	print('chair root', c.name, ' scene_file_path=', c.scene_file_path)
	for child in c.get_children():
		print(' chair child', child.name, ' scene_file_path=', child.scene_file_path)
	quit()

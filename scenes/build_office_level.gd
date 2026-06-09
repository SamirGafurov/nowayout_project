extends SceneTree

const SCENE_PATH := "res://scenes/office_level.tscn"
const OFFICE_LAYOUT_SYNC_SCRIPT := preload("res://scenes/terminal_layout_sync.gd")
const OFFICE_CHAIR_SCENE := preload("res://assets/models/office_chair.glb")
const OFFICE_WORKSTATION_SCENE := preload("res://assets/models/office_desk.glb")
const COMPUTER_TERMINAL_SCRIPT := preload("res://scenes/computer_terminal.gd")
const WATER_COOLER_SCENE := preload("res://assets/models/water_cooler.glb")
const SERVER_RACK_SCENE := preload("res://assets/models/server-rack.glb")
const CEILING_LIGHT_SCENE := preload("res://assets/models/ceiling_lights.glb")
const OFFICE_FLOOR_TEXTURE := preload("res://assets/textures/office_floor_albedo.png")
const OFFICE_WALL_TEXTURE := preload("res://assets/textures/office_wall_albedo.png")
const OFFICE_CARPET_TEXTURE := preload("res://assets/textures/office_carpet_albedo.png")
const OFFICE_PARTITION_TEXTURE := preload("res://assets/textures/office_partition_albedo.png")
const OFFICE_CHAIR_SCALE := 0.13
const OFFICE_CHAIR_BASE_OFFSET := Vector3(-0.025, 0.569, 0.0)
const OFFICE_CHAIR_MODEL_ROTATION := 180.0
const OFFICE_CHAIR_COLLIDER_SIZE := Vector3(0.75, 1.15, 0.75)
const OFFICE_CHAIR_COLLIDER_OFFSET := Vector3(0.0, 0.58, 0.0)
const OFFICE_WORKSTATION_SCALE := 1.55
const OFFICE_WORKSTATION_BASE_OFFSET := Vector3(0.0, 0.775, 0.0)
const OFFICE_WORKSTATION_MODEL_ROTATION := 270.0
const OFFICE_WORKSTATION_COLLIDER_SIZE := Vector3(1.55, 0.82, 0.82)
const OFFICE_WORKSTATION_COLLIDER_OFFSET := Vector3(0.0, 0.41, -0.02)
const COMPUTER_TERMINAL_SCREEN_OFFSET := Vector3(0.0, 1.52, -0.62)
const COMPUTER_TERMINAL_SCALE := Vector3.ONE * 1.44
const COMPUTER_TERMINAL_INTERACT_SIZE := Vector3(0.42, 0.24, 0.08)
const COMPUTER_TERMINAL_SEED := 46031
const ACTIVE_COMPUTER_COUNT := 6
const WATER_COOLER_SCALE := 2.32
const WATER_COOLER_BASE_OFFSET := Vector3(0.0, 1.16, 0.0)
const WATER_COOLER_MODEL_ROTATION := 180.0
const WATER_COOLER_COLLIDER_SIZE := Vector3(0.9, 2.15, 0.9)
const WATER_COOLER_COLLIDER_OFFSET := Vector3(0.0, 1.08, 0.0)
const SERVER_RACK_SCALE := 5.4
const SERVER_RACK_BASE_OFFSET := Vector3(0.0, 0.0, 0.0)
const SERVER_RACK_MODEL_ROTATION := 0.0
const CEILING_LIGHT_SCALE := 1.45
const CEILING_LIGHT_BASE_OFFSET := Vector3(0.0, 0.78, 0.0)
const CEILING_LIGHT_MODEL_ROTATION := 90.0
const STORAGE_CABINET_SCENE := preload("res://assets/models/storage_cabinet.glb")
const STORAGE_CABINET_SCALE := 1.5725
const STORAGE_CABINET_BASE_OFFSET := Vector3(-0.0185, 0.89725, -1.665)
const STORAGE_CABINET_MODEL_ROTATION := 180.0
const STORAGE_CABINET_COLLIDER_SIZE := Vector3(1.3, 2.75, 0.95)
const STORAGE_CABINET_COLLIDER_OFFSET := Vector3(-0.02, 1.35, -1.66)

func _initialize() -> void:
	var office := build_office()
	assign_owner_recursive(office, office)

	var packed := PackedScene.new()
	var pack_result := packed.pack(office)
	if pack_result != OK:
		push_error("Failed to pack office scene: %s" % pack_result)
		quit(1)
		return

	var instance := packed.instantiate()
	if instance.get_child_count() == 0:
		push_error("Packed office scene has no children.")
		quit(1)
		return

	var save_result := ResourceSaver.save(packed, SCENE_PATH)
	if save_result != OK:
		push_error("Failed to save office scene: %s" % save_result)
		instance.free()
		office.free()
		quit(1)
		return

	var header_result := ensure_scene_header(SCENE_PATH)
	if header_result != OK:
		push_error("Failed to normalize scene header: %s" % header_result)
		instance.free()
		office.free()
		quit(1)
		return

	instance.free()
	office.free()
	quit()

func build_office() -> Node3D:
	var root := Node3D.new()
	root.name = "OfficeLevel"
	root.set_script(OFFICE_LAYOUT_SYNC_SCRIPT)

	var environment := WorldEnvironment.new()
	environment.name = "WorldEnvironment"
	environment.environment = create_environment()
	root.add_child(environment)

	var sun_pivot := Node3D.new()
	sun_pivot.name = "SunPivot"
	sun_pivot.rotation_degrees = Vector3(-48.0, -30.0, 0.0)
	root.add_child(sun_pivot)

	var sun := DirectionalLight3D.new()
	sun.name = "DirectionalLight3D"
	sun.light_energy = 0.0
	sun.shadow_enabled = false
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sun_pivot.add_child(sun)

	var floor := create_box("Floor", Vector3(24.0, 0.2, 18.0), Vector3(0.0, -0.1, 0.0), Color(0.16, 0.17, 0.18))
	root.add_child(floor)
	root.add_child(create_floor_surface("FloorSurface", Vector2(24.0, 18.0), Vector3(0.0, 0.001, 0.0), OFFICE_FLOOR_TEXTURE, Vector3(8.0, 1.0, 6.0)))

	var ceiling := create_box("Ceiling", Vector3(24.0, 0.12, 18.0), Vector3(0.0, 3.8, 0.0), Color(0.76, 0.78, 0.82))
	root.add_child(ceiling)

	var perimeter := Node3D.new()
	perimeter.name = "PerimeterWalls"
	root.add_child(perimeter)
	build_perimeter_walls(perimeter)

	var hallway := create_box("HallRunner", Vector3(2.2, 0.03, 16.2), Vector3(0.0, 0.02, 0.0), Color(0.20, 0.20, 0.22))
	root.add_child(hallway)

	var desks := Node3D.new()
	desks.name = "CubicleGrid"
	root.add_child(desks)
	build_cubicles(desks)

	var props := Node3D.new()
	props.name = "OfficeProps"
	root.add_child(props)
	build_props(props)

	var lights := Node3D.new()
	lights.name = "CeilingLights"
	root.add_child(lights)
	build_ceiling_lights(lights)

	var camera_rig := Node3D.new()
	camera_rig.name = "CameraRig"
	root.add_child(camera_rig)

	var camera := Camera3D.new()
	camera.name = "MainCamera"
	camera.current = true
	camera.look_at_from_position(Vector3(0.0, 4.6, 11.8), Vector3(0.0, 1.1, 0.0), Vector3.UP)
	camera.fov = 55.0
	camera_rig.add_child(camera)

	return root

func build_perimeter_walls(parent: Node3D) -> void:
	parent.add_child(create_box("NorthWall", Vector3(24.0, 4.0, 0.25), Vector3(0.0, 1.9, -9.0), Color(1.0, 1.0, 1.0), OFFICE_WALL_TEXTURE, Vector3(6.0, 1.0, 1.0)))
	parent.add_child(create_box("SouthWall", Vector3(24.0, 4.0, 0.25), Vector3(0.0, 1.9, 9.0), Color(1.0, 1.0, 1.0), OFFICE_WALL_TEXTURE, Vector3(6.0, 1.0, 1.0)))
	parent.add_child(create_box("WestWall", Vector3(0.25, 4.0, 18.0), Vector3(-12.0, 1.9, 0.0), Color(1.0, 1.0, 1.0), OFFICE_WALL_TEXTURE, Vector3(4.5, 1.0, 1.0)))
	parent.add_child(create_box("EastWall", Vector3(0.25, 4.0, 18.0), Vector3(12.0, 1.9, 0.0), Color(1.0, 1.0, 1.0), OFFICE_WALL_TEXTURE, Vector3(4.5, 1.0, 1.0)))

func build_cubicles(parent: Node3D) -> void:
	var x_positions := [-7.2, -2.4, 2.4, 7.2]
	var z_positions := [-5.0, 0.0, 5.0]
	var cubicle_index := 1
	var active_indices := pick_active_computer_indices(12, ACTIVE_COMPUTER_COUNT)

	for z in z_positions:
		for x in x_positions:
			var cubicle := Node3D.new()
			cubicle.name = "Cubicle%02d" % cubicle_index
			cubicle.position = Vector3(x, 0.0, z)
			parent.add_child(cubicle)
			build_single_cubicle(cubicle, cubicle_index, active_indices.has(cubicle_index))
			cubicle_index += 1

func build_single_cubicle(parent: Node3D, cubicle_index: int, computer_is_active: bool) -> void:
	parent.add_child(create_box("Carpet", Vector3(3.2, 0.02, 3.2), Vector3(0.0, 0.01, 0.0), Color(1.0, 1.0, 1.0), OFFICE_CARPET_TEXTURE, Vector3(1.0, 1.0, 1.0)))

	var wall_color := Color(1.0, 1.0, 1.0)
	parent.add_child(create_box("BackPartition", Vector3(3.0, 1.55, 0.08), Vector3(0.0, 0.78, -1.45), wall_color, OFFICE_PARTITION_TEXTURE, Vector3(1.2, 1.0, 1.0)))
	parent.add_child(create_box_collider("BackPartitionCollider", Vector3(3.0, 1.55, 0.08), Vector3(0.0, 0.78, -1.45)))
	parent.add_child(create_box("LeftPartition", Vector3(0.08, 1.55, 2.9), Vector3(-1.46, 0.78, 0.0), wall_color, OFFICE_PARTITION_TEXTURE, Vector3(1.16, 1.0, 1.0)))
	parent.add_child(create_box_collider("LeftPartitionCollider", Vector3(0.08, 1.55, 2.9), Vector3(-1.46, 0.78, 0.0)))
	parent.add_child(create_box("RightPartition", Vector3(0.08, 1.55, 2.9), Vector3(1.46, 0.78, 0.0), wall_color, OFFICE_PARTITION_TEXTURE, Vector3(1.16, 1.0, 1.0)))
	parent.add_child(create_box_collider("RightPartitionCollider", Vector3(0.08, 1.55, 2.9), Vector3(1.46, 0.78, 0.0)))

	var desk := create_office_workstation("Desk", Vector3(0.0, 0.0, -0.72), 0.0)
	parent.add_child(desk)
	if computer_is_active:
		desk.add_child(create_computer_terminal("ComputerTerminal"))

	parent.add_child(create_office_chair("Chair", Vector3(0.0, 0.0, 0.35), 180.0))

func build_props(parent: Node3D) -> void:
	parent.add_child(create_storage_cabinet("StorageCabinetA", Vector3(-11.35, -0.9, -7.45), 180.0))
	parent.add_child(create_storage_cabinet("StorageCabinetB", Vector3(-11.35, -0.9, -5.75), 180.0))
	parent.add_child(create_water_cooler("WaterCooler", Vector3(10.7, 0.0, -8.15), 90.0))

func build_ceiling_lights(parent: Node3D) -> void:
	var x_positions := [-8.0, -2.7, 2.7, 8.0]
	var z_positions := [-5.8, 0.0, 5.8]
	var fixture_index := 1

	for z in z_positions:
		for x in x_positions:
			var fixture := Node3D.new()
			fixture.name = "LightFixture%02d" % fixture_index
			fixture.position = Vector3(x, 3.55, z)
			parent.add_child(fixture)
			fixture_index += 1

			fixture.add_child(create_ceiling_light_model("FixtureBody", Vector3.ZERO, 0.0))

			var spot := SpotLight3D.new()
			spot.name = "SpotLight3D"
			spot.position = Vector3(0.0, -0.18, 0.0)
			spot.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
			spot.light_color = Color(0.80, 0.88, 0.96)
			spot.light_energy = 1.55
			spot.spot_range = 9.6
			spot.spot_angle = 80.0
			spot.spot_angle_attenuation = 0.82
			spot.shadow_enabled = false
			fixture.add_child(spot)

func create_box(name: String, size: Vector3, pos: Vector3, color: Color, albedo_texture: Texture2D = null, uv_scale: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	mesh_instance.position = pos

	var box := BoxMesh.new()
	box.size = size
	box.material = create_material(color, albedo_texture, uv_scale)
	mesh_instance.mesh = box
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return mesh_instance

func create_floor_surface(name: String, size: Vector2, pos: Vector3, albedo_texture: Texture2D, uv_scale: Vector3) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	mesh_instance.position = pos
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var plane := PlaneMesh.new()
	plane.size = size
	plane.material = create_material(Color(1.0, 1.0, 1.0), albedo_texture, uv_scale)
	mesh_instance.mesh = plane
	return mesh_instance

func create_office_chair(name: String, pos: Vector3, yaw_degrees: float) -> Node3D:
	var holder := Node3D.new()
	holder.name = name
	holder.position = pos
	holder.rotation_degrees = Vector3(0.0, yaw_degrees, 0.0)

	var chair_instance := OFFICE_CHAIR_SCENE.instantiate()
	chair_instance.position = OFFICE_CHAIR_BASE_OFFSET
	chair_instance.rotation_degrees = Vector3(0.0, OFFICE_CHAIR_MODEL_ROTATION, 0.0)
	chair_instance.scale = Vector3.ONE * OFFICE_CHAIR_SCALE
	holder.add_child(chair_instance)
	holder.add_child(create_local_box_collider("ChairCollider", OFFICE_CHAIR_COLLIDER_SIZE, OFFICE_CHAIR_COLLIDER_OFFSET))
	return holder

func create_office_workstation(name: String, pos: Vector3, yaw_degrees: float) -> Node3D:
	var holder := Node3D.new()
	holder.name = name
	holder.position = pos
	holder.rotation_degrees = Vector3(0.0, yaw_degrees, 0.0)

	var workstation_instance := OFFICE_WORKSTATION_SCENE.instantiate()
	workstation_instance.position = OFFICE_WORKSTATION_BASE_OFFSET
	workstation_instance.rotation_degrees = Vector3(0.0, OFFICE_WORKSTATION_MODEL_ROTATION, 0.0)
	workstation_instance.scale = Vector3.ONE * OFFICE_WORKSTATION_SCALE
	holder.add_child(workstation_instance)
	holder.add_child(create_local_box_collider("DeskCollider", OFFICE_WORKSTATION_COLLIDER_SIZE, OFFICE_WORKSTATION_COLLIDER_OFFSET))
	return holder

func create_water_cooler(name: String, pos: Vector3, yaw_degrees: float) -> Node3D:
	var holder := Node3D.new()
	holder.name = name
	holder.position = pos
	holder.rotation_degrees = Vector3(0.0, yaw_degrees, 0.0)

	var cooler_instance := WATER_COOLER_SCENE.instantiate()
	cooler_instance.position = WATER_COOLER_BASE_OFFSET
	cooler_instance.rotation_degrees = Vector3(0.0, WATER_COOLER_MODEL_ROTATION, 0.0)
	cooler_instance.scale = Vector3.ONE * WATER_COOLER_SCALE
	holder.add_child(cooler_instance)

	holder.add_child(create_local_box_collider("WaterCoolerCollider", WATER_COOLER_COLLIDER_SIZE, WATER_COOLER_COLLIDER_OFFSET))
	return holder

func create_computer_terminal(name: String) -> Node3D:
	var terminal := Node3D.new()
	terminal.name = name
	terminal.position = COMPUTER_TERMINAL_SCREEN_OFFSET
	terminal.scale = COMPUTER_TERMINAL_SCALE
	terminal.set_script(COMPUTER_TERMINAL_SCRIPT)

	var interact_area := Area3D.new()
	interact_area.name = "InteractArea"
	interact_area.collision_layer = 1 << 9
	interact_area.collision_mask = 0
	interact_area.monitorable = false
	interact_area.position = Vector3(0.0, -0.02, 0.012)
	interact_area.rotation_degrees = Vector3(-8.0, 180.0, 0.0)
	terminal.add_child(interact_area)

	var collision_shape := CollisionShape3D.new()
	collision_shape.name = "InteractShape"
	var interaction_box := BoxShape3D.new()
	interaction_box.size = COMPUTER_TERMINAL_INTERACT_SIZE
	collision_shape.shape = interaction_box
	interact_area.add_child(collision_shape)
	return terminal

func create_storage_cabinet(name: String, pos: Vector3, yaw_degrees: float) -> Node3D:
	var holder := Node3D.new()
	holder.name = name
	holder.position = pos
	holder.rotation_degrees = Vector3(0.0, yaw_degrees, 0.0)

	var cabinet_instance := STORAGE_CABINET_SCENE.instantiate()
	cabinet_instance.position = STORAGE_CABINET_BASE_OFFSET
	cabinet_instance.rotation_degrees = Vector3(0.0, STORAGE_CABINET_MODEL_ROTATION, 0.0)
	cabinet_instance.scale = Vector3.ONE * STORAGE_CABINET_SCALE
	holder.add_child(cabinet_instance)
	holder.add_child(create_local_box_collider("%sCollider" % name, STORAGE_CABINET_COLLIDER_SIZE, STORAGE_CABINET_COLLIDER_OFFSET))
	return holder

func create_ceiling_light_model(name: String, pos: Vector3, yaw_degrees: float) -> Node3D:
	var holder := Node3D.new()
	holder.name = name
	holder.position = pos
	holder.rotation_degrees = Vector3(0.0, yaw_degrees, 0.0)

	var light_instance := CEILING_LIGHT_SCENE.instantiate()
	light_instance.position = CEILING_LIGHT_BASE_OFFSET
	light_instance.rotation_degrees = Vector3(0.0, CEILING_LIGHT_MODEL_ROTATION, 0.0)
	light_instance.scale = Vector3.ONE * CEILING_LIGHT_SCALE
	holder.add_child(light_instance)
	return holder

func create_material(color: Color, albedo_texture: Texture2D = null, uv_scale: Vector3 = Vector3.ONE) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.albedo_texture = albedo_texture
	material.uv1_scale = uv_scale
	material.roughness = 0.92
	material.metallic = 0.06
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material

func create_box_collider(name: String, size: Vector3, pos: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = name
	body.position = pos

	var collision_shape := CollisionShape3D.new()
	collision_shape.shape = create_box_shape(size)
	body.add_child(collision_shape)
	return body

func create_local_box_collider(name: String, size: Vector3, pos: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = name
	body.position = pos

	var collision_shape := CollisionShape3D.new()
	collision_shape.shape = create_box_shape(size)
	body.add_child(collision_shape)
	return body

func create_box_shape(size: Vector3) -> BoxShape3D:
	var shape := BoxShape3D.new()
	shape.size = size
	return shape

func pick_active_computer_indices(total_count: int, active_count: int) -> Array[int]:
	var indices: Array[int] = []
	for index in range(1, total_count + 1):
		indices.append(index)

	var rng := RandomNumberGenerator.new()
	rng.seed = COMPUTER_TERMINAL_SEED
	for index in range(indices.size() - 1, 0, -1):
		var swap_index := rng.randi_range(0, index)
		var temp := indices[index]
		indices[index] = indices[swap_index]
		indices[swap_index] = temp

	var picked: Array[int] = indices.slice(0, active_count)
	picked.sort()
	return picked

func brighten_meshes(node: Node, emission_color: Color, emission_strength: float) -> void:
	if node is MeshInstance3D and node.mesh != null:
		var mesh_instance: MeshInstance3D = node
		var mesh: Mesh = mesh_instance.mesh
		for surface_index in mesh.get_surface_count():
			var source_material: Material = mesh_instance.get_active_material(surface_index)
			if source_material == null:
				source_material = mesh.surface_get_material(surface_index)

			var material := StandardMaterial3D.new()
			if source_material is StandardMaterial3D:
				material = source_material.duplicate()

			material.albedo_color = material.albedo_color.lerp(Color(1.0, 1.0, 1.0), 0.42)
			material.emission_enabled = true
			material.emission = emission_color
			material.emission_energy_multiplier = emission_strength
			material.roughness = max(material.roughness - 0.16, 0.32)
			mesh_instance.set_surface_override_material(surface_index, material)

	for child in node.get_children():
		brighten_meshes(child, emission_color, emission_strength)

func create_environment() -> Environment:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.035, 0.040, 0.052)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.34, 0.38, 0.45)
	environment.ambient_light_energy = 0.56
	environment.ssr_enabled = false
	environment.ssao_enabled = false
	environment.glow_enabled = true
	environment.glow_intensity = 0.46
	environment.glow_strength = 0.38
	environment.glow_bloom = 0.04
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.14, 0.16, 0.20)
	environment.fog_density = 0.013
	environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	environment.adjustment_enabled = true
	environment.adjustment_brightness = 0.92
	environment.adjustment_contrast = 1.06
	environment.adjustment_saturation = 0.82
	return environment

func assign_owner_recursive(node: Node, owner: Node) -> void:
	for child in node.get_children():
		child.owner = owner
		if child.scene_file_path.is_empty():
			assign_owner_recursive(child, owner)

func ensure_scene_header(scene_path: String) -> int:
	var file := FileAccess.open(scene_path, FileAccess.READ)
	if file == null:
		return ERR_CANT_OPEN

	var content := file.get_as_text()
	file.close()

	var line_ending := "\r\n" if content.contains("\r\n") else "\n"
	var lines := content.split(line_ending, false)
	if lines.is_empty():
		return ERR_PARSE_ERROR

	var load_steps := 1
	for line in lines:
		if line.begins_with("[sub_resource") or line.begins_with("[ext_resource"):
			load_steps += 1

	lines[0] = "[gd_scene load_steps=%d format=3]" % load_steps

	file = FileAccess.open(scene_path, FileAccess.WRITE)
	if file == null:
		return ERR_CANT_OPEN

	file.store_string(line_ending.join(lines))
	file.close()
	return OK

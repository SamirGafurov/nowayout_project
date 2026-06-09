extends SceneTree

const OFFICE_SCENE := preload("res://scenes/office_level.tscn")

func _initialize() -> void:
	var office := OFFICE_SCENE.instantiate()
	get_root().add_child(office)

	assert_equal(count_name_prefix(office, "Cubicle0"), 9, "Expected the first nine cubicles to be present")
	assert_equal(count_name_prefix(office, "Cubicle1"), 3, "Expected the remaining three cubicles to be present")
	assert_equal(count_name(office, "Desk"), 12, "Each cubicle should have one workstation")
	assert_equal(count_name(office, "Chair"), 12, "Each cubicle should have one desk chair")
	assert_equal(count_name(office, "ComputerTerminal"), 6, "Exactly six computers should start powered on")
	assert_equal(count_name(office, "InteractArea"), 6, "Each active computer should provide a direct interaction area")
	assert_equal(count_name(office, "DeskCollider"), 12, "Each workstation should provide a desk collider")
	assert_equal(count_name(office, "ChairCollider"), 12, "Each desk chair should provide a collider")
	assert_equal(count_name(office, "BackPartitionCollider"), 12, "Each cubicle should have a back partition collider")
	assert_equal(count_name(office, "LeftPartitionCollider"), 12, "Each cubicle should have a left partition collider")
	assert_equal(count_name(office, "RightPartitionCollider"), 12, "Each cubicle should have a right partition collider")
	assert_equal(count_name(office, "StorageCabinetACollider"), 1, "StorageCabinetA should provide a collider")
	assert_equal(count_name(office, "StorageCabinetBCollider"), 1, "StorageCabinetB should provide a collider")
	assert_true(count_name_prefix(office, "WaterCoolerCollider") > 0, "Water cooler should provide a collider")
	assert_equal(count_children_with_prefix(office.get_node("CeilingLights"), "LightFixture"), 12, "Ceiling light layout should cover the office evenly")
	assert_true(office.has_node("CameraRig/MainCamera"), "Office scene should include a main camera")

	quit()

func count_name(root: Node, needle: String) -> int:
	var total := 0
	if String(root.name) == needle:
		total += 1

	for child in root.get_children():
		total += count_name(child, needle)

	return total

func count_name_prefix(root: Node, prefix: String) -> int:
	var total := 0
	if String(root.name).begins_with(prefix):
		total += 1

	for child in root.get_children():
		total += count_name_prefix(child, prefix)

	return total

func count_children_with_prefix(root: Node, prefix: String) -> int:
	var total := 0
	for child in root.get_children():
		if String(child.name).begins_with(prefix):
			total += 1

	return total

func assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	if actual == expected:
		print("ASSERT PASS: %s (%s)" % [message, actual])
		return

	push_error("ASSERT FAIL: %s (expected %s, got %s)" % [message, expected, actual])
	quit(1)

func assert_true(condition: bool, message: String) -> void:
	if condition:
		print("ASSERT PASS: %s" % message)
		return

	push_error("ASSERT FAIL: %s" % message)
	quit(1)

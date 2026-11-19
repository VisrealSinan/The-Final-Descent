extends SceneTree
## Packs only runtime dependencies, excluding concepts, credentials and unrelated files.

func _initialize() -> void:
	var destination := "res://builds/dungeon/TheFinalDescent.pck"
	var packer := PCKPacker.new()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(destination.get_base_dir()))
	if packer.pck_start(ProjectSettings.globalize_path(destination)) != OK:
		push_error("Could not create the combat package")
		quit(1)
		return
	var paths: Array[String] = ["res://project.godot", "res://assets/characters/visreal/visreal_frames.tres", "res://assets/characters/visreal/visreal_visual.tscn"]
	for name in DirAccess.get_files_at("res://game"):
		if name.get_extension() in ["gd", "tscn"]:
			paths.append("res://game/" + name)
	for name: String in ["idle", "walk", "attack", "hurt", "death"]:
		var path := "res://assets/characters/visreal/" + name + ".png"
		paths.append(path)
		paths.append(path + ".import")
		var config := ConfigFile.new()
		if config.load(path + ".import") != OK:
			push_error("Missing imported sprite sheet: " + path)
			quit(1)
			return
		paths.append(config.get_value("remap", "path"))
	for path in paths:
		if packer.add_file(path, ProjectSettings.globalize_path(path)) != OK:
			push_error("Could not pack " + path)
			quit(1)
			return
	var result := packer.flush()
	print("Packed %d runtime files into %s" % [paths.size(), destination])
	quit(0 if result == OK else 1)

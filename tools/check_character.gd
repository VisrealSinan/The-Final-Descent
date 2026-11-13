extends SceneTree

var character_id := "visreal"
var root_path := "res://assets/characters/visreal/"

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg in ["visreal", "han", "ghalrym"]:
			character_id = arg
	root_path = "res://assets/characters/" + character_id + "/"
	call_deferred("check_pack")

func fail(message: String) -> void:
	push_error(message)
	quit(1)

func check_pack() -> void:
	var resource := load(root_path + character_id + "_frames.tres") as SpriteFrames
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(root_path + character_id + ".atlas.json"))
	if resource == null or resource.get_animation_names().size() != 20 or manifest.frames.size() != 80:
		fail("Expected 20 animations and 80 frames")
		return
	var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(root_path + "validation.json"))
	for sheet in report.sheets.values():
		if sheet.boundary_opaque_pixels != 0:
			fail("A frame boundary crosses artwork")
			return
	var total := 0
	for animation in resource.get_animation_names():
		if resource.get_frame_count(animation) != 4:
			fail("Unexpected frame count: " + animation)
			return
		for index in resource.get_frame_count(animation):
			var atlas := resource.get_frame_texture(animation, index) as AtlasTexture
			if atlas == null or atlas.atlas == null or atlas.get_size() != Vector2(384, 384):
				fail("Invalid frame texture: " + animation + str(index))
				return
			if not Rect2(Vector2.ZERO, atlas.atlas.get_size()).encloses(atlas.region):
				fail("Frame outside its sheet")
				return
			var key := String(animation) + "_%02d" % index
			if not manifest.frames.has(key):
				fail("Manifest missing frame " + key)
				return
			total += 1
	var scene := load(root_path + character_id + "_visual.tscn") as PackedScene
	if scene == null:
		fail("Visual scene failed to load")
		return
	var visual := scene.instantiate()
	root.add_child(visual)
	var sprite := visual.get_node("AnimatedSprite2D") as AnimatedSprite2D
	sprite.play("death_south")
	await create_timer(0.85).timeout
	if sprite.is_playing() or sprite.frame != 3:
		fail("Death must finish on its final frame without looping")
		return
	sprite.play("walk_north")
	await create_timer(0.7).timeout
	if not sprite.is_playing():
		fail("Walk must continue looping")
		return
	print("PASS %s: clean load, 20 animations, %d valid frames, death stops, walk loops." % [character_id, total])
	visual.queue_free()
	quit(0)

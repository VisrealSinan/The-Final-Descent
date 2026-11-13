extends SceneTree

# Measures PNG atlas regions and writes Godot resources; never changes image pixels.
const ROOT := "res://assets/characters/visreal/"
const ACTIONS := ["idle", "walk", "attack", "hurt", "death"]
const DIRECTIONS := ["south", "west", "east", "north"]
const SPEEDS := {"idle": 5.0, "walk": 8.0, "attack": 10.0, "hurt": 10.0, "death": 6.0}
const CANVAS := Vector2i(384, 384)
const ANCHOR := Vector2(192, 348)

func _initialize() -> void:
	call_deferred("build")

func find_cut(projection: PackedInt32Array, ideal: int, radius: int) -> int:
	var chosen := ideal
	var score := INF
	for at in range(maxi(1, ideal - radius), mini(projection.size() - 1, ideal + radius)):
		var candidate := float(projection[at] + projection[at - 1]) * 1000.0 + absf(at - ideal)
		if candidate < score:
			score = candidate
			chosen = at
	return chosen

func build() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	var manifest := {"character": "Visreal", "version": 1, "canvas": [384, 384], "anchor": [192, 348], "directions": DIRECTIONS, "frames": {}, "animations": {}}
	var report := {"engine": Engine.get_version_info().string, "frame_count": 0, "sheets": {}}
	for action in ACTIONS:
		var path: String = ROOT + action + ".png"
		var image := Image.load_from_file(ProjectSettings.globalize_path(path))
		if image == null or image.is_empty() or not image.detect_alpha():
			push_error("Missing image or alpha: " + path)
			quit(1)
			return
		image.convert(Image.FORMAT_RGBA8)
		var pixels := image.get_data()
		var width := image.get_width()
		var height := image.get_height()
		var rows := PackedInt32Array()
		rows.resize(height)
		for y in height:
			for x in width:
				if pixels[(y * width + x) * 4 + 3] > 64:
					rows[y] += 1
		var ycuts := [0]
		for i in range(1, 4):
			ycuts.append(find_cut(rows, roundi(height * i / 4.0), 30))
		ycuts.append(height)
		var texture := load(path) as Texture2D
		if texture == null:
			push_error("Import PNGs in the editor before building resources")
			quit(1)
			return
		var sheet_report := {"dimensions": [width, height], "row_cuts": ycuts, "column_cuts": [], "boundary_opaque_pixels": 0}
		for row in 4:
			var columns := PackedInt32Array()
			columns.resize(width)
			for y in range(ycuts[row], ycuts[row + 1]):
				for x in width:
					if pixels[(y * width + x) * 4 + 3] > 64:
						columns[x] += 1
			var xcuts := [0]
			for i in range(1, 4):
				xcuts.append(find_cut(columns, roundi(width * i / 4.0), 52))
			xcuts.append(width)
			sheet_report.column_cuts.append(xcuts)
			var animation: String = action + "_" + DIRECTIONS[row]
			frames.add_animation(animation)
			frames.set_animation_speed(animation, SPEEDS[action])
			frames.set_animation_loop(animation, action in ["idle", "walk"])
			var names: Array[String] = []
			for col in 4:
				var min_point := Vector2i(width, height)
				var max_point := Vector2i(-1, -1)
				var count := 0
				for y in range(ycuts[row], ycuts[row + 1]):
					for x in range(xcuts[col], xcuts[col + 1]):
						if pixels[(y * width + x) * 4 + 3] > 24:
							min_point = min_point.min(Vector2i(x, y))
							max_point = max_point.max(Vector2i(x, y))
							count += 1
				if count < 1000:
					push_error("Empty or incomplete cell " + animation + str(col))
					quit(1)
					return
				min_point = (min_point - Vector2i(2, 2)).max(Vector2i(xcuts[col], ycuts[row]))
				max_point = (max_point + Vector2i(3, 3)).min(Vector2i(xcuts[col + 1], ycuts[row + 1]))
				var region := Rect2i(min_point, max_point - min_point)
				var source_anchor := Vector2(roundi((col + 0.5) * width / 4.0), roundi((row + 1.0) * height / 4.0) - 12)
				var padding := Vector2(region.position) + ANCHOR - source_anchor
				if padding.x < 0 or padding.y < 0 or padding.x + region.size.x > CANVAS.x or padding.y + region.size.y > CANVAS.y:
					push_error("Frame exceeds logical canvas: " + animation + str(col))
					quit(1)
					return
				var atlas := AtlasTexture.new()
				atlas.atlas = texture
				atlas.region = Rect2(region)
				atlas.margin = Rect2(padding, Vector2(CANVAS - region.size))
				atlas.filter_clip = true
				frames.add_frame(animation, atlas)
				var frame_name := animation + "_%02d" % col
				names.append(frame_name)
				manifest.frames[frame_name] = {"sheet": action + ".png", "region": [region.position.x, region.position.y, region.size.x, region.size.y], "offset": [int(padding.x), int(padding.y)], "canvas": [384, 384], "anchor": [192, 348]}
				report.frame_count += 1
			manifest.animations[animation] = {"fps": SPEEDS[action], "loop": action in ["idle", "walk"], "frames": names}
			for cut_index in range(1, 4):
				sheet_report.boundary_opaque_pixels += columns[xcuts[cut_index]]
		for i in range(1, 4):
			sheet_report.boundary_opaque_pixels += rows[ycuts[i]]
		if sheet_report.boundary_opaque_pixels > 0:
			push_error("Atlas cut intersects artwork: " + action)
			quit(1)
			return
		report.sheets[action] = sheet_report
	if ResourceSaver.save(frames, ROOT + "visreal_frames.tres") != OK:
		push_error("Could not save SpriteFrames")
		quit(1)
		return
	FileAccess.open(ROOT + "visreal.atlas.json", FileAccess.WRITE).store_string(JSON.stringify(manifest, "\t") + "\n")
	FileAccess.open(ROOT + "validation.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t") + "\n")
	print(JSON.stringify(report))
	quit(0)

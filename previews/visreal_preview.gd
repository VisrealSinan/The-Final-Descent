extends Node2D

const ACTIONS := ["idle", "walk", "attack", "hurt", "death"]
const DIRECTIONS := ["south", "west", "east", "north"]
const FRAMES := preload("res://assets/characters/visreal/visreal_frames.tres")
var sprites: Array[AnimatedSprite2D] = []
var paused := false
var automatic_replay := true
var light_backdrop := false

func label_at(text: String, at: Vector2, size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.position = at
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	add_child(label)

func _ready() -> void:
	label_at("THE FINAL DESCENT", Vector2(34, 20), 30, Color("e0d5c7"))
	label_at("VISREAL  /  SPRITE ANIMATION PREVIEW", Vector2(36, 61), 16, Color("c27379"))
	label_at("Space: pause   |   R: replay   |   Right: step while paused   |   T: change backdrop", Vector2(36, 855), 16, Color("a0a8b8"))
	for col in 5:
		label_at(ACTIONS[col].to_upper(), Vector2(142 + col * 234, 110), 18, Color("e0d5c7"))
	for row in 4:
		label_at(DIRECTIONS[row].to_upper(), Vector2(20, 228 + row * 180), 13, Color("b29da5"))
		for col in 5:
			var sprite := AnimatedSprite2D.new()
			sprite.sprite_frames = FRAMES
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			sprite.position = Vector2(186 + col * 234, 300 + row * 180)
			sprite.scale = Vector2(0.43, 0.43)
			sprite.offset = Vector2(0, -156)
			add_child(sprite)
			sprite.play(ACTIONS[col] + "_" + DIRECTIONS[row])
			sprites.append(sprite)
	var replay := Timer.new()
	replay.wait_time = 2.4
	replay.autostart = true
	replay.timeout.connect(func():
		if automatic_replay and not paused:
			for sprite in sprites:
				if not FRAMES.get_animation_loop(sprite.animation):
					sprite.frame = 0
					sprite.play()
	)
	add_child(replay)
	if "--capture" in OS.get_cmdline_user_args():
		automatic_replay = false
		for sprite in sprites:
			sprite.pause()
			sprite.frame = 2 if not String(sprite.animation).begins_with("death") else 3
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://previews/visreal-preview.png")
		get_tree().quit()

func _draw() -> void:
	for row in 4:
		for col in 5:
			var rectangle := Rect2(94 + col * 234, 140 + row * 180, 212, 166)
			draw_rect(rectangle, Color("b2a698") if light_backdrop else Color("151b26"))
			draw_rect(rectangle, Color("2c3444"), false, 1.0)
			draw_line(Vector2(rectangle.position.x + 12, rectangle.end.y - 6), Vector2(rectangle.end.x - 12, rectangle.end.y - 6), Color("3d4655"))

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_SPACE:
			paused = not paused
			for sprite in sprites:
				if paused:
					sprite.pause()
				else:
					sprite.play()
		KEY_R:
			for sprite in sprites:
				sprite.frame = 0
				if not paused:
					sprite.play()
		KEY_RIGHT:
			if paused:
				for sprite in sprites:
					sprite.frame = (sprite.frame + 1) % 4
		KEY_T:
			light_backdrop = not light_backdrop
			queue_redraw()

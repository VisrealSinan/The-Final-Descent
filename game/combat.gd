extends Node2D

const T = preload("res://game/tuning.gd")
const Player = preload("res://game/visreal.gd")
const Enemy = preload("res://game/enemy.gd")
const Controls = preload("res://game/controls.gd")
const ROOM := Rect2(48, 160, 908, 612)
const SPAWN := Vector2(350, 510)
const INK := Color("e8e0d5")
const MUTED := Color("9c9baa")
const GOLD := Color("d8b67e")

var player: CharacterBody2D
var actors: Node2D
var state := "ready"
var bout := 0
var kills := 0
var enemies_remaining := 0
var reward_claimed := false
var rewards: Array[String] = []
var rng := RandomNumberGenerator.new()
var last_reward := ""
var notice_left := 0.0
var floats: Array[Dictionary] = []
var motes_clock := 0.0
var ui: Control
var health_bar: ProgressBar
var health_label: Label
var round_label: Label
var enemy_label: Label
var notice: Label
var status_label: Label
var shadow_label: Label
var venom_label: Label
var passive_label: Label
var gear_labels: Dictionary = {}
var gear_panels: Dictionary = {}
var overlay: Panel
var overlay_title: Label
var overlay_copy: Label
var overlay_button: Button
var secondary_button: Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Controls.install()
	rng.randomize()
	actors = Node2D.new()
	actors.name = "Actors"
	actors.y_sort_enabled = true
	actors.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(actors)
	create_walls()
	create_ui()
	new_run()

func create_walls() -> void:
	# Feet stay inside the chamber; top padding keeps the tall sprite below the header.
	for rectangle: Rect2 in [Rect2(28, 140, 40, 652), Rect2(936, 140, 40, 652), Rect2(48, 140, 908, 118), Rect2(48, 752, 908, 40)]:
		var wall := StaticBody2D.new()
		wall.collision_layer = 1
		wall.collision_mask = 0
		wall.position = rectangle.get_center()
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rectangle.size
		collision.shape = shape
		wall.add_child(collision)
		add_child(wall)

func new_run() -> void:
	get_tree().paused = false
	for child in actors.get_children():
		child.set_physics_process(false)
		if child.is_in_group("enemies"):
			child.remove_from_group("enemies")
		if child.is_in_group("player"):
			child.remove_from_group("player")
		child.queue_free()
	player = Player.new()
	player.position = SPAWN
	actors.add_child(player)
	player.died.connect(on_player_died)
	player.skill_used.connect(on_skill_used)
	state = "ready"
	bout = 0
	kills = 0
	enemies_remaining = 0
	reward_claimed = false
	last_reward = ""
	notice_left = 0.0
	floats.clear()
	rewards.assign(T.SLOTS)
	for i in range(rewards.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var slot := rewards[i]
		rewards[i] = rewards[j]
		rewards[j] = slot
	show_overlay("ENTER THE VEIL", "Test Visreal in five short fights. Defeat each guardian to earn one unique gear piece.\n\nWASD moves. Hold arrows to slash. Q dashes toward your aim; E coats your blades.", "Begin combat  [Enter]", "Reset run  [R]")
	update_hud()

func start_bout() -> void:
	if state not in ["ready", "clear", "complete"]:
		return
	bout += 1
	state = "fight"
	reward_claimed = false
	player.position = SPAWN
	player.prepare_bout()
	player.aim = Vector2.RIGHT
	overlay.hide()
	var positions := [Vector2(760, 440), Vector2(700, 650), Vector2(510, 300)]
	enemies_remaining = positions.size()
	for i in positions.size():
		var enemy := Enemy.new()
		enemy.position = positions[i]
		enemy.guardian = i == 0
		enemy.tier = mini(bout, 5)
		enemy.player = player
		enemy.defeated.connect(on_enemy_defeated)
		enemy.damaged.connect(add_damage_number)
		actors.add_child(enemy)
	set_notice("E: coat blades  >  slash to poison  >  Q: Shadowstep  >  slash for Nightshade", 5.0)
	update_hud()

func on_enemy_defeated(enemy: Node2D) -> void:
	if state != "fight":
		return
	kills += 1
	enemies_remaining -= 1
	if enemy.guardian and not reward_claimed:
		reward_claimed = true
		if not rewards.is_empty():
			last_reward = rewards.pop_front()
			player.equip(last_reward)
			set_notice("EQUIPPED  /  " + T.ITEM_NAMES[last_reward] + "  /  " + T.ITEM_EFFECTS[last_reward], 6.0)
	if enemies_remaining == 0:
		finish_bout()

func finish_bout() -> void:
	player.active = false
	player.velocity = Vector2.ZERO
	player.attack_elapsed = -1.0
	player.sprite.modulate = Color.WHITE
	player.sprite.play("idle_" + player.direction_name(player.aim))
	player.queue_redraw()
	state = "complete" if rewards.is_empty() else "clear"
	if state == "complete":
		show_overlay("THE SET IS COMPLETE", "All five equipment effects are active. Continue sparring with the full kit, or restart for a fresh reward order.\n\nThis chamber is the combat prototype; the six-floor adventure is still to come.", "Full-kit sparring  [Enter]", "New run  [R]")
	else:
		show_overlay("GUARDIAN DEFEATED", T.ITEM_NAMES[last_reward] + " equipped.\n" + T.ITEM_EFFECTS[last_reward] + ".\n\nThe next fight restores health and skill cooldowns. Your equipment stays with you.", "Next fight  [Enter]", "New run  [R]")
	update_hud()

func on_player_died() -> void:
	state = "dead"
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.active = false
	show_overlay("THE VOID TAKES YOU", "Your run has ended.\n%d enemies defeated. %d of 5 gear pieces earned.\n\nRestart with basic gear and a newly shuffled reward order." % [kills, player.gear.size()], "Try again  [Enter]", "New run  [R]")

func on_skill_used(skill: String) -> void:
	if skill == "shadowstep":
		set_notice("SHADOWSTEP  /  Your next slash is empowered. Strike a poisoned enemy for Nightshade.", 2.3)
	else:
		set_notice("VENOM BLADES  /  Melee hits now apply poison over time.", 2.3)

func add_damage_number(at: Vector2, amount: float, kind: String) -> void:
	var color := Color("e5dbcb")
	if kind == "poison":
		color = Color("abe477")
	elif kind in ["shadow", "nightshade"]:
		color = Color("c99afb")
	var text := str(roundi(amount))
	if kind == "nightshade":
		text += "  NIGHTSHADE"
	floats.append({"at": at + Vector2(rng.randf_range(-12, 12), -108), "text": text, "color": color, "life": 0.9})

func set_notice(text: String, seconds: float) -> void:
	notice.text = text
	notice_left = seconds

func _process(delta: float) -> void:
	if not get_tree().paused:
		motes_clock += delta
		notice_left = maxf(0.0, notice_left - delta)
		for i in range(floats.size() - 1, -1, -1):
			floats[i].life -= delta
			floats[i].at.y -= 30.0 * delta
			if floats[i].life <= 0.0:
				floats.remove_at(i)
	update_hud()
	queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_ENTER, KEY_KP_ENTER:
			primary_action()
		KEY_R:
			new_run()
		KEY_ESCAPE:
			toggle_pause()

func primary_action() -> void:
	if get_tree().paused:
		toggle_pause()
	elif state == "dead":
		new_run()
		start_bout()
	elif state in ["ready", "clear", "complete"]:
		start_bout()

func toggle_pause() -> void:
	if state != "fight":
		return
	get_tree().paused = not get_tree().paused
	if get_tree().paused:
		show_overlay("PAUSED", "WASD  /  Move\nArrow keys  /  Aim and repeat melee attacks\nQ  /  Shadowstep       E  /  Venom Blades\n\nYour last arrow direction is remembered for Shadowstep.", "Resume  [Esc / Enter]", "New run  [R]")
	else:
		overlay.hide()

func show_overlay(title: String, copy: String, action: String, secondary: String) -> void:
	overlay_title.text = title
	overlay_copy.text = copy
	overlay_button.text = action
	secondary_button.text = secondary
	overlay.show()

func panel(parent: Node, rectangle: Rect2, fill: Color, border: Color) -> Panel:
	var result := Panel.new()
	result.position = rectangle.position
	result.size = rectangle.size
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	result.add_theme_stylebox_override("panel", style)
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(result)
	return result

func label(parent: Node, text: String, rectangle: Rect2, font_size: int, color: Color) -> Label:
	var result := Label.new()
	result.text = text
	result.position = rectangle.position
	result.size = rectangle.size
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", color)
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(result)
	return result

func button(parent: Node, text: String, rectangle: Rect2, callback: Callable) -> Button:
	var result := Button.new()
	result.text = text
	result.position = rectangle.position
	result.size = rectangle.size
	result.focus_mode = Control.FOCUS_NONE
	result.add_theme_font_size_override("font_size", 16)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("38303e")
	normal.border_color = Color("89705f")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(4)
	result.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("554355")
	result.add_theme_stylebox_override("hover", hover)
	result.add_theme_stylebox_override("pressed", hover)
	result.pressed.connect(callback)
	parent.add_child(result)
	return result

func create_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	ui = Control.new()
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(ui)
	label(ui, "THE FINAL DESCENT", Rect2(36, 23, 800, 42), 32, INK)
	label(ui, "VISREAL   /   THE VEIL CHAMBER", Rect2(38, 73, 700, 28), 17, GOLD)
	label(ui, "COMBAT PROTOTYPE  ·  temporary balance", Rect2(38, 107, 750, 25), 14, MUTED)
	button(ui, "Pause  [Esc]", Rect2(1090, 54, 154, 38), toggle_pause)
	round_label = label(ui, "", Rect2(690, 76, 265, 24), 17, INK)
	round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	enemy_label = label(ui, "", Rect2(690, 108, 265, 24), 14, MUTED)
	enemy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	panel(ui, Rect2(980, 160, 264, 612), Color("141822"), Color("373141"))
	label(ui, "VISREAL", Rect2(1000, 178, 230, 30), 24, INK)
	label(ui, "Shadow & poison rogue", Rect2(1000, 214, 230, 25), 14, MUTED)
	health_bar = ProgressBar.new()
	health_bar.position = Vector2(1000, 252)
	health_bar.size = Vector2(224, 14)
	health_bar.max_value = T.MAX_HEALTH
	health_bar.show_percentage = false
	var background := StyleBoxFlat.new()
	background.bg_color = Color("292432")
	health_bar.add_theme_stylebox_override("background", background)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("bc6377")
	health_bar.add_theme_stylebox_override("fill", fill)
	ui.add_child(health_bar)
	health_label = label(ui, "", Rect2(1000, 284, 224, 24), 15, INK)
	status_label = label(ui, "", Rect2(1000, 314, 224, 38), 13, GOLD)
	label(ui, "EQUIPMENT  /  BOSS REWARDS", Rect2(1000, 356, 230, 24), 12, MUTED)
	for i in T.SLOTS.size():
		var slot: String = T.SLOTS[i]
		var card := panel(ui, Rect2(996, 391 + i * 66, 232, 58), Color("1b1e29"), Color("383344"))
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		card.tooltip_text = T.ITEM_NAMES[slot] + "\n" + T.ITEM_EFFECTS[slot]
		gear_panels[slot] = card
		label(card, slot.to_upper(), Rect2(10, 5, 210, 20), 12, GOLD)
		var description := label(card, "", Rect2(10, 27, 214, 22), 12, MUTED)
		gear_labels[slot] = description
	label(ui, "One unique drop per guardian", Rect2(1000, 733, 230, 24), 13, MUTED)
	notice = label(ui, "", Rect2(54, 775, 1180, 26), 14, GOLD)
	var shadow_card := panel(ui, Rect2(36, 811, 360, 57), Color("201d30"), Color("5b466f"))
	shadow_label = label(shadow_card, "", Rect2(14, 7, 336, 44), 15, INK)
	var poison_card := panel(ui, Rect2(408, 811, 360, 57), Color("1d2726"), Color("45634d"))
	venom_label = label(poison_card, "", Rect2(14, 7, 336, 44), 15, INK)
	var passive_card := panel(ui, Rect2(780, 811, 464, 57), Color("241e2c"), Color("584051"))
	passive_label = label(passive_card, "NIGHTSHADE  /  Passive\nEmpowered strikes punish poisoned enemies", Rect2(14, 7, 438, 44), 14, INK)
	label(ui, "WASD move   ·   Hold arrows to aim + slash   ·   Q Shadowstep   ·   E Venom Blades   ·   R restart", Rect2(38, 876, 1205, 23), 13, MUTED)
	overlay = panel(ui, Rect2(200, 320, 604, 340), Color(0.065, 0.07, 0.105, 0.97), Color("8a7060"))
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay_title = label(overlay, "", Rect2(26, 24, 552, 42), 28, GOLD)
	overlay_copy = label(overlay, "", Rect2(26, 82, 552, 164), 17, INK)
	overlay_copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay_button = button(overlay, "", Rect2(26, 267, 326, 46), primary_action)
	secondary_button = button(overlay, "", Rect2(366, 267, 212, 46), new_run)

func update_hud() -> void:
	if not is_instance_valid(player):
		return
	health_bar.value = player.health
	health_label.text = "%d / %d health" % [ceili(player.health), int(T.MAX_HEALTH)]
	round_label.text = "FIGHT %d / 5" % maxi(1, bout) if bout <= 5 else "FULL-KIT SPARRING"
	enemy_label.text = "%d enemies  /  %d defeated" % [enemies_remaining, kills]
	status_label.text = "%d / 5 gear pieces equipped" % player.gear.size()
	if player.empower_left > 0.0:
		status_label.text += "\nShadow strike ready"
	for slot: String in T.SLOTS:
		var earned: bool = slot in player.gear
		gear_labels[slot].text = T.ITEM_NAMES[slot] if earned else ("Basic blades" if slot == "swords" else "Awaiting guardian reward")
		gear_labels[slot].add_theme_color_override("font_color", Color("bde398") if earned else MUTED)
		var style: StyleBoxFlat = gear_panels[slot].get_theme_stylebox("panel")
		style.border_color = Color("688159") if earned else Color("383344")
	shadow_label.text = "Q  SHADOWSTEP  /  " + ("READY" if player.shadow_cooldown <= 0.0 else "%.1fs" % player.shadow_cooldown)
	shadow_label.text += "\nDash toward aim; empower the next slash"
	venom_label.text = "E  VENOM BLADES  /  " + ("READY" if player.venom_cooldown <= 0.0 else "%.1fs" % player.venom_cooldown)
	venom_label.text += "\n" + ("Poison coating active  /  %.1fs" % player.venom_left if player.venom_left > 0.0 else "Coat swords to poison enemies on hit")
	notice.visible = notice_left > 0.0

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1280, 900), Color("0c1019"))
	draw_line(Vector2(36, 143), Vector2(1244, 143), Color("51404b"), 1.0)
	draw_rect(ROOM.grow(8), Color("252231"))
	draw_rect(ROOM, Color("171c27"))
	for row in 10:
		for col in 15:
			var x := 52.0 + col * 60.0
			var y := 164.0 + row * 60.0
			var color := Color("1d222d") if (row + col) % 2 == 0 else Color("1b202b")
			draw_rect(Rect2(x, y, 57, 57), color)
	var center := Vector2(502, 478)
	draw_arc(center, 170, 0, TAU, 90, Color("353041"), 2.0, true)
	draw_arc(center, 155, 0, TAU, 90, Color("2b2b3c"), 1.0, true)
	for i in 8:
		var angle := i * TAU / 8.0
		draw_line(center + Vector2.from_angle(angle) * 143, center + Vector2.from_angle(angle) * 178, Color("393247"), 3.0, true)
	for x in [78.0, 926.0]:
		for y in [210.0, 720.0]:
			draw_rect(Rect2(x - 12, y - 25, 24, 52), Color("39313d"))
			draw_circle(Vector2(x, y - 14), 15, Color(0.75, 0.29, 0.25, 0.08))
			draw_circle(Vector2(x, y - 14), 7 + sin(motes_clock * 6 + y) * 1.4, Color("d68765"))
	draw_rect(ROOM, Color("6b5260"), false, 2.0)
	for floating: Dictionary in floats:
		var color: Color = floating.color
		color.a = minf(1.0, floating.life * 2.0)
		draw_string(ThemeDB.fallback_font, floating.at, floating.text, HORIZONTAL_ALIGNMENT_CENTER, -1, 18, color)

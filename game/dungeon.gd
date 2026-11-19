extends "res://game/combat.gd"

const Chamber = preload("res://game/chamber_art.gd")
const FLOOR_NAMES := ["The Threshold", "Flooded Vaults", "Cinder Works", "The Ossuary", "Violet Reliquary", "The Unblinking Court"]
const GUARDIANS := ["Gate Warden", "Keeper of the Sluice", "Ash Warden", "Bone Castellan", "Keeper of the Seal", "The Witness"]
const ROOMS := ["Refuge", "Passage", "Gallery", "Antechamber", "Sanctum"]
const ROUTES := [
	[Vector2i.RIGHT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN],
	[Vector2i.UP, Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT],
	[Vector2i.LEFT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP],
	[Vector2i.DOWN, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT],
	[Vector2i.LEFT, Vector2i.UP, Vector2i.UP, Vector2i.RIGHT],
	[Vector2i.UP, Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.DOWN]
]
const GATES := {Vector2i.LEFT: Vector2(100, 506), Vector2i.RIGHT: Vector2(902, 506),
	Vector2i.UP: Vector2(502, 287), Vector2i.DOWN: Vector2(502, 721)}
const STAIRS := Vector2(502, 508)
const EXPOSURE_DELAY := 0.9
const LIGHT_HALF_WIDTH := 71.0

var depth := 1
var room := 0
var cleared: Array[int] = []
var level := 1
var xp := 0
var gaze_time := 0.0
var exposure := 0.0
var tagged := false
var objective := ""
var layout_art := Chamber.new()
var masonry: Node2D

func _ready() -> void:
	masonry = Node2D.new()
	masonry.z_index = -1
	masonry.draw.connect(func(): layout_art.draw_chamber(masonry, depth, room))
	add_child(masonry)
	super._ready()

func new_run() -> void:
	depth = 1
	room = 0
	level = 1
	xp = 0
	cleared.assign([0])
	exposure = 0.0
	tagged = false
	gaze_time = 0.0
	super.new_run()
	masonry.queue_redraw()
	objective = "Descend through six floors."
	show_overlay("THE FINAL DESCENT", "Six floors beneath the void. Walk through the lit gates, defeat each floor’s guardian and take the stairs deeper.\n\nWASD moves. Hold arrows to slash. Q uses Shadowstep and E coats your blades.", "Enter the dungeon  [Enter]", "Reset  [R]")

func primary_action() -> void:
	if get_tree().paused:
		toggle_pause()
	elif state in ["dead", "won"]:
		new_run()
		start_floor()
	elif state == "ready":
		start_floor()

func start_floor() -> void:
	state = "fight"
	cleared.assign([0])
	reward_claimed = false
	overlay.hide()
	player.prepare_bout()
	enter_room(0, Vector2i.ZERO)
	if depth == 6:
		set_notice("THE WITNESS  /  Step out of the moving light before it exposes you.", 8.0)
	elif depth > 1:
		set_notice("Refuge reached. Health restored.", 3.0)

func forward_dir() -> Vector2i:
	return ROUTES[depth - 1][room]

func back_dir() -> Vector2i:
	return -ROUTES[depth - 1][room - 1]

func direction_word(direction: Vector2i) -> String:
	match direction:
		Vector2i.RIGHT: return "east"
		Vector2i.LEFT: return "west"
		Vector2i.UP: return "north"
	return "south"

func enter_room(index: int, entry: Vector2i) -> void:
	room = index
	masonry.queue_redraw()
	enemies_remaining = 0
	floats.clear()
	gaze_time = index * 1.7
	exposure = 0.0
	tagged = false
	player.velocity = Vector2.ZERO
	player.dash_left = 0.0
	player.attack_elapsed = -1.0
	player.trails.clear()
	if entry == Vector2i.ZERO:
		player.position = STAIRS
		player.aim = Vector2(forward_dir())
	else:
		player.position = GATES[entry] - Vector2(entry) * 80.0
		player.aim = -Vector2(entry)
	if room not in cleared:
		spawn_room()
	refresh_objective()
	update_hud()

func spawn_room() -> void:
	# Select positions furthest from the gate used to enter.
	var positions: Array[Vector2] = [Vector2(246, 373), Vector2(748, 646), Vector2(715, 374), Vector2(267, 631), Vector2(507, 500)]
	positions.sort_custom(func(a: Vector2, b: Vector2): return a.distance_squared_to(player.position) > b.distance_squared_to(player.position))
	var boss := room == 4
	enemies_remaining = 1 + int(depth >= 3) if boss else 1 + int(room >= 2) + int(depth >= 4)
	for i in enemies_remaining:
		spawn_enemy(positions[i], boss and i == 0, depth)

func on_enemy_defeated(enemy: Node2D) -> void:
	if state != "fight":
		return
	kills += 1
	enemies_remaining -= 1
	gain_xp(36 if enemy.guardian else 12)
	if enemy.guardian and depth < 6 and not reward_claimed:
		reward_claimed = true
		last_reward = rewards.pop_front()
		player.equip(last_reward)
		set_notice("Equipped %s   ·   %s" % [T.ITEM_NAMES[last_reward], T.ITEM_EFFECTS[last_reward]], 6)
	if enemies_remaining == 0:
		cleared.append(room)
		tagged = false
		exposure = 0.0
		if depth == 6 and room == 4:
			state = "won"
			player.active = false
			player.sprite.play("idle_" + player.direction_name(player.aim))
			show_overlay("THE WITNESS FALLS", "The last searchlight goes dark. Visreal slips through the court unseen.\n\nSix floors cleared   ·   %d enemies defeated\nLevel %d   ·   %d gear pieces recovered" % [kills, level, player.gear.size()], "Descend again  [Enter]", "Main menu  [R]")
	refresh_objective()

func xp_needed() -> int:
	return 48 + (level - 1) * 12

func gain_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_needed():
		xp -= xp_needed()
		level += 1
		player.max_health += 12
		player.health += 12
		player.melee_bonus += 2
		set_notice("Level %d   ·   Maximum health +12   ·   Melee damage +2" % level, 3)

func refresh_objective() -> void:
	if state == "won":
		objective = "All six floors cleared."
	elif enemies_remaining > 0:
		objective = "Defeat " + GUARDIANS[depth - 1] + " and clear the sanctum." if room == 4 else "Clear the room to unseal its gates."
	elif room == 4:
		objective = "Walk onto the central stairs to descend."
	else:
		objective = "Follow the lit gate " + direction_word(forward_dir()) + "."

func on_player_died() -> void:
	super.on_player_died()
	tagged = false
	show_overlay("THE VOID TAKES YOU", "Visreal fell in %s, floor %d.\n\n%d enemies defeated   ·   Level %d   ·   %d gear pieces recovered" % [FLOOR_NAMES[depth - 1], depth, kills, level, player.gear.size()], "Try again  [Enter]", "Main menu  [R]")

func _physics_process(delta: float) -> void:
	if state != "fight" or get_tree().paused:
		return
	if enemies_remaining > 0:
		if depth == 6:
			advance_gaze(delta)
		return
	if room < 4 and player.position.distance_to(GATES[forward_dir()]) < 32.0:
		var through := forward_dir()
		enter_room(room + 1, -through)
	elif room > 0 and player.position.distance_to(GATES[back_dir()]) < 32.0:
		var through := back_dir()
		enter_room(room - 1, -through)
	elif room == 4 and depth < 6 and player.position.distance_to(STAIRS) < 38.0:
		depth += 1
		start_floor()

func light_x() -> float:
	return 502.0 + 340.0 * sin(gaze_time * 0.48)

func advance_gaze(delta: float) -> void:
	gaze_time += delta
	tagged = absf(player.position.x - light_x()) <= LIGHT_HALF_WIDTH
	if tagged:
		exposure += delta
		if exposure >= EXPOSURE_DELAY:
			player.take_damage(16)
			exposure = 0.0
			if not player.dead:
				set_notice("EXPOSED   ·   Leave the light!", 1.4)
	else:
		exposure = 0.0

func update_hud() -> void:
	super.update_hud()
	if not is_instance_valid(player):
		return
	place_label.text = "VISREAL   /   " + FLOOR_NAMES[depth - 1].to_upper()
	objective_label.text = objective
	round_label.text = "FLOOR %d / 6    ·    ROOM %d / 5" % [depth, room + 1]
	enemy_label.text = "%s    ·    %d enemies" % [ROOMS[room], enemies_remaining]
	health_bar.max_value = player.max_health
	health_bar.value = player.health
	health_label.text = "%d / %d health" % [ceili(player.health), int(player.max_health)]
	status_label.text = "Level %d    ·    XP %d / %d\n%d / 5 gear pieces" % [level, xp, xp_needed(), player.gear.size()]
	if tagged:
		objective_label.text = "IN THE LIGHT   ·   Exposure %d%%   ·   Move into shadow!" % roundi(100.0 * exposure / EXPOSURE_DELAY)

func _draw() -> void:
	if depth == 6 and enemies_remaining > 0:
		layout_art.draw_searchlight(self, light_x(), LIGHT_HALF_WIDTH, tagged)
	if room < 4:
		layout_art.draw_gate(self, GATES[forward_dir()], forward_dir(), enemies_remaining == 0, true)
	if room > 0:
		layout_art.draw_gate(self, GATES[back_dir()], back_dir(), enemies_remaining == 0, false)
	if room == 4 and depth < 6 and room in cleared:
		layout_art.draw_stairs(self, STAIRS, motes_clock)
	layout_art.draw_map(self, ROUTES[depth - 1], room, cleared)
	draw_damage_numbers()

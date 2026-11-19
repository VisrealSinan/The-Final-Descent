extends SceneTree
## Traverse the packaged main scene with normal movement and melee input.
var game
var errors: Array[String] = []
var visited := {}
var gear_seen := {}
var checks := 0
var ticks := 0
var last_room := ""
var forward := true
var tested_return := false
const ACTIONS := ["move_left","move_right","move_up","move_down","aim_left","aim_right","aim_up","aim_down","venom_blades"]

func _initialize() -> void:
	call_deferred("run")

func check(passed: bool, message: String) -> void:
	checks += 1
	if not passed:
		push_error(message)
		errors.append(message)

func release() -> void:
	for action: String in ACTIONS:
		Input.action_release(action)

func steer(direction: Vector2, prefix: String, tolerance: float) -> void:
	if absf(direction.x) > tolerance:
		Input.action_press(prefix + ("right" if direction.x > 0 else "left"))
	if absf(direction.y) > tolerance:
		Input.action_press(prefix + ("down" if direction.y > 0 else "up"))

func run() -> void:
	var main: PackedScene = load(ProjectSettings.get_setting("application/run/main_scene"))
	game = main.instantiate()
	root.add_child(game)
	await physics_frame
	check(game.state == "ready", "Title screen")
	game.primary_action()
	var p = game.player
	while ticks < 80000 and game.state == "fight":
		await physics_frame
		release()
		ticks += 1
		var id := "%d/%d" % [game.depth, game.room]
		if id != last_room:
			if not visited.has(id):
				check((game.room == 0) == (game.enemies_remaining == 0), "Correct safe/combat room " + id)
				var guardians := 0
				for enemy in get_nodes_in_group("enemies"):
					if enemy.guardian:
						guardians += 1
				check(guardians == int(game.room == 4), "One guardian only in boss room " + id)
				if game.room == 0:
					check(p.gear.size() == game.depth - 1, "Gear persists across descent " + id)
					print("Reached floor ", game.depth, " with ", p.gear.size(), " rewards")
			visited[id] = true
			last_room = id
		if game.enemies_remaining > 0:
			var closest: Node2D
			var nearest := INF
			for enemy in get_nodes_in_group("enemies"):
				var distance: float = p.position.distance_to(enemy.position)
				if distance < nearest:
					nearest = distance
					closest = enemy
			if closest != null:
				var delta: Vector2 = closest.position - p.position
				steer(delta.normalized(), "aim_", 0.40)
				if p.venom_cooldown <= 0.0:
					Input.action_press("venom_blades")
				# Leave the exposure beam while aiming independently at the nearest enemy.
				if game.depth == 6 and game.tagged:
					var escape := 1 if p.position.x > game.light_x() else -1
					if p.position.x < 155: escape = 1
					if p.position.x > 840: escape = -1
					Input.action_press("move_right" if escape > 0 else "move_left")
		else:
			for item in p.gear:
				gear_seen[item] = true
			var destination: Vector2
			if game.room == 4:
				destination = game.STAIRS
			elif game.depth == 1 and game.room == 1 and not tested_return:
				destination = game.GATES[game.back_dir()]
				forward = false
			else:
				destination = game.GATES[game.forward_dir()]
			if game.room == 0 and not forward:
				tested_return = true
				forward = true
			steer(destination - p.position, "move_", 8)
	release()
	check(game.state == "won", "Normal attacks and gate traversal reach victory, ended at " + last_room + " state " + game.state)
	check(visited.size() == 30, "Visited 30 rooms")
	check(tested_return, "Returned to refuge and re-entered cleared passage")
	check(gear_seen.size() == 5 and p.gear.size() == 5, "All five distinct boss drops")
	check(game.level > 1 and p.melee_bonus > 0 and p.max_health > p.T.MAX_HEALTH, "Run XP raised stats")
	if game.state == "won":
		game.primary_action()
		check(game.depth == 1 and game.room == 0 and game.level == 1 and game.player.gear.is_empty(), "Victory restart clears progress")
		game.toggle_pause()
		check(paused, "Safe room can pause")
		game.toggle_pause()
		game.player.take_damage(10000)
		check(game.state == "dead", "Death ends run")
		game.primary_action()
		check(game.state == "fight" and game.depth == 1 and game.room == 0, "Death retry reaches refuge")
		# Isolate the sixth-floor beam to verify grace, damage, shade and pause.
		game.depth = 6
		game.start_floor()
		check(not game.tagged and game.enemies_remaining == 0, "Final refuge is safe")
		game.enter_room(1, Vector2i.DOWN)
		game.player.position.x = game.light_x()
		var hp: float = game.player.health
		game.advance_gaze(0.1)
		check(game.player.health == hp and game.tagged, "Beam gives a visible warning before damage")
		game.player.position.x = 100
		game.advance_gaze(0.1)
		check(game.exposure == 0.0 and not game.tagged, "Leaving the band clears exposure")
		for i in 60:
			game.player.position.x = game.light_x()
			game.advance_gaze(1.0 / 60.0)
		check(game.player.health < hp, "Staying in the beam deals damage")
	print("%d dungeon checks, %d rooms, %d simulated physics frames, %d failures" % [checks,visited.size(),ticks,errors.size()])
	quit(0 if errors.is_empty() else 1)

extends SceneTree
## Integration checks against the actual combat scene and physical-key bindings.
const Combat = preload("res://game/combat.tscn")
const T = preload("res://game/tuning.gd")
const Enemy = preload("res://game/enemy.gd")
var game: Node2D
var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
	call_deferred("run")

func verify(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
		push_error(description)

func key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func frames(count: int) -> void:
	for i in count:
		await physics_frame

func release_keys() -> void:
	for code in [KEY_W, KEY_A, KEY_S, KEY_D, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_Q, KEY_E]:
		key(code, false)

func frozen_targets() -> Array[Node]:
	var targets := get_nodes_in_group("enemies")
	for target in targets:
		target.set_physics_process(false)
	return targets

func run() -> void:
	create_timer(30.0).timeout.connect(func():
		push_error("Combat checks timed out")
		quit(2)
	)
	game = Combat.instantiate()
	root.add_child(game)
	await frames(2)
	verify(game.state == "ready" and game.player.gear.is_empty(), "Starts safely with basic gear and a start screen")
	key(KEY_ENTER, true)
	key(KEY_ENTER, false)
	await frames(2)
	verify(game.state == "fight" and game.enemies_remaining == 3, "Enter starts a real encounter")
	var targets := frozen_targets()
	for i in targets.size():
		targets[i].position = Vector2(800, 300 + i * 140)
	var player = game.player
	var origin: Vector2 = player.position
	key(KEY_D, true)
	await frames(15)
	key(KEY_D, false)
	var horizontal_distance: float = player.position.x - origin.x
	verify(horizontal_distance > 45.0 and horizontal_distance < 70.0, "WASD moves at the configured speed")
	player.position = origin
	key(KEY_D, true)
	key(KEY_S, true)
	await frames(15)
	release_keys()
	var diagonal_distance: float = player.position.distance_to(origin)
	verify(absf(diagonal_distance - horizontal_distance) < 7.0, "Diagonal movement is normalized")
	player.position = Vector2(420, 510)
	key(KEY_D, true)
	key(KEY_LEFT, true)
	await frames(4)
	verify(player.position.x > 420 and player.aim == Vector2.LEFT, "Movement and arrow aim are independent")
	release_keys()
	player.position = Vector2(420, 510)
	player.attack_cooldown = 0.0
	player.attack_elapsed = -1.0
	targets[0].position = Vector2(355, 510)
	targets[1].position = Vector2(485, 510)
	targets[2].position = Vector2(200, 510)
	var health_front: float = targets[0].health
	var health_back: float = targets[1].health
	var health_far: float = targets[2].health
	key(KEY_LEFT, true)
	await frames(14)
	release_keys()
	verify(targets[0].health < health_front, "Sword slash damages a target in front")
	verify(targets[1].health == health_back, "Sword slash does not hit behind Visreal")
	verify(targets[2].health == health_far, "Sword slash cannot damage a distant target")
	var before: int = player.attacks_started
	targets[0].health = 1000.0
	key(KEY_LEFT, true)
	await frames(60)
	release_keys()
	verify(player.attacks_started - before >= 2, "Holding an arrow repeats attacks")
	key(KEY_UP, true)
	key(KEY_RIGHT, true)
	await frames(2)
	verify(player.aim.distance_to(Vector2(1, -1).normalized()) < 0.01, "Two arrows aim diagonally")
	release_keys()
	player.position = Vector2(900, 500)
	player.aim = Vector2.RIGHT
	player.shadow_cooldown = 0.0
	key(KEY_Q, true)
	await frames(2)
	key(KEY_Q, false)
	verify(player.dash_left > 0.0 and player.empower_left > 0.0, "Q starts Shadowstep and empowers the next slash")
	verify(not player.try_shadowstep(), "Shadowstep cannot bypass its cooldown")
	await frames(18)
	verify(player.position.x <= 920.1, "Shadowstep collides with chamber walls")
	player.position = Vector2(420, 510)
	player.attack_elapsed = -1.0
	player.attack_cooldown = 0.0
	player.empower_left = 0.0
	key(KEY_E, true)
	await frames(2)
	key(KEY_E, false)
	verify(player.venom_left > 0.0 and not player.try_venom(), "E activates coating and respects cooldown")
	key(KEY_LEFT, true)
	await frames(14)
	release_keys()
	verify(targets[0].poison_left > 0.0, "Coated melee hits apply poison")
	var unpoisoned: Dictionary = T.hit([], true, true, false)
	var poisoned: Dictionary = T.hit([], true, true, true)
	verify(poisoned.shadow > unpoisoned.shadow and poisoned.nightshade, "Nightshade boosts empowered strikes against existing poison")
	verify(not T.hit([], false, true, true).nightshade, "Ordinary coated strikes do not trigger Nightshade")
	verify(not unpoisoned.nightshade, "A fresh poison application cannot trigger Nightshade on the same hit")
	var base: Dictionary = T.hit([], false, false, false)
	var blades: Dictionary = T.hit(["swords"], false, false, false)
	verify(blades.shadow > 0.0 and blades.poison > 0.0 and blades.physical == base.physical, "Paired swords add both damage types without a generic physical increase")
	verify(blades.dot == 0.0, "Weapon poison is direct damage; Venom Blades still supplies the status")
	var mask: Dictionary = T.hit(["swords", "mask"], false, true, false)
	verify(mask.poison > blades.poison and mask.dot > T.POISON_TICK_DAMAGE, "Mask boosts direct poison and poison ticks")
	verify(T.hit(["trinket"], true, false, false).shadow > unpoisoned.shadow, "Trinket strengthens the empowered shadow strike")
	player.gear.clear()
	player.hurt_left = 0.0
	player.health = T.MAX_HEALTH
	var normal_damage: float = player.take_damage(20)
	player.equip("armor")
	player.hurt_left = 0.0
	var armored_damage: float = player.take_damage(20)
	verify(armored_damage < normal_damage, "Armor actually reduces health lost")
	player.equip("cape")
	player.shadow_cooldown = 0.0
	player.try_shadowstep()
	verify(player.shadow_cooldown < T.SHADOWSTEP_COOLDOWN, "Cape reduces the cooldown used by Shadowstep")
	# Check poison expiration, refresh and kill attribution independently of AI motion.
	var dummy := Enemy.new()
	game.actors.add_child(dummy)
	dummy.set_physics_process(false)
	dummy.max_health = 1000
	dummy.health = 1000
	dummy.apply_poison(5)
	dummy.advance_poison(0.25)
	dummy.apply_poison(5)
	dummy.advance_poison(0.25)
	verify(is_equal_approx(dummy.health, 995), "Repeated poison applications do not postpone ticks")
	var poisoned_health: float = dummy.health
	dummy.advance_poison(4.0)
	verify(is_equal_approx(dummy.health, poisoned_health - 25), "Poison refresh does not stack and stops after its duration")
	var expired_health: float = dummy.health
	dummy.advance_poison(10)
	verify(dummy.health == expired_health, "Expired poison deals no further damage")
	dummy.health = 4
	dummy.apply_poison(5)
	dummy.advance_poison(0.5)
	verify(dummy.dead, "Poison can kill a target")
	await frames(2)
	# Randomized slots must be a permutation on every new run.
	var orders: Dictionary = {}
	for i in 20:
		game.new_run()
		var sorted: Array = game.rewards.duplicate()
		sorted.sort()
		var expected: Array = T.SLOTS.duplicate()
		expected.sort()
		verify(sorted == expected, "Run %d has all five rewards exactly once" % i)
		orders[str(game.rewards)] = true
		await frames(1)
	verify(orders.size() > 1, "New runs genuinely shuffle reward order")
	game.start_bout()
	await frames(2)
	frozen_targets()
	var paused_player = game.player
	var pause_position: Vector2 = paused_player.position
	game.toggle_pause()
	key(KEY_D, true)
	await frames(12)
	release_keys()
	verify(paused and paused_player.position == pause_position, "Pause freezes movement and simulation")
	game.toggle_pause()
	# Exercise actual defeat signals, auto-equip and all five reward transitions.
	for stage in 5:
		if stage > 0:
			game.start_bout()
		await frames(2)
		for target in frozen_targets():
			target.receive_hit({"physical": 10000.0, "shadow": 0.0, "poison": 0.0, "dot": 0.0, "nightshade": false}, Vector2.RIGHT)
		await frames(2)
		verify(game.player.gear.size() == stage + 1, "Guardian %d awards exactly one new gear piece" % (stage + 1))
	verify(game.state == "complete" and game.rewards.is_empty(), "Fifth fight completes the loadout")
	game.start_bout()
	await frames(2)
	verify(game.player.gear.size() == 5 and game.state == "fight", "Full-kit sparring preserves the earned equipment")
	var live_targets := frozen_targets()
	var attacker = live_targets[0]
	attacker.position = game.player.position + Vector2(50, 0)
	attacker.cooldown = 0.0
	attacker.set_physics_process(true)
	await frames(3)
	verify(attacker.windup > 0.0, "Enemy announces its attack with a windup")
	var safe_health: float = game.player.health
	game.player.position += Vector2(-150, 0)
	await frames(50)
	verify(game.player.health == safe_health, "Moving away during windup avoids the enemy strike")
	attacker.position = game.player.position + Vector2(50, 0)
	attacker.cooldown = 0.0
	attacker.windup = -1.0
	await frames(55)
	verify(game.player.health < safe_health, "Enemy melee actually damages the player")
	game.player.hurt_left = 0.0
	game.player.take_damage(10000)
	verify(game.state == "dead" and game.player.dead and game.overlay.visible, "Death shows the game-over flow")
	game.primary_action()
	await frames(2)
	verify(game.state == "fight" and game.bout == 1 and game.player.gear.is_empty() and game.player.health == T.MAX_HEALTH, "Restart clears equipment and restores health at encounter one")
	release_keys()
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("PASS: %d combat checks (physical keys, movement, melee, skills, equipment, poison, rewards, pause, death and restart)." % checks)
		quit(0)
	else:
		print("FAIL: %d / %d combat checks: %s" % [failures.size(), checks, str(failures)])
		quit(1)

extends CharacterBody2D

signal died
signal hit_landed(at: Vector2, payload: Dictionary)
signal skill_used(skill: String)

const T = preload("res://game/tuning.gd")
const VISUAL = preload("res://assets/characters/visreal/visreal_visual.tscn")

var health := T.MAX_HEALTH
var max_health := T.MAX_HEALTH
var melee_bonus := 0.0
var gear: Array[String] = []
var aim := Vector2.DOWN
var active := false
var dead := false
var input_enabled := true
var shadow_cooldown := 0.0
var venom_cooldown := 0.0
var venom_left := 0.0
var empower_left := 0.0
var dash_left := 0.0
var dash_direction := Vector2.DOWN
var hurt_left := 0.0
var attack_cooldown := 0.0
var attack_elapsed := -1.0
var attack_direction := Vector2.DOWN
var attack_empowered := false
var attack_coated := false
var hit_resolved := false
var attacks_started := 0
var sprite: AnimatedSprite2D
var trails: Array[Dictionary] = []
var trail_clock := 0.0

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = T.BODY_RADIUS
	shape.shape = circle
	add_child(shape)
	var visual := VISUAL.instantiate()
	visual.scale = Vector2(0.37, 0.37)
	add_child(visual)
	sprite = visual.get_node("AnimatedSprite2D")
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if not active or dead:
		return
	shadow_cooldown = maxf(0.0, shadow_cooldown - delta)
	venom_cooldown = maxf(0.0, venom_cooldown - delta)
	venom_left = maxf(0.0, venom_left - delta)
	empower_left = maxf(0.0, empower_left - delta)
	hurt_left = maxf(0.0, hurt_left - delta)
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	var movement := Vector2.ZERO
	var aiming := Vector2.ZERO
	if input_enabled:
		movement = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		aiming = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aiming != Vector2.ZERO:
		aim = aiming.normalized()
	if input_enabled and Input.is_action_just_pressed("shadowstep"):
		try_shadowstep()
	if input_enabled and Input.is_action_just_pressed("venom_blades"):
		try_venom()
	if dash_left > 0.0:
		dash_left = maxf(0.0, dash_left - delta)
		velocity = dash_direction * T.DASH_SPEED
		trail_clock -= delta
		if trail_clock <= 0.0:
			trails.append({"at": global_position, "life": 0.24})
			trail_clock = 0.025
	else:
		velocity = movement * T.MOVE_SPEED
		if aiming != Vector2.ZERO:
			try_attack()
	move_and_slide()
	if attack_elapsed >= 0.0:
		attack_elapsed += delta
		if not hit_resolved and attack_elapsed >= T.ATTACK_WINDUP:
			resolve_attack()
		if attack_elapsed >= T.ATTACK_INTERVAL:
			attack_elapsed = -1.0
	for i in range(trails.size() - 1, -1, -1):
		trails[i].life -= delta
		if trails[i].life <= 0.0:
			trails.remove_at(i)
	update_animation(movement)
	queue_redraw()

func try_attack() -> bool:
	if not active or dead or attack_cooldown > 0.0 or dash_left > 0.0:
		return false
	attack_cooldown = T.ATTACK_INTERVAL
	attack_elapsed = 0.0
	attack_direction = aim
	attack_empowered = empower_left > 0.0
	attack_coated = venom_left > 0.0
	empower_left = 0.0
	hit_resolved = false
	attacks_started += 1
	sprite.play("attack_" + direction_name(attack_direction))
	sprite.frame = 0
	return true

func resolve_attack() -> void:
	hit_resolved = true
	for target in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(target) or target.dead:
			continue
		var difference: Vector2 = target.global_position - global_position
		var radius: float = target.body_radius
		if difference.length() > T.ATTACK_REACH + radius:
			continue
		if difference.length() > radius and attack_direction.dot(difference.normalized()) < cos(T.ATTACK_HALF_ANGLE):
			continue
		var payload: Dictionary = T.hit(gear, attack_empowered, attack_coated, target.poison_left > 0.0)
		payload.physical += melee_bonus
		target.receive_hit(payload, attack_direction)
		hit_landed.emit(target.global_position, payload)

func try_shadowstep() -> bool:
	if not active or dead or shadow_cooldown > 0.0 or dash_left > 0.0:
		return false
	shadow_cooldown = T.shadowstep_cooldown(gear)
	dash_direction = aim
	dash_left = T.DASH_DURATION
	empower_left = T.EMPOWER_DURATION
	# Cancel a pending windup so the next actual slash is the empowered one.
	attack_elapsed = -1.0
	attack_cooldown = 0.0
	skill_used.emit("shadowstep")
	return true

func try_venom() -> bool:
	if not active or dead or venom_cooldown > 0.0:
		return false
	venom_cooldown = T.VENOM_COOLDOWN
	venom_left = T.VENOM_DURATION
	skill_used.emit("venom")
	return true

func take_damage(amount: float) -> float:
	if not active or dead or hurt_left > 0.0:
		return 0.0
	var actual := T.incoming_damage(amount, gear)
	health = maxf(0.0, health - actual)
	hurt_left = T.HURT_GRACE
	if health <= 0.0:
		dead = true
		active = false
		attack_elapsed = -1.0
		dash_left = 0.0
		venom_left = 0.0
		empower_left = 0.0
		trails.clear()
		sprite.modulate = Color.WHITE
		sprite.play("death_" + direction_name(aim))
		died.emit()
	queue_redraw()
	return actual

func equip(slot: String) -> void:
	if slot in T.SLOTS and slot not in gear:
		gear.append(slot)

func prepare_bout() -> void:
	health = max_health
	shadow_cooldown = 0.0
	venom_cooldown = 0.0
	venom_left = 0.0
	empower_left = 0.0
	dash_left = 0.0
	hurt_left = 0.0
	attack_elapsed = -1.0
	attack_cooldown = 0.0
	velocity = Vector2.ZERO
	active = true
	dead = false
	trails.clear()
	queue_redraw()

func update_animation(movement: Vector2) -> void:
	var facing := aim
	var action := "idle"
	if attack_elapsed >= 0.0:
		action = "attack"
		facing = attack_direction
	elif hurt_left > T.HURT_GRACE - 0.22:
		action = "hurt"
	elif movement != Vector2.ZERO or dash_left > 0.0:
		action = "walk"
		if not input_enabled or Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down") == Vector2.ZERO:
			facing = movement if movement != Vector2.ZERO else dash_direction
	var animation := action + "_" + direction_name(facing)
	if sprite.animation != animation:
		sprite.play(animation)
	var tint := Color.WHITE
	if dash_left > 0.0 or empower_left > 0.0:
		tint = Color(1.15, 0.8, 1.35)
	elif venom_left > 0.0:
		tint = Color(0.8, 1.15, 0.8)
	if hurt_left > 0.0 and fmod(hurt_left, 0.16) < 0.08:
		tint.a = 0.45
	sprite.modulate = tint

static func direction_name(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "east" if direction.x > 0.0 else "west"
	return "south" if direction.y >= 0.0 else "north"

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.38))
	draw_circle(Vector2.ZERO, 26.0, Color(0.0, 0.0, 0.0, 0.48))
	draw_set_transform(Vector2.ZERO)
	if dead:
		return
	for trail: Dictionary in trails:
		var point: Vector2 = trail.at - global_position
		draw_circle(point + Vector2(0, -35), 19.0, Color(0.55, 0.3, 0.9, trail.life * 1.7))
	var tip := aim * 37.0
	draw_colored_polygon(PackedVector2Array([tip + aim * 9.0, tip + aim.orthogonal() * 5.0, tip - aim.orthogonal() * 5.0]), Color("d5b57b"))
	if venom_left > 0.0:
		draw_arc(Vector2.ZERO, 25.0, 0.0, TAU, 40, Color("9cda6c"), 2.0, true)
	if empower_left > 0.0:
		draw_arc(Vector2(0, -28), 40.0, 0.0, TAU, 40, Color("b58be8"), 2.0, true)
	if attack_elapsed >= T.ATTACK_WINDUP and attack_elapsed < 0.32:
		var color := Color("d6dbe4")
		if attack_empowered or "swords" in gear:
			color = Color("bc8bf2")
		color.a = clampf((0.32 - attack_elapsed) / 0.22, 0.0, 1.0)
		var angle := attack_direction.angle()
		draw_arc(Vector2(0, -25), T.ATTACK_REACH, angle - T.ATTACK_HALF_ANGLE, angle + T.ATTACK_HALF_ANGLE, 24, color, 6.0, true)
		if attack_coated or "swords" in gear:
			draw_arc(Vector2(0, -25), T.ATTACK_REACH - 9.0, angle - 0.8, angle + 0.8, 24, Color(0.6, 0.9, 0.35, color.a), 3.0, true)

extends CharacterBody2D
## Simple melee target for the combat prototype, not a final dungeon enemy.

signal defeated(enemy: Node2D)
signal damaged(at: Vector2, amount: float, kind: String)
const T = preload("res://game/tuning.gd")

var player: CharacterBody2D
var guardian := false
var tier := 1
var active := true
var dead := false
var health := 0.0
var max_health := 0.0
var body_radius := 20.0
var speed := T.ENEMY_SPEED
var damage := T.ENEMY_DAMAGE
var cooldown := 0.4
var windup := -1.0
var strike_direction := Vector2.DOWN
var knockback := Vector2.ZERO
var poison_left := 0.0
var poison_tick := 0.0
var poison_damage := 0.0
var flash_left := 0.0
var age := 0.0

func _ready() -> void:
	body_radius = 29.0 if guardian else 19.0
	max_health = (T.GUARDIAN_HEALTH if guardian else T.ENEMY_HEALTH) * (1.0 + 0.12 * (tier - 1))
	health = max_health
	speed = T.ENEMY_SPEED * (0.72 if guardian else 1.0)
	damage = T.GUARDIAN_DAMAGE if guardian else T.ENEMY_DAMAGE
	collision_layer = 4
	collision_mask = 1 | 4
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = body_radius
	shape.shape = circle
	add_child(shape)
	add_to_group("enemies")
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not active or dead:
		return
	age += delta
	flash_left = maxf(0.0, flash_left - delta)
	advance_poison(delta)
	if dead:
		return
	cooldown = maxf(0.0, cooldown - delta)
	velocity = Vector2.ZERO
	if is_instance_valid(player) and not player.dead:
		var difference: Vector2 = player.global_position - global_position
		if windup >= 0.0:
			windup -= delta
			if windup <= 0.0:
				var in_front := difference.length() < body_radius or strike_direction.dot(difference.normalized()) > 0.2
				if difference.length() <= T.ENEMY_REACH + T.BODY_RADIUS and in_front:
					player.take_damage(damage)
				windup = -1.0
				cooldown = T.ENEMY_COOLDOWN
		elif difference.length() <= T.ENEMY_REACH and cooldown <= 0.0:
			windup = T.ENEMY_WINDUP * (1.2 if guardian else 1.0)
			strike_direction = difference.normalized()
		elif difference.length() > body_radius + 22.0:
			velocity = difference.normalized() * speed
	velocity += knockback
	knockback = knockback.move_toward(Vector2.ZERO, delta * 650.0)
	move_and_slide()
	queue_redraw()

func receive_hit(payload: Dictionary, direction: Vector2) -> void:
	if dead:
		return
	var amount: float = payload.physical + payload.shadow + payload.poison
	health = maxf(0.0, health - amount)
	flash_left = 0.12
	knockback = direction * (65.0 if guardian else 140.0)
	damaged.emit(global_position, amount, "nightshade" if payload.nightshade else ("shadow" if payload.shadow > 0.0 else "physical"))
	if health <= 0.0:
		die()
		return
	if payload.dot > 0.0:
		apply_poison(payload.dot)
	queue_redraw()

func apply_poison(tick_damage: float) -> void:
	# Refresh duration; never stack or reset the pending tick on repeated hits.
	if poison_left <= 0.0:
		poison_tick = T.POISON_TICK_INTERVAL
	poison_left = T.POISON_DURATION
	poison_damage = tick_damage

func advance_poison(delta: float) -> void:
	if poison_left <= 0.0 or dead:
		return
	var elapsed := minf(delta, poison_left)
	poison_left = maxf(0.0, poison_left - delta)
	poison_tick -= elapsed
	while poison_tick <= 0.00001 and not dead:
		poison_tick += T.POISON_TICK_INTERVAL
		health = maxf(0.0, health - poison_damage)
		damaged.emit(global_position, poison_damage, "poison")
		if health <= 0.0:
			die()

func die() -> void:
	if dead:
		return
	dead = true
	active = false
	remove_from_group("enemies")
	collision_layer = 0
	collision_mask = 0
	defeated.emit(self)
	queue_free()

func _draw() -> void:
	var scale_factor := 1.4 if guardian else 1.0
	var bob := sin(age * 3.0) * 2.5
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.4))
	draw_circle(Vector2.ZERO, body_radius + 7.0, Color(0.0, 0.0, 0.0, 0.5))
	draw_set_transform(Vector2(0, -18 + bob), 0.0, Vector2.ONE * scale_factor)
	var tint := Color("655477") if guardian else Color("495a68")
	if flash_left > 0.0:
		tint = Color("e1d5c0")
	var body := PackedVector2Array([Vector2(-23, 12), Vector2(-20, -19), Vector2(-10, -36), Vector2(10, -36), Vector2(20, -19), Vector2(23, 12), Vector2(12, 7), Vector2(4, 16), Vector2(-5, 9), Vector2(-14, 16)])
	draw_colored_polygon(body, tint)
	draw_polyline(body, Color("a297b1") if guardian else Color("70828b"), 1.5, true)
	draw_colored_polygon(PackedVector2Array([Vector2(-13, -21), Vector2(0, -30), Vector2(13, -21), Vector2(10, -4), Vector2(-10, -4)]), Color("171c2a"))
	var eyes := Color("c3ed8b") if poison_left > 0.0 else Color("ef9c82")
	draw_line(Vector2(-9, -17), Vector2(-3, -15), eyes, 3.0, true)
	draw_line(Vector2(3, -15), Vector2(9, -17), eyes, 3.0, true)
	if guardian:
		draw_polyline(PackedVector2Array([Vector2(-18, -31), Vector2(-22, -44), Vector2(-8, -36), Vector2(0, -48), Vector2(8, -36), Vector2(22, -44), Vector2(18, -31)]), Color("d6b778"), 3.0, true)
	draw_set_transform(Vector2.ZERO)
	var bar_y := -85.0 if guardian else -65.0
	draw_rect(Rect2(-26, bar_y, 52, 4), Color("242431"))
	draw_rect(Rect2(-26, bar_y, 52 * health / max_health, 4), Color("b97c89") if guardian else Color("b7b6bc"))
	if poison_left > 0.0:
		draw_circle(Vector2(0, bar_y - 7), 3.0, Color("a5dc73"))
	if windup >= 0.0:
		var angle := strike_direction.angle()
		draw_arc(Vector2(0, -8), T.ENEMY_REACH, angle - 1.3, angle + 1.3, 28, Color(1.0, 0.4, 0.3, 0.8), 4.0, true)
		draw_line(Vector2(0, -8), strike_direction * T.ENEMY_REACH + Vector2(0, -8), Color("f3aa7c"), 2.0)

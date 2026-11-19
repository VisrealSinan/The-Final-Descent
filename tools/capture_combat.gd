extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var scene := load("res://game/combat.tscn") as PackedScene
	var game := scene.instantiate()
	root.add_child(game)
	await process_frame
	var mode := "combat"
	for option in OS.get_cmdline_user_args():
		if option in ["ready", "dead", "complete"]:
			mode = option
	if mode == "ready":
		await save_capture(mode)
		return
	game.start_bout()
	game.player.input_enabled = false
	game.player.position = Vector2(440, 510)
	game.player.aim = Vector2.RIGHT
	game.player.equip("swords")
	game.player.equip("mask")
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
		if enemy.guardian:
			enemy.position = Vector2(515, 510)
			enemy.apply_poison(7.5)
	game.player.try_venom()
	game.player.empower_left = 4.0
	game.player.try_attack()
	await create_timer(0.16).timeout
	game.player.set_physics_process(false)
	if mode == "dead":
		game.player.hurt_left = 0.0
		game.player.take_damage(10000)
		await create_timer(0.8).timeout
	elif mode == "complete":
		for slot: String in game.T.SLOTS:
			game.player.equip(slot)
		game.rewards.clear()
		game.bout = 5
		game.finish_bout()
	game.update_hud()
	await save_capture(mode)

func save_capture(mode: String) -> void:
	await RenderingServer.frame_post_draw
	var destination := "res://previews/combat-prototype.png" if mode == "combat" else "res://tmp/combat-" + mode + ".png"
	var result := root.get_texture().get_image().save_png(destination)
	print("Combat screenshot result: ", result)
	quit(0 if result == OK else 1)

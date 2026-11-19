extends RefCounted

static func install() -> void:
	var bindings := {
		"move_left": KEY_A, "move_right": KEY_D, "move_up": KEY_W, "move_down": KEY_S,
		"aim_left": KEY_LEFT, "aim_right": KEY_RIGHT, "aim_up": KEY_UP, "aim_down": KEY_DOWN,
		"shadowstep": KEY_Q, "venom_blades": KEY_E
	}
	for action: String in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var key := InputEventKey.new()
			key.physical_keycode = bindings[action]
			InputMap.action_add_event(action, key)

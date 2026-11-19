extends RefCounted

const STONE := ["34414b", "284851", "4b332f", "40404b", "40334e", "343044"]
const METAL := ["b1a185", "83bdaf", "d79969", "bbb08d", "b99ad2", "e8cc8c"]
const ROOM := Rect2(48, 160, 908, 612)

func draw_chamber(canvas: Node2D, depth: int, room: int) -> void:
	var stone := Color(STONE[depth - 1])
	var metal := Color(METAL[depth - 1])
	canvas.draw_rect(Rect2(0, 0, 1280, 900), Color("0c1019"))
	canvas.draw_line(Vector2(36, 143), Vector2(1244, 143), metal.darkened(0.65))
	canvas.draw_rect(ROOM.grow(8), stone.darkened(0.52))
	canvas.draw_rect(ROOM, stone.darkened(0.54))
	# Offset courses of masonry, with deterministic wear for each room.
	for row in 12:
		for col in 11:
			var left := 49 + col * 94 - 47 * (row % 2)
			var tile := Rect2(left, 161 + row * 52, 92, 50).intersection(ROOM.grow(-1))
			if tile.size.x <= 0 or tile.size.y <= 0:
				continue
			var wear := posmod(row * 13 + col * 7 + room * 5 + depth * 3, 9)
			canvas.draw_rect(tile, stone.darkened(0.23 + wear * 0.014))
			canvas.draw_line(tile.position, Vector2(tile.end.x, tile.position.y), stone.darkened(0.18))
			if wear == 2 and tile.size.x > 40:
				var start := tile.position + Vector2(28, 0)
				canvas.draw_polyline(PackedVector2Array([start, start + Vector2(-5, 8), start + Vector2(7, 16), start + Vector2(1, 23)]), stone.darkened(0.47))
	# Raised north wall with recessed lancet arches.
	canvas.draw_rect(Rect2(48, 160, 908, 93), stone.darkened(0.32))
	for i in 8:
		var x := 83.0 + i * 119.0
		var arch := PackedVector2Array([Vector2(x, 240), Vector2(x, 198), Vector2(x+25, 174), Vector2(x+50, 198), Vector2(x+50, 240)])
		canvas.draw_colored_polygon(arch, stone.darkened(0.70))
		canvas.draw_polyline(arch, stone.lightened(0.04), 3, true)
		canvas.draw_line(Vector2(x+25, 187), Vector2(x+25, 238), metal.darkened(0.62), 2)
	canvas.draw_rect(Rect2(48, 246, 908, 10), stone.darkened(0.12))
	canvas.draw_rect(Rect2(48, 256, 908, 8), Color(0, 0, 0, 0.22))
	canvas.draw_rect(Rect2(72, 267, 859, 475), metal.darkened(0.65), false, 2)
	canvas.draw_rect(Rect2(77, 272, 849, 465), stone.darkened(0.42), false, 3)
	var center := Vector2(502, 507)
	var radius := 64.0 + room * 13.0
	var outline := stone.lerp(metal, 0.16)
	canvas.draw_arc(center, radius + 10, 0, TAU, 80, outline, 2, true)
	canvas.draw_arc(center, radius, 0, TAU, 80, outline, 1, true)
	var emblem := PackedVector2Array()
	for i in (depth + 3):
		emblem.append(center + Vector2.from_angle(TAU * i / (depth + 3) - PI / 2) * (radius - 10))
	emblem.append(emblem[0])
	canvas.draw_polyline(emblem, outline, 2, true)
	draw_inlays(canvas, center, room, depth, outline, stone)
	for i in 4:
		var lamp := Vector2(104 if i % 2 == 0 else 900, 304 if i < 2 else 706)
		canvas.draw_circle(lamp, 34, Color(metal, 0.045))
		canvas.draw_circle(lamp, 20, Color(metal, 0.085))
		canvas.draw_rect(Rect2(lamp - Vector2(9, 4), Vector2(18, 11)), stone.darkened(0.7))
		canvas.draw_colored_polygon(PackedVector2Array([lamp + Vector2(-5,0), lamp+Vector2(2,-14),lamp+Vector2(6,0),lamp+Vector2(0,4)]), metal)
	canvas.draw_rect(ROOM, metal.darkened(0.47), false, 2)

func draw_inlays(canvas: Node2D, center: Vector2, room: int, depth: int, ink: Color, stone: Color) -> void:
	# Different materials survive on each landing and flank the path through its rooms.
	for sign_x in [-1, 1]:
		var at := center + Vector2(sign_x * (241 + 9 * room), 0)
		match depth:
			1: # Worn brass chevrons
				for i in 3:
					var offset := at + Vector2(0, i * 18 - 18)
					canvas.draw_polyline(PackedVector2Array([offset+Vector2(-21,9), offset+Vector2(0,-3), offset+Vector2(21,9)]), ink, 2, true)
			2: # Shallow channels with broken ripples
				canvas.draw_rect(Rect2(at-Vector2(25,116),Vector2(50,232)), stone.darkened(0.52))
				for i in 9:
					var ripple := at + Vector2(sin(i + room)*6, i*24 - 98)
					canvas.draw_arc(ripple, 13, 0.2, 2.8, 12, ink, 1.5, true)
			3: # Kiln grates
				for i in 2:
					var origin := at + Vector2(-24, i*128 - 82)
					canvas.draw_rect(Rect2(origin, Vector2(48,48)), Color("412626"))
					for j in 6:
						canvas.draw_line(origin+Vector2(3,j*8),origin+Vector2(45,j*8),ink,3)
			4: # Memorial tablets
				for i in 3:
					var origin := at + Vector2(-24,i*74-92)
					canvas.draw_rect(Rect2(origin,Vector2(48,43)), stone.darkened(0.42))
					canvas.draw_rect(Rect2(origin,Vector2(48,43)), ink, false, 1)
					canvas.draw_arc(origin+Vector2(24,17),6,0,TAU,14,ink,1.5,true)
					canvas.draw_line(origin+Vector2(13,31),origin+Vector2(35,31),ink)
			5: # Violet reliquary seals
				for i in 3:
					var p := at + Vector2(0,i*61-61)
					canvas.draw_colored_polygon(PackedVector2Array([p+Vector2(0,-23),p+Vector2(12,0),p+Vector2(0,23),p+Vector2(-12,0)]),ink.darkened(0.2))
					canvas.draw_line(p+Vector2(0,-18),p+Vector2(0,18),ink.lightened(0.15),2)
			6: # Eyes incised into the court floor
				for i in 3:
					var p := at + Vector2(0,i*70-70)
					canvas.draw_polyline(PackedVector2Array([p+Vector2(-22,0),p+Vector2(0,-10),p+Vector2(22,0),p+Vector2(0,10),p+Vector2(-22,0)]),ink,2,true)
					canvas.draw_circle(p,4,ink)

func draw_gate(canvas: Node2D, at: Vector2, direction: Vector2i, unlocked: bool, forward: bool) -> void:
	var axis := Vector2(direction)
	var tint := Color("e7c47e") if forward else Color("89b9c1")
	if not unlocked:
		tint = Color("a46f73")
	canvas.draw_set_transform(at, axis.angle())
	canvas.draw_rect(Rect2(-17, -34, 39, 68), Color("121620"))
	canvas.draw_rect(Rect2(-18, -37, 42, 6), tint.darkened(0.28))
	canvas.draw_rect(Rect2(-18, 31, 42, 6), tint.darkened(0.28))
	if unlocked:
		for x in [-10, 2]:
			canvas.draw_polyline(PackedVector2Array([Vector2(x-4,-12),Vector2(x+5,0),Vector2(x-4,12)]),tint,3,true)
	else:
		for y in [-19, -6, 7, 20]:
			canvas.draw_line(Vector2(-14,y),Vector2(18,y),tint,4)
	canvas.draw_set_transform(Vector2.ZERO)
	var caption := "GATE" if forward else "RETURN"
	if not unlocked:
		caption = "SEALED"
	var text_at := at + Vector2(-45, -44)
	if direction == Vector2i.UP:
		text_at.y = at.y + 42
	canvas.draw_string(ThemeDB.fallback_font, text_at, caption, HORIZONTAL_ALIGNMENT_CENTER, 90, 13, tint)

func draw_stairs(canvas: Node2D, at: Vector2, clock: float) -> void:
	var gold := Color("e9c27e")
	canvas.draw_circle(at, 54.0 + 2.0 * sin(clock * 3), Color(gold, 0.14))
	canvas.draw_rect(Rect2(at - Vector2(36,29), Vector2(72,58)), Color("11121c"))
	for i in 5:
		var half_width := 29.0 - i * 3
		canvas.draw_line(at+Vector2(-half_width,-20+i*10),at+Vector2(half_width,-20+i*10),gold.darkened(i*0.11),3)
	canvas.draw_string(ThemeDB.fallback_font, at + Vector2(-55, -44), "DESCEND", HORIZONTAL_ALIGNMENT_CENTER, 110, 15, gold)

func draw_map(canvas: Node2D, route: Array, current: int, cleared: Array[int]) -> void:
	var points := PackedVector2Array([Vector2.ZERO])
	var bounds := Rect2(Vector2.ZERO, Vector2.ZERO)
	for step: Vector2i in route:
		var point := points[-1] + Vector2(step) * 18.0
		points.append(point)
		bounds = bounds.expand(point)
	var offset := Vector2(736, 40) - bounds.get_center()
	for i in points.size():
		points[i] += offset
	canvas.draw_polyline(points, Color("6a626c"), 2, true)
	for i in points.size():
		var point := points[i]
		canvas.draw_rect(Rect2(point - Vector2(5,5), Vector2(10,10)), Color("29303c"))
		canvas.draw_rect(Rect2(point - Vector2(5,5), Vector2(10,10)), Color("dbc28e") if i in cleared else Color("898190"), false, 1)
		if i == current:
			canvas.draw_circle(point, 3.5, Color("f7e2a7"))
		elif i == 4:
			canvas.draw_circle(point, 2.4, Color("dc8a89"))

func draw_searchlight(canvas: Node2D, x: float, half_width: float, exposed: bool) -> void:
	var glow := Color("ffaf71") if exposed else Color("f0dc91")
	canvas.draw_rect(Rect2(x-half_width, 266, half_width*2, 479), Color(glow, 0.17))
	for edge in [x-half_width, x+half_width]:
		canvas.draw_line(Vector2(edge,266), Vector2(edge,745),Color(glow,0.63),2)
	var eye := Vector2(x, 226)
	canvas.draw_colored_polygon(PackedVector2Array([eye+Vector2(-22,0), eye+Vector2(0,-10), eye+Vector2(22,0), eye+Vector2(0,10)]), glow)
	canvas.draw_circle(eye, 6, Color("292033"))

class_name GameView
extends Control
## Where the game's pixels live: its own little low-resolution screen, at least
## 480 by 270 and always a whole number of the window's pixels, with the crisp full
## resolution UI over it. All the distance between the two is the point.

const BASE := Vector2(480, 270)

var viewport: SubViewport
var _picture: TextureRect
var _shine: WorldShine
var world: World
var _by := 1.0
var _fitted_to := Vector2i.ZERO
## UI units to a game pixel.
var ui_scale := 4.0


func _init() -> void:
	viewport = SubViewport.new()
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	viewport.snap_2d_transforms_to_pixel = true
	viewport.snap_2d_vertices_to_pixel = true
	viewport.size = Vector2i(BASE)
	viewport.own_world_3d = true
	add_child(viewport)
	_picture = TextureRect.new()
	_picture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var picture_shader := ShaderMaterial.new()
	picture_shader.shader = preload("res://src/fx/picture.gdshader")
	_picture.material = picture_shader
	_picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_picture.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(_picture)
	_shine = WorldShine.new()
	_shine.view = self
	add_child(_shine)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_picture.texture = viewport.get_texture()
	_fit()


func _process(_delta: float) -> void:
	_fit()


func _fit() -> void:
	var window := get_window().size
	if window == _fitted_to or window.x <= 0 or window.y <= 0:
		return
	_fitted_to = window
	_by = maxf(1.0, floorf(minf(window.x / BASE.x, window.y / BASE.y)))
	viewport.size = Vector2i(ceili(window.x / _by), ceili(window.y / _by))
	# The UI's units aren't the window's pixels, unless the window's exactly 1920 by 1080.
	var units := get_viewport_rect().size.x / float(window.x)
	ui_scale = _by * units
	_picture.position = Vector2.ZERO
	_picture.size = Vector2(viewport.size) * ui_scale


func show_world(the_world: World) -> void:
	world = the_world
	world.view = self
	viewport.add_child(world)


## Where a place in the world is, in the UI's units.
func world_to_ui(pos: Vector2) -> Vector2:
	return viewport.get_canvas_transform() * pos * ui_scale


## Where the pointer is, in the game's pixels.
func pointer() -> Vector2:
	return get_global_mouse_position() / ui_scale


## Over the game's pixels, on exactly the same grid: the bright things in the world
## again, past white, so the screen's glow catches them. The pixels stay pixels; only
## the light coming off them is smooth.
class WorldShine extends Control:
	var view: GameView

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var add := CanvasItemMaterial.new()
		add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		material = add

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		var world: World = view.world
		if world == null or not world.is_inside_tree() or world.fx == null:
			return
		var by := view.ui_scale
		var to := view.viewport.get_canvas_transform()
		_walls(world, to, by)
		_missiles(world, to, by)
		for s in world.shots.list:
			var at: Vector2 = to * s.pos * by
			draw_rect(Rect2(at - Vector2(by, by), Vector2(by, by) * 2.0), UI.glow(Color("ff8a1f"), 1.3))
		for p in world.fx.particles:
			var at: Vector2 = to * p.pos * by
			var c: Color = UI.glow(p.color, 1.8)
			c.a = clampf(p.life / p.total * 1.5, 0.0, 1.0)
			draw_rect(Rect2(at, Vector2(p.size, p.size) * by), c)
		for r in world.fx.rings:
			var t: float = r.time / r.total
			var c: Color = UI.glow(r.color, 1.8)
			c.a = 1.0 - t
			var radius: float = maxf(r.radius * (1.0 - (1.0 - t) * (1.0 - t)), 1.0) * by
			draw_arc(to * r.pos * by, radius, 0.0, TAU, 48, c, by * (1.0 + (1.0 - t)), false)
		_ship(world, to, by)
		if world.boss != null and world.boss.has_method("hazards") and world.boss.alive:
			for line: Array in world.boss.call("hazards"):
				var a: Vector2 = to * (line[0] as Vector2) * by
				var b: Vector2 = to * (world.boss.call("clip", line[1]) as Vector2) * by
				draw_line(a, b, UI.glow(UI.RED, 1.2), by, false)

	func _walls(world: World, to: Transform2D, by: float) -> void:
		var area := Rect2(to * world.arena.position * by, world.arena.size * by).grow(by)
		var c := world.edge_color()
		draw_rect(area, UI.glow(c, 0.75 + world.fx.wall_hit * 1.5), false, by * 2.0)

	func _missiles(world: World, to: Transform2D, by: float) -> void:
		var m := world.missiles
		for i in m.count:
			var at: Vector2 = to * m.positions[i] * by
			var hot: bool = m.damages[i] >= Balance.MISSILE_DAMAGE * (1.0 + Balance.SPEED_DAMAGE * 0.6)
			draw_rect(Rect2(at, Vector2(by, by)), UI.glow(UI.YELLOW if hot else UI.CYAN, 1.6))

	func _ship(world: World, to: Transform2D, by: float) -> void:
		var ship := world.ship
		if ship.state == Ship.State.DEAD:
			return
		var at: Vector2 = to * ship.pos * by
		var glow_tex := Sprites.get_tex("glow")
		var gold := ship.is_smasking() or (ship.invulnerable > 0.0 and ship.safe_from_smask)
		var charge := ship.charge if ship.state == Ship.State.CHARGING else 0.0
		var amount := 1.0 if gold else charge * 0.8
		if amount > 0.0:
			var reach := by * 14.0
			draw_texture_rect(glow_tex, Rect2(at - Vector2(reach, reach), Vector2(reach, reach) * 2.0), false, UI.glow(Color(1.0, 0.8, 0.25, amount), 2.5))

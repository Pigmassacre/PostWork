class_name GameView
extends Control
## Where the game's pixels live: its own little low-resolution screen, at least
## 480 by 270 and always a whole number of the window's pixels, with the crisp full
## resolution UI over it. All the distance between the two is the point.

const BASE := Vector2(480, 270)

var viewport: SubViewport
var _picture: TextureRect
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
	add_child(viewport)
	_picture = TextureRect.new()
	_picture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_picture.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(_picture)


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


func show_world(world: World) -> void:
	world.view = self
	viewport.add_child(world)


## Where a place in the world is, in the UI's units.
func world_to_ui(pos: Vector2) -> Vector2:
	return viewport.get_canvas_transform() * pos * ui_scale


## Where the pointer is, in the game's pixels.
func pointer() -> Vector2:
	return get_global_mouse_position() / ui_scale

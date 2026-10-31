class_name Skyline
extends Control
## What's behind the game's pixels, in full resolution: the city as the evening goes
## by (src/fx/city.gdshader), and the floor hanging over it (src/fx/floor.gdshader).

## Top and bottom of the sky, by how far the evening's got, 0 to 1.
const SKIES := [
	[0.0, Color("3a1f6e"), Color("ff8a3c")],
	[0.25, Color("2a1660"), Color("e0406f")],
	[0.5, Color("170f4a"), Color("8a2f8f")],
	[0.75, Color("090728"), Color("35206e")],
	[1.0, Color("03030f"), Color("1c1040")],
]

var view: GameView
var _city := ShaderMaterial.new()
var _floor := ShaderMaterial.new()
var _floor_rect := ColorRect.new()
var _clock := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var city_rect := ColorRect.new()
	city_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	city_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_city.shader = preload("res://src/fx/city.gdshader")
	city_rect.material = _city
	add_child(city_rect)
	_floor_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_floor.shader = preload("res://src/fx/floor.gdshader")
	_floor_rect.material = _floor
	add_child(_floor_rect)


static func _sky_at(night: float, which: int) -> Color:
	for i in SKIES.size() - 1:
		if night <= SKIES[i + 1][0]:
			var t := inverse_lerp(float(SKIES[i][0]), float(SKIES[i + 1][0]), night)
			return (SKIES[i][which] as Color).lerp(SKIES[i + 1][which], t)
	return SKIES[SKIES.size() - 1][which]


func _process(delta: float) -> void:
	var world := view.world
	if world == null or not world.is_inside_tree():
		return
	_clock += delta
	var night := world.night()
	var by := view.ui_scale
	var to := view.viewport.get_canvas_transform()
	_city.set_shader_parameter("screen", size)
	_city.set_shader_parameter("night", night)
	_city.set_shader_parameter("clock", _clock)
	_city.set_shader_parameter("camera_x", (world.camera_centre().x) * by)
	_city.set_shader_parameter("sky_top", _sky_at(night, 1))
	_city.set_shader_parameter("sky_bottom", _sky_at(night, 2))
	var margin := by * 16.0
	var area := world.arena.size * by
	_floor_rect.position = to * world.arena.position * by - Vector2(margin, margin)
	_floor_rect.size = area + Vector2(margin, margin) * 2.0
	_floor.set_shader_parameter("area", area)
	_floor.set_shader_parameter("margin", margin)
	_floor.set_shader_parameter("unit", by)
	_floor.set_shader_parameter("clock", _clock)
	_floor.set_shader_parameter("pop", world.floor_pop)
	_floor.set_shader_parameter("wall_hit", world.fx.wall_hit)
	_floor.set_shader_parameter("tint", world.floor_tint())
	_floor.set_shader_parameter("edge", world.edge_color())

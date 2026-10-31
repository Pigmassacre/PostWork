class_name MenuScreen
extends Node
## A screen of the menus: the sunburst, a heading slammed across the top, and Back.

var ui: Control
var body: Control
var back: SmaskButton
var _shaker: Control


func build(title: String, content_is_column := true) -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	ui = Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(ui)
	ui.add_child(Backdrop.new())
	_shaker = Control.new()
	_shaker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shaker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(_shaker)
	var heading := Heading.new(title)
	heading.position = Vector2(40, 34)
	heading.size = Vector2(1500, 140)
	_shaker.add_child(heading)
	if content_is_column:
		var column := VBoxContainer.new()
		column.add_theme_constant_override("separation", 12)
		body = column
	else:
		body = Control.new()
		body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	body.offset_left = 110
	body.offset_right = -110
	body.offset_top = 196
	body.offset_bottom = -130
	_shaker.add_child(body)
	back = SmaskButton.new("BACK", 34)
	back.alignment = HORIZONTAL_ALIGNMENT_CENTER
	back.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	back.offset_left = 70
	back.offset_right = 370
	back.offset_top = -104
	back.offset_bottom = -36
	back.pressed.connect(go_back)
	_shaker.add_child(back)
	back.pop_in(0.1)
	back.grab_focus()


func go_back() -> void:
	Game.main.show_screen("title", {}, 0.2)


func _process(_delta: float) -> void:
	if _shaker and UI.fx:
		_shaker.position = UI.fx.offset


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		go_back()

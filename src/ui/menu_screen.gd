class_name MenuScreen
extends Node
## A screen of the menus: a heading over the dark, and Back at the bottom.

var ui: Control
var body: VBoxContainer
var back: Button


func build(title: String) -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	ui = Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(ui)
	var bg := ColorRect.new()
	bg.color = UI.PANEL
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(bg)
	var heading := UI.label(title, UI.ACCENT, true)
	heading.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	heading.offset_left = -220
	heading.offset_right = 220
	heading.offset_top = 8
	heading.offset_bottom = 30
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.add_child(heading)
	body = VBoxContainer.new()
	body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	body.offset_left = 24
	body.offset_right = -24
	body.offset_top = 36
	body.offset_bottom = -22
	body.add_theme_constant_override("separation", 2)
	ui.add_child(body)
	back = UI.button("Back")
	back.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	back.offset_left = -30
	back.offset_right = 30
	back.offset_top = -18
	back.offset_bottom = -4
	back.pressed.connect(go_back)
	ui.add_child(back)
	back.grab_focus()


func go_back() -> void:
	Game.main.show_screen("title", {}, 0.2)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		go_back()

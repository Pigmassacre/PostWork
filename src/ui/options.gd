extends Node
## The title's Options.

var _shaker: Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	var ui := Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(ui)
	ui.add_child(Backdrop.new())
	var panel := OptionsPanel.new()
	panel.closed.connect(func() -> void: Game.main.show_screen("title", {}, 0.2))
	ui.add_child(panel)
	_shaker = panel


func _process(_delta: float) -> void:
	if UI.fx:
		_shaker.position = UI.fx.offset


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		Game.main.show_screen("title", {}, 0.2)

extends MenuScreen
## Who made what.


func _ready() -> void:
	build("CREDITS")
	var text := UI.label(FileAccess.get_file_as_string("res://src/data/credits.txt"), UI.SOFT)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(text)

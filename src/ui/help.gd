extends MenuScreen
## How it's played.


func _ready() -> void:
	build("HOW IT'S PLAYED")
	var lines := [
		["FLY.", "%s turns you and shoves you. You've got a lot of momentum and very little grip." % _move_text(), UI.SOFT],
		["THE GUNS AIM THEMSELVES.", "A salvo of homing missiles, eight times a second, at everything they can reach. The faster you're flying, the harder they hit.", UI.SOFT],
		["HOLD %s TO CHARGE." % Inputs.prompt("smask").to_upper(), "The guns stop, the ship brakes, the world slows. Point yourself at something.", UI.SOFT],
		["LET GO TO SMASK.", "You go straight through it, and can't be hurt while you do. A kill means you can go again at once. Hit a wall and it's a shock wave.", UI.ACCENT],
		["SHELLS.", "Missiles bounce off a hermit. Only a SMASK cracks one.", UI.SOFT],
		["COUNT IT DOWN.", "The number on the floor is what's left of the hour. At zero the clock moves on and you take a perk. It's 17:00. Get to midnight.", UI.SOFT],
	]
	for line: Array in lines:
		body.add_child(UI.label(line[0], line[2]))
		var text := UI.label(line[1], UI.DIM)
		text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.add_child(text)


func _move_text() -> String:
	var move := Inputs.prompt("move")
	return move[0].to_upper() + move.substr(1)

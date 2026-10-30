extends Node
## Sets up the input actions in code, so they live in one readable place, keeps
## track of what the player last played with, so the prompts can name the right
## button, and answers the two questions the game has: where's the ship being
## told to go, and is the SMASK being held?

enum Device { KEYBOARD, MOUSE, PAD, TOUCH }

signal device_changed(device: Device)
## A controller has gone away mid-game (out of battery, unplugged).
signal pad_lost

const KEYS := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"thrust": [],
	"smask": [KEY_SPACE, KEY_SHIFT, KEY_J, KEY_Z],
	"pause": [KEY_ESCAPE, KEY_P],
}

const BUTTONS := {
	"move_left": [JOY_BUTTON_DPAD_LEFT],
	"move_right": [JOY_BUTTON_DPAD_RIGHT],
	"move_up": [JOY_BUTTON_DPAD_UP],
	"move_down": [JOY_BUTTON_DPAD_DOWN],
	"smask": [JOY_BUTTON_A, JOY_BUTTON_X, JOY_BUTTON_RIGHT_SHOULDER, JOY_BUTTON_LEFT_SHOULDER],
	"pause": [JOY_BUTTON_START, JOY_BUTTON_BACK],
}

## Action: [axis, direction]
const AXES := {
	"move_left": [JOY_AXIS_LEFT_X, -1.0],
	"move_right": [JOY_AXIS_LEFT_X, 1.0],
	"move_up": [JOY_AXIS_LEFT_Y, -1.0],
	"move_down": [JOY_AXIS_LEFT_Y, 1.0],
	# The original's: the right trigger thrusts along wherever the ship points.
	"thrust": [JOY_AXIS_TRIGGER_RIGHT, 1.0],
	"smask": [JOY_AXIS_TRIGGER_LEFT, 1.0],
}

const MOUSE := {
	"smask": [MOUSE_BUTTON_LEFT],
	"thrust": [MOUSE_BUTTON_RIGHT],
}

var device := Device.KEYBOARD
## Running on a Steam Deck (or pretending to, with `--deck`).
var deck := _is_deck()
## The pad's prompts: Xbox's letters, or PlayStation's shapes.
var playstation := false
## The pad last used, for the rumble.
var last_pad := 0
var _rumble_until := 0
var _rumble_level := 0.0
var _pointer_seen := false
## What the on-screen controls say, when played by finger (src/play/touch_controls.gd).
var touch_move := Vector2.ZERO
var touch_smask := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for action: String in KEYS:
		if not InputMap.has_action(action):
			InputMap.add_action(action, 0.2)
		for key: Key in KEYS[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)
		for button: JoyButton in BUTTONS.get(action, []):
			var press := InputEventJoypadButton.new()
			press.button_index = button
			InputMap.action_add_event(action, press)
		if AXES.has(action):
			var motion := InputEventJoypadMotion.new()
			motion.axis = AXES[action][0]
			motion.axis_value = AXES[action][1]
			InputMap.action_add_event(action, motion)
		for mouse_button: MouseButton in MOUSE.get(action, []):
			var click := InputEventMouseButton.new()
			click.button_index = mouse_button
			InputMap.action_add_event(action, click)
	for action in ["move_left", "move_right", "move_up", "move_down"]:
		InputMap.action_set_deadzone(action, 0.18)
	InputMap.action_set_deadzone("thrust", 0.25)
	InputMap.action_set_deadzone("smask", 0.4)
	# The menus answer to a pad and WASD too.
	_add_ui("ui_accept", [JOY_BUTTON_A], [KEY_SPACE])
	_add_ui("ui_cancel", [JOY_BUTTON_B], [])
	_add_ui("ui_up", [JOY_BUTTON_DPAD_UP], [KEY_W], JOY_AXIS_LEFT_Y, -1.0)
	_add_ui("ui_down", [JOY_BUTTON_DPAD_DOWN], [KEY_S], JOY_AXIS_LEFT_Y, 1.0)
	_add_ui("ui_left", [JOY_BUTTON_DPAD_LEFT], [KEY_A], JOY_AXIS_LEFT_X, -1.0)
	_add_ui("ui_right", [JOY_BUTTON_DPAD_RIGHT], [KEY_D], JOY_AXIS_LEFT_X, 1.0)
	if DisplayServer.is_touchscreen_available() and (OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")):
		device = Device.TOUCH
	# A Deck's controls are a pad, whatever was last touched.
	if deck:
		device = Device.PAD
	Input.joy_connection_changed.connect(_on_joy_connection)


## SteamOS says so when Steam starts the game; otherwise the board is Valve's (the LCD's, and the OLED's).
static func _is_deck() -> bool:
	if OS.get_cmdline_user_args().has("--deck") or OS.get_environment("SteamDeck") == "1":
		return true
	if OS.get_name() == "Linux":
		for file: String in ["/sys/devices/virtual/dmi/id/board_name", "/sys/devices/virtual/dmi/id/product_name"]:
			if FileAccess.file_exists(file) and FileAccess.get_file_as_string(file).strip_edges() in ["Jupiter", "Galileo"]:
				return true
	return false


func _on_joy_connection(_pad: int, connected: bool) -> void:
	if not connected and device == Device.PAD:
		pad_lost.emit()


## Adds pad buttons, keys and a stick direction to a UI action.
func _add_ui(action: String, buttons: Array, keys: Array, axis := -1, direction := 0.0) -> void:
	for button: JoyButton in buttons:
		var press := InputEventJoypadButton.new()
		press.button_index = button
		InputMap.action_add_event(action, press)
	for key: Key in keys:
		var event := InputEventKey.new()
		event.physical_keycode = key
		InputMap.action_add_event(action, event)
	if axis >= 0:
		var motion := InputEventJoypadMotion.new()
		motion.axis = axis
		motion.axis_value = direction
		InputMap.action_add_event(action, motion)


func _input(event: InputEvent) -> void:
	var now := device
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		now = Device.TOUCH
	elif event is InputEventMouseButton or (event is InputEventMouseMotion and event.relative.length() > 1.0):
		# A window that has just opened gets told where the pointer is: nobody has moved it.
		if event is InputEventMouseMotion and not _pointer_seen:
			_pointer_seen = true
		elif event.device != InputEvent.DEVICE_ID_EMULATION:
			now = Device.MOUSE
	elif event is InputEventKey:
		now = Device.KEYBOARD
	elif event is InputEventJoypadButton or (event is InputEventJoypadMotion and absf(event.axis_value) > 0.5):
		now = Device.PAD
		last_pad = event.device
		var pad_name := Input.get_joy_name(event.device).to_lower()
		playstation = pad_name.contains("ps") or pad_name.contains("dualsense") or pad_name.contains("dualshock") \
			or pad_name.contains("playstation") or pad_name.contains("sony")
	if now != device:
		device = now
		device_changed.emit(device)


## Which way the ship's told to go, up to length 1. A mouse flies at the pointer
## from where the ship is, `ship_on_screen`, while the right button's held.
func steer(ship_on_screen: Vector2, pointer: Vector2) -> Vector2:
	if device == Device.TOUCH:
		return touch_move
	if device == Device.MOUSE:
		var to := pointer - ship_on_screen
		return to.normalized() if to.length() > 6.0 else Vector2.ZERO
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


## How hard the ship's thrusting, 0 to 1, given how far it's being steered.
func thrust(steering: Vector2) -> float:
	if device == Device.MOUSE:
		return 1.0 if Input.is_action_pressed("thrust") else 0.0
	# The trigger does it from wherever the ship points; so does the stick, by being pushed.
	var trigger := Input.get_action_strength("thrust")
	return maxf(trigger, 1.0 if steering.length() > Balance.STICK_DEADZONE else 0.0)


func smask_held() -> bool:
	if device == Device.TOUCH:
		return touch_smask
	return Input.is_action_pressed("smask")


## A shake of the pad, 0 to 1. A small one doesn't cut a big one short.
func rumble(amount: float) -> void:
	if device != Device.PAD or not Game.settings.rumble:
		return
	var now := Time.get_ticks_msec()
	if now < _rumble_until and amount <= _rumble_level:
		return
	var seconds := 0.06 + amount * 0.22
	_rumble_level = amount
	_rumble_until = now + int(seconds * 1000.0)
	Input.start_joy_vibration(last_pad, clampf(amount * 1.2, 0.0, 1.0), clampf(amount, 0.0, 1.0), seconds)


## What to press for `action`, on what the player is playing with now.
func prompt(action: String) -> String:
	match device:
		Device.TOUCH:
			return {"smask": "your right thumb", "pause": "the corner", "move": "your left thumb", "accept": "tap"}.get(action, "tap")
		Device.PAD:
			if playstation:
				return {"smask": "Cross", "pause": "Options", "move": "the left stick", "accept": "Cross"}.get(action, "Cross")
			return {"smask": "A", "pause": "Menu" if deck else "Start", "move": "the left stick", "accept": "A"}.get(action, "A")
		Device.MOUSE:
			return {"smask": "left click", "pause": "Esc", "move": "right click", "accept": "click"}.get(action, "click")
	return {"smask": "Space", "pause": "Esc", "move": "WASD", "accept": "Space"}.get(action, "Space")

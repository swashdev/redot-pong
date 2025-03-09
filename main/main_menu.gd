extends Control
# The main menu for Redot Pong.


#region Signals

# Note: These signals are only used as middle men between the menu buttons and
# Main.  Therefore, instead of writing a function to emit the signals, the
# buttons connect to the `emit_signal` function.
@warning_ignore("unused_signal")
signal requested_unpause
@warning_ignore("unused_signal")
signal requested_new_game(two_players: bool)
@warning_ignore("unused_signal")
signal requested_quit_game

#endregion Signals

#region Buttons

@onready var start_button = $Buttons/StartButton
@onready var resume_button = $Buttons/ResumeButton

#endregion Buttons


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("visibility_changed", _on_visibility_changed)
	update_version_number()
	# The start button should have focus first.
	start_button.grab_focus()


# Fill out the version number label with comprehensive version data.
func update_version_number() -> void:
	var pong_version: String = Global.get_nice_version()
	var info: Dictionary = Engine.get_version_info()
	var engine_version: String
	if not Global.report_full_redot_version:
		engine_version = info["string"]
	else:
		engine_version = "%d.%d" % [info["major"], info["minor"]]
		if info["patch"] > 0:
			engine_version += "." + str(info["patch"])
		engine_version += "." + info["status"]
		if info["status"] != "stable" and info.has("status_version"):
			if info["status_version"] > 0:
				engine_version += "." + str(info["status_version"])
		engine_version += "." + info["build"] + "." + info["hash"].left(9)
	if OS.is_debug_build():
		engine_version += " (debug)"
	var version_text: String = "Version " + pong_version + ", " + \
			"running on Redot Engine " + engine_version

	$VersionNumberLabel.set_text(version_text)


# Called whenever the menu is hidden or shown.
func _on_visibility_changed() -> void:
	if visible:
		# If the menu just popped up, choose a button to give focus to.
		# Favor the "Resume" button if it is available; otherwise, the "Start
		# Game" button.
		if resume_button.is_visible():
			resume_button.grab_focus()
		else:
			start_button.grab_focus()


var _sequence: int = 0
# Called when an input event occurs.
func _input(event) -> void:
	if _sequence < 10 and event.is_pressed():
		var keycode: Key = KEY_NONE
		var button: JoyButton = JOY_BUTTON_INVALID
		if event is InputEventKey:
			keycode = event.get_keycode()
		elif event is InputEventJoypadButton:
			button = event.get_button_index()
		else:
			return
		if keycode == KEY_UP or button == JOY_BUTTON_DPAD_UP:
			if _sequence < 2:
				_sequence += 1
			else:
				_sequence = 1
		elif keycode == KEY_DOWN or button == JOY_BUTTON_DPAD_DOWN:
			if _sequence >= 2 and _sequence < 4:
				_sequence += 1
			else:
				_sequence = 0
		elif keycode == KEY_LEFT or button == JOY_BUTTON_DPAD_LEFT:
			if _sequence == 4 or _sequence == 6:
				_sequence += 1
			else:
				_sequence = 0
		elif keycode == KEY_RIGHT or button == JOY_BUTTON_DPAD_RIGHT:
			if _sequence == 5 or _sequence == 7:
				_sequence += 1
			else:
				_sequence = 0
		elif keycode == KEY_A or button == JOY_BUTTON_A:
			if _sequence == 9:
				_sequence += 1
				$Buttons/DebugMenuButton.show()
				$Buttons/DebugMenuButton.grab_focus()
			else:
				_sequence = 0
		elif keycode == KEY_B or button == JOY_BUTTON_B:
			if _sequence == 8:
				_sequence += 1
			else:
				_sequence = 0
		else:
			_sequence = 0

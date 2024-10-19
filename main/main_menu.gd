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
		if info.has("status_version"):
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

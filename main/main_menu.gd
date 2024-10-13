extends Control
# The main menu for Redot Pong.


signal requested_new_game(two_players: bool)
signal requested_quit_game


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Fill out the version number label with comprehensive version data.
	var pong_version: String = Global.get_version_string()
	var info: Dictionary = Engine.get_version_info()
	var engine_version: String
	if not Global.report_full_redot_version:
		engine_version = info["string"]
	else:
		engine_version = "%d.%d" % [info["major"], info["minor"]]
		if info["patch"] > 0:
			engine_version += ".%d" % info["patch"]
		engine_version += ".%s.%s.%s" % [info["status"], info["build"], \
				info["hash"].left(9)]
	if OS.is_debug_build():
		engine_version += " (debug)"
	var version_text: String = "Version " + pong_version + ", " + \
			"running on Redot Engine " + engine_version

	$VersionNumberLabel.set_text(version_text)

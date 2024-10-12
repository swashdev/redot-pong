extends Control
# The main menu for Redot Pong.


signal requested_new_game(two_players: bool)
signal requested_quit_game


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Fill out the version number label with comprehensive version data.
	var redot_pong_version: String = Global.get_version_string()
	var redot_engine_version: String = Engine.get_version_info()["string"]
	if OS.is_debug_build():
		redot_engine_version += " (debug)"
	var version_text: String = "Version " + redot_pong_version + ", " + \
			"running on Redot Engine " + redot_engine_version

	$VersionNumberLabel.set_text(version_text)

extends "res://main/settings/settings_menu.gd"


# Update setting checkboxes which might be affected by compile-time shenanigans
func _ready() -> void:
	$ScrollContainer/GridContainer/FullRedotVersionToggle.button_pressed = \
			Global.report_full_redot_version

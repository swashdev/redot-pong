extends ConfirmationDialog
# A script for the Settings menu.


# Emitted when the user has elected to save their changed settings.
signal requested_save(num_changes: int)


# Which settings have been changed since the settings have last been saved.
# Discarded after the settings have been saved.
var changed: Dictionary = {}


# Clears the list of changed settings.
func clear_changes() -> void:
	changed.clear()


# Requests the program to save the changed settings and then closes the window.
func save_and_close() -> void:
	if not changed.is_empty():
		emit_signal("requested_save", changed.size())
	hide()


# Discards the saved changes and closes the window.
func discard_and_close() -> void:
	if not changed.is_empty():
		emit_signal("requested_save", 0)
	hide()


# Called when a setting has been changed.  `setting` is the setting which has
# been changed, and `value` is its new value.
func _on_setting_changed(value: Variant, setting: int) -> void:
	changed[setting] = value

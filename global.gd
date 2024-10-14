extends Node
# Used to handle global variables and functions.


#region Configuration

# If set to `true`, the ball will change color when it bounced off of a paddle.
var color_changing_ball: bool = true

# If set to `true`, a more verobse version number will be given for the Redot
# Engine.  This is potentially beneficial for tracking down bugs.  For now
# this defaults to true.
var report_full_redot_version: bool = true

#endregion Configuration

#region Version Number

const VERSION_MAJOR: int = 0
const VERSION_MINOR: int = 1
const VERSION_PATCH: int = 0
const VERSION_BUILD: String = "alpha.3"

# Returns the version number as a string.
func get_version_string() -> String:
	var result: String = "%d.%d" % [VERSION_MAJOR, VERSION_MINOR]

	if VERSION_PATCH > 0 or VERSION_MAJOR < 1:
		result += ".%d" % VERSION_PATCH

	if VERSION_BUILD != "stable" and VERSION_BUILD != "":
		result += "-" + VERSION_BUILD

	if VERSION_MAJOR == 1 and VERSION_MINOR == 0:
		result += " 🥳"

	return result

# Returns the version number as a string following the semantic versioning
# standard.  Essentially `get_version_string` but longer.
func get_semantic_version() -> String:
	var result: String = "%d.%d.%d" % [VERSION_MAJOR, VERSION_MINOR, \
			VERSION_PATCH]

	if VERSION_BUILD != "stable" and VERSION_BUILD != "":
		result += "-" + VERSION_BUILD

	return result

#endregion Version Number

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
const VERSION_BUILD: String = "alpha.4"
const IS_DEV_BUILD: bool = true


# Returns `true` if the current build is a prerelease.
func is_prerelease() -> bool:
	return IS_DEV_BUILD or (VERSION_BUILD != "" and VERSION_BUILD != "stable")


# Returns the version number as a string following the semantic versioning
# standard.  More technical and more terse than `get_nice_version`.
func get_semantic_version() -> String:
	var result: String = "%d.%d.%d" % [VERSION_MAJOR, VERSION_MINOR, \
			VERSION_PATCH]

	if VERSION_BUILD != "stable" and VERSION_BUILD != "":
		result += "-" + VERSION_BUILD
		if IS_DEV_BUILD:
			result += ".dev"
	elif IS_DEV_BUILD:
		result += "-dev"

	return result


# Returns the version number as a string.  The output is verbose and intended
# to be human-readable and pleasant.
func get_nice_version() -> String:
	var result: String = "%d.%d" % [VERSION_MAJOR, VERSION_MINOR]

	if VERSION_PATCH > 0:
		result += ".%d" % VERSION_PATCH

	if is_prerelease():
		var prerelease_data: PackedStringArray = VERSION_BUILD.split(".", false)
		for element in prerelease_data:
			if element == "stable":
				break
			elif element == "rc":
				result += " Release Candidate"
			else:
				result += " " + element.capitalize()
		if IS_DEV_BUILD:
			result += " (dev build)"
	elif result == "1.0":
		result += " 🥳"

	return result

#endregion Version Number

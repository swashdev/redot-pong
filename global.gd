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
const VERSION_BUILD: String = "beta.2"
const IS_DEV_BUILD: bool = false


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

#region Settings Menu

# This enum is used to determine what settings have been changed by the Options
# or Debug menu.
enum Setting \
{
	FULL_REDOT_VERSION = 0,
	COLOR_CHANGING_BALL = 1,
	# This is a dummy value.  Values >= `DEBUG` are reserved for the debug menu
	# and may affect game scoring.
	DEBUG = 100,
	DEBUG_PADDLE_1_HEIGHT = 101,
	DEBUG_PADDLE_1_WIDTH = 102,
	DEBUG_PADDLE_2_HEIGHT = 103,
	DEBUG_PADDLE_2_WIDTH = 104,
	DEBUG_BALL_RADIUS = 105,
	DEBUG_SCORING_PLAYER_1 = 106,
	DEBUG_SCORING_PLAYER_2 = 107,
	DEBUG_COLLISION_PLAYER_1 = 108,
	DEBUG_COLLISION_PLAYER_2 = 109,
	DEBUG_BASE_PADDLE_SPEED = 110,
	DEBUG_BASE_BALL_SPEED = 111,
	DEBUG_BALL_SPEED_MODIFIER = 112,
	DEBUG_BALL_SPEED_MOD_INCREASE = 113,
	DEBUG_BALL_MAX_BOUNCE_ANGLE = 114,
	DEBUG_AI_MIN_SPEED_MOD = 115,
	DEBUG_AI_MAX_SPEED_MOD = 116,
	DEBUG_AI_FRUSTRATION = 117,
	DEBUG_AI_MIN_FRUSTRATION = 118,
	DEBUG_AI_MAX_FRUSTRATION = 119,
	DEBUG_AI_START_FRUSTRATION = 120,
	DEBUG_AI_FRUSTRATION_INCREASE = 121,
	DEBUG_AI_FRUSTRATION_THRESHOLD = 122,
	DEBUG_AI_FRUSTRATION_MULTIPLIER = 123,
	DEBUG_AI_FRUSTRATION_ERROR = 124,
	DEBUG_WINNING_SCORE = 125,
}

#endregion Settings Menu

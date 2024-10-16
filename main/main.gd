extends Node2D
# The main scene for Redot Pong.


#region Child Nodes

@onready var main_menu = $UI/MainMenu
@onready var resume_button = $UI/MainMenu/Buttons/ResumeButton
@onready var debug_menu_button = $UI/MainMenu/Buttons/DebugMenuButton
@onready var game = $Game
@onready var message_box = $UI/MessageBox
@onready var debug_menu = $UI/DebugMenu

#endregion Child Nodes

#region Game Data

# Stores whether or not the current game is two-player.
var two_player_game: bool = false

# Helps `Main` keep track of what event it is currently anticipating following
# the closing of the message box.
var awaiting: int = 0
enum { GAME = 1, SHOW_MENU = 2 }

#endregion Game Data

# Run on initialization
func _ready() -> void:
	# Output the version number.
	var game_name: String = tr("REDOT_PONG")
	var game_version: String = Global.get_semantic_version()
	print(game_name + " " + game_version)
	# Output an additional half-warning if this is a dev build.
	if Global.IS_DEV_BUILD:
		print(tr("DEV_BUILD_MESSAGE"))
	debug_menu_button.connect("pressed", debug_menu.popup_centered)

#region Game Logic

# Listening for input
func _input(event) -> void:
	# We're only listening for input if we are `awaiting` closing the message
	# box.
	if awaiting:
		if event.is_action_released("start"):
			# Hide the message box.
			message_box.hide()
			# Decide what to do next based on what we were waiting on.
			match awaiting:
				GAME:
					game.unpause()
				SHOW_MENU:
					main_menu.show()
			awaiting = 0


# A game over has occurred and it is time to declare a winner.
func _on_game_over(victor: int) -> void:
	# Hide the "resume" button.  We don't need it anymore.
	resume_button.hide()
	# Show a message to the player to celebrate and/or rub it in.
	if two_player_game:
		# For the "Player %d Wins!" message, we need to localize the message
		# explicitly first so we can insert the number into the message.
		var string: String = tr("MESSAGE_PLAYER_WON")
		message_box.set_text(string.replace("{num}", "%d" % victor))
	elif victor == 1:
		message_box.set_text("MESSAGE_YOU_WIN")
	else:
		message_box.set_text("MESSAGE_GAME_OVER")
	# Pop up the message box and await instructions to close it.
	message_box.show()
	awaiting = SHOW_MENU

#endregion Game Logic

#region Menu Buttons

# The "Start Game" button has been pressed, and it is time to start a new game.
func _on_main_menu_requested_new_game(two_players: bool) -> void:
	two_player_game = two_players
	# Instruct `game` to set up for a new game.
	await game.new_game(two_players)
	# Unpause the game.
	_on_main_menu_requested_unpause()
	# Unhide the "Resume" button on the main menu, so the player can resume
	# the game after pausing it.
	resume_button.show()


# The player has requested to unpause the game.
func _on_main_menu_requested_unpause() -> void:
	# Hide the main menu first.
	main_menu.hide()
	# Put up a message telling the player to get ready.
	message_box.set_text("MESSAGE_GET_READY")
	message_box.show()
	awaiting = GAME


# Alas, the player has pressed the "Quit Game" button :-(
func _on_main_menu_requested_quit_game() -> void:
	get_tree().quit()

#endregion Menu Buttons

#region Settings

# Handles the changes that have occurred as a result of the player saving
# their settings.  The specific behavior will be different depending on which
# window the settings were saved `from`.
func _handle_settings_changes(from: Node, num_changes: int) -> void:
	# It's possible that `num_changes` will be zero despite there being cached
	# changes.
	if num_changes > 0:
		# Grab the keys for the changed settings.
		var keys: Array = from.changed.keys()
		assert(keys.size() == num_changes)

		var value: Variant
		var player_1 = game.get_node("Player1Paddle")
		var player_2 = game.get_node("Player2Paddle")
		var ball = game.get_node("Ball")
		var report_set = func(s: String, v: Variant) -> void:
			print(s + " set to " + str(v))
		var report_on_off = func(s: String, b: bool) -> void:
			print(s + " " + ("ON" if b else "OFF"))
		var report_yn = func(s: String, b: bool) -> void:
			print(s + "? " + ("YES" if b else "NO"))
		for key in keys:
			# For every `key` in the dictionary, grab the value from that key
			# and decide what to do with it.
			value = from.changed[key]
			match key:
#region Match of Doom
				Global.Setting.FULL_REDOT_VERSION:
					Global.report_full_redot_version = value
					report_yn.call("Report full Redot Engine version", value)
					main_menu.update_version_number()
				Global.Setting.COLOR_CHANGING_BALL:
					Global.color_changing_ball = value
					report_on_off.call("Color-changing ball", value)
#region Debug Settings
				Global.Setting.DEBUG_WINNING_SCORE:
					game.winning_score = value
					report_set.call("Max points", value)
				Global.Setting.DEBUG_PADDLE_1_HEIGHT:
					player_1.extent_y = value / 2
					report_set.call("Player 1 height", value)
				Global.Setting.DEBUG_PADDLE_1_WIDTH:
					player_1.extent_x = value / 2
					report_set.call("Player 1 width", value)
				Global.Setting.DEBUG_PADDLE_2_HEIGHT:
					player_2.extent_y = value / 2
					report_set.call("Player 2 height", value)
				Global.Setting.DEBUG_PADDLE_2_WIDTH:
					player_2.extent_x = value / 2
					report_set.call("Player 2 width", value)
				Global.Setting.DEBUG_BALL_RADIUS:
					ball.radius = value
					report_set.call("Ball radius", value)
				Global.Setting.DEBUG_SCORING_PLAYER_1:
					game.player_1_scoring = value
					report_on_off.call("Player 1 scoring", value)
				Global.Setting.DEBUG_SCORING_PLAYER_2:
					game.player_2_scoring = value
					report_on_off.call("Player 2 scoring", value)
				Global.Setting.DEBUG_COLLISION_PLAYER_1:
					game.player_1_collision = value
					report_on_off.call("Player 1 collision", value)
				Global.Setting.DEBUG_COLLISION_PLAYER_2:
					game.player_2_collision = value
					report_on_off.call("Player 2 collision", value)
				Global.Setting.DEBUG_BASE_PADDLE_SPEED:
					game.base_paddle_speed = value
					report_set.call("Base paddle speed", value)
				Global.Setting.DEBUG_BASE_BALL_SPEED:
					game.base_ball_speed = value
					report_set.call("Base ball speed", value)
				Global.Setting.DEBUG_BALL_SPEED_MODIFIER:
					game.starting_ball_speed_mod = value
					report_set.call("Starting ball speed multiplier", value)
				Global.Setting.DEBUG_BALL_SPEED_MOD_INCREASE:
					game.ball_speed_increase = value
					report_set.call("Ball speed multiplier increase", value)
				Global.Setting.DEBUG_BALL_MAX_BOUNCE_ANGLE:
					game.max_bounce_angle = value
					report_set.call("Max bounce angle", value)
				Global.Setting.DEBUG_AI_MIN_SPEED_MOD:
					game.ai_min_speed = value
					report_set.call("AI minimum speed multiplier", value)
				Global.Setting.DEBUG_AI_MAX_SPEED_MOD:
					game.ai_max_speed = value
					report_set.call("AI maximum speed multiplier", value)
				Global.Setting.DEBUG_AI_FRUSTRATION:
					game.ai_frustration = value
					report_on_off.call("AI frustration", value)
				Global.Setting.DEBUG_AI_MIN_FRUSTRATION:
					game.min_frustration = value
					report_set.call("Min AI frustration", value)
				Global.Setting.DEBUG_AI_MAX_FRUSTRATION:
					game.max_frustration = value
					report_set.call("Max AI frustration", value)
				Global.Setting.DEBUG_AI_START_FRUSTRATION:
					game.starting_frustration = value
					report_set.call("Starting AI frustration", value)
				Global.Setting.DEBUG_AI_FRUSTRATION_INCREASE:
					game.frustration_increase = value
					report_set.call("AI frustration increase", value)
				Global.Setting.DEBUG_AI_FRUSTRATION_THRESHOLD:
					game.frustration_threshold = value
					report_set.call("AI frustration threshold", value)
				Global.Setting.DEBUG_AI_FRUSTRATION_MULTIPLIER:
					game.frustration_multiplier = value
					report_set.call("AI frustration multiplier", value)
				Global.Setting.DEBUG_AI_FRUSTRATION_ERROR:
					game.frustration_error = value
					report_set.call("AI frustration error", value)
#endregion Debug Settings
#endregion Match of Doom
				_:
					# If the key is invalid, throw a warning and ignore it.
					push_warning("Invalid key %d sent by settings menu!" % key)
	# At the end of the operation, clear the cached changes.
	from.clear_changes()


# The Debug Menu has requested that we save the player's debug settings.
func _on_debug_menu_requested_save(num_changes: int) -> void:
	_handle_settings_changes(debug_menu, num_changes)

#endregion Settings

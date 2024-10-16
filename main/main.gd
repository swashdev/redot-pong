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

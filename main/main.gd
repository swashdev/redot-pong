extends Node2D
# The main scene for Redot Pong.


#region Child Nodes

@onready var main_menu = $UI/MainMenu
@onready var resume_button = $UI/MainMenu/Buttons/ResumeButton
@onready var game = $Game
@onready var message_box = $MessagePopup

#endregion Child Nodes

#region Game Data

# Stores whether or not the current game is two-player.
var two_player_game: bool = false

# Helps `Main` keep track of what event it is currently anticipating following
# the closing of the message box.
var awaiting: int = 0
enum { GAME = 1, SHOW_MENU = 2 }

#endregion


# Initialization
func _ready() -> void:
	game.connect("pause_state_changed", _on_game_pause_state_changed)


# Listening for input
func _input(event) -> void:
	# We're only listening for input if we are `awaiting` closing the message
	# box.
	if awaiting:
		if event.is_action_released("ui_accept"):
			# Hide the message box.
			message_box.hide()
			# Decide what to do next based on what we were waiting on.
			match awaiting:
				GAME:
					game.unpause()
				SHOW_MENU:
					main_menu.show()
			awaiting = 0


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
	# Unpause the game.
	game.unpause()



# The game has paused or unpaused.
func _on_game_pause_state_changed(paused: bool) -> void:
	# If the game has paused, show the menu.
	if paused:
		main_menu.show()


# A game over has occurred and it is time to declare a winner.
func _on_game_over(victor: int) -> void:
	# Hide the "resume" button.  We don't need it anymore.
	resume_button.hide()
	# Show a message to the player to celebrate and/or rub it in.
	if two_player_game:
		message_box.set_text("Player %d\nWins!" % victor)
	elif victor == 1:
		message_box.set_text("You're Winner!")
	else:
		message_box.set_text("You're Loser!")
	# Pop up the message box and await instructions to close it.
	message_box.popup_centered()
	awaiting = SHOW_MENU


# Alas, the player has pressed the "Quit Game" button :-(
func _on_main_menu_requested_quit_game() -> void:
	get_tree().quit()

extends Node2D
# The main scene for Redot Pong.


#region Child Nodes

@onready var main_menu = $MainMenu
@onready var game = $Game

#endregion Child Nodes


# Initialization
func _ready() -> void:
	game.connect("pause_state_changed", _on_game_pause_state_changed)


# The "Start Game" button has been pressed, and it is time to start a new game.
func _on_main_menu_requested_new_game(two_players: bool) -> void:
	# Hide the main menu first.
	main_menu.hide()
	# Instruct `game` to set up for a new game.
	await game.new_game(two_players)
	# Unpause the game.
	game.unpause()


# The game has paused or unpaused.
func _on_game_pause_state_changed(paused: bool) -> void:
	# If the game has paused, show the menu.
	if paused:
		main_menu.show()


# Alas, the player has pressed the "Quit Game" button :-(
func _on_main_menu_requested_quit_game() -> void:
	get_tree().quit()

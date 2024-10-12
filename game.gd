extends Node2D
# A node controlling the playfield and game logic for Redot Pong.


#region Constants

const BASE_PADDLE_SPEED: float = 600.0

#endregion Constants

#region Child Nodes

@onready var playfield = $Playfield
@onready var ball = $Ball
@onready var player_1 = $Player1Paddle
@onready var player_2 = $Player2Paddle

#endregion Child Nodes

#region Mainloop

func _process(delta: float) -> void:
	var delta_pos: float
	var movement: float = delta * BASE_PADDLE_SPEED

	delta_pos = movement * Input.get_action_strength("ui_down")
	delta_pos -= movement * Input.get_action_strength("ui_up")
	move_paddle(player_1, delta_pos)


# Moves the given `paddle` a given `delta_pos`.
func move_paddle(paddle: RedotPongPaddle, delta_pos: float) -> void:
	paddle.position.y += delta_pos

	# Snap paddle to the playfield boundaries.
	if paddle.top < playfield.top:
		paddle.top = playfield.top
	if paddle.bottom > playfield.bottom:
		paddle.bottom = playfield.bottom

#endregion Mainloop

extends Node2D
# A node controlling the playfield and game logic for Redot Pong.


#region Constants

# The base speed for the ball & paddle
const BASE_BALL_SPEED: float = 300.0
const BASE_PADDLE_SPEED: float = 600.0

# The max angle (in radians) at which the ball will bounce.
const MAX_BOUNCE_ANGLE = 0.872664626

#endregion Constants

#region Child Nodes

@onready var playfield = $Playfield
@onready var ball = $Ball
@onready var player_1 = $Player1Paddle
@onready var player_2 = $Player2Paddle

#endregion Child Nodes

#region Local Variables

# Player score.
var player_1_score: int = 0
var player_2_score: int = 0

# The direction that the ball is moving, irrespective of speed.
var ball_direction: Vector2 = Vector2(-0.5, 0.5)

#endregion Local Variables

#region Mainloop

func _process(delta: float) -> void:
	var delta_pos: float
	var movement: float = delta * BASE_PADDLE_SPEED

	delta_pos = movement * Input.get_action_strength("ui_down")
	delta_pos -= movement * Input.get_action_strength("ui_up")
	move_paddle(player_1, delta_pos)

	# Move the ball.
	move_ball(delta)


# Moves the given `paddle` a given `delta_pos`.
func move_paddle(paddle: RedotPongPaddle, delta_pos: float) -> void:
	paddle.position.y += delta_pos

	# Snap paddle to the playfield boundaries.
	if paddle.top < playfield.top:
		paddle.top = playfield.top
	if paddle.bottom > playfield.bottom:
		paddle.bottom = playfield.bottom


# Moves the ball.
func move_ball(delta: float) -> void:
	var ball_speed: float = BASE_BALL_SPEED * delta
	var ball_velocity: Vector2 = ball_direction * ball_speed
	var contact_point: float
	var contact_point_normal: float
	var dir_rotate: float
	ball.position += ball_velocity

	# Reflect the ball off of walls.  If the ball contacts a paddle, its
	# direction is discarded and is altered depending on where on the paddle
	# it struck.
	# Note that collision detection is unidirectional for the paddles, so that
	# the ball can bounce back off of walls.
	if ball_direction.x < 0.0:
		if ball.left < player_1.right and ball.right > player_1.right:
			if ball.top < player_1.bottom and ball.bottom > player_1.top:
				contact_point = player_1.position.y - ball.position.y
				contact_point_normal = contact_point / player_1.extent_y
				dir_rotate = contact_point_normal * MAX_BOUNCE_ANGLE
				ball_direction = Vector2.RIGHT.rotated(-dir_rotate)
		elif ball.left < playfield.left:
			ball_direction.x *= -1
			player_2_score += 1
			print("Ball contacted left wall.  Player 2 has %d points." \
					% player_2_score)
	elif ball_direction.x > 0.0:
		if ball.right > player_2.left and ball.left < player_2.left:
			if ball.top < player_2.bottom and ball.bottom > player_2.top:
				contact_point = player_2.position.y - ball.position.y
				contact_point_normal = contact_point / player_2.extent_y
				dir_rotate = contact_point_normal * MAX_BOUNCE_ANGLE
				ball_direction = Vector2.LEFT.rotated(dir_rotate)
		elif ball.right > playfield.right:
			ball_direction.x *= -1
			player_1_score += 1
			print("Ball contacted right wall.  Player 1 has %d points." \
					% player_1_score)
	if ball_direction.y < 0.0:
		if ball.top < playfield.top:
			ball_direction.y *= -1
			print("Ball contacted top wall")
		#elif ball.left < player_1.right and ball.top > player_1.bottom:
			#if ball.top < player_1.bottom:
				#ball_direction.y *= -1
		#elif ball.right > player_2.left and ball.top > player_2.bottom:
			#if ball.top < player_2.bottom:
				#ball_direction.y *= -1
	elif ball_direction.y > 0.0:
		if ball.bottom > playfield.bottom:
			ball_direction.y *= -1
			print("Ball contacted bottom wall")
		#elif ball.left < player_1.right and ball.left > player_1.left:
			#if ball.bottom > player_1.top:
				#ball_direction.y *= -1
		#elif ball.right > player_2.left and ball.right < player_2.right:
			#if ball.bottom > player_2.top:
				#ball_direction.y *= -1


#endregion Mainloop

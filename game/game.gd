extends Node2D
# A node controlling the playfield and game logic for Redot Pong.


#region Signals

# Emitted when the game is finished setting up.
signal all_set

# Emitted when the game is over.
signal over(victor: int)

# Emitted when the game pauses/unpouses
signal pause_state_changed(paused: bool)

#region Signals

#region Constants

# The base speed for the ball & paddle
const BASE_BALL_SPEED: float = 300.0
const BASE_PADDLE_SPEED: float = 300.0

# The max angle (in radians) at which the ball will bounce.
const MAX_BOUNCE_ANGLE = 1.2217304764

#endregion Constants

#region Child Nodes

@onready var playfield = $Playfield
@onready var ball = $Ball
@onready var player_1 = $Player1Paddle
@onready var player_2 = $Player2Paddle
@onready var player_1_scoreboard = $Player1Score
@onready var player_2_scoreboard = $Player2Score

#endregion Child Nodes

#region Local Variables

# Player score.
var player_1_score: int = 0
var player_2_score: int = 0

# TODO: Implement multiplayer :-)
var two_players: bool = false

#region Ball Movement

# The direction that the ball is moving, irrespective of speed.
var ball_direction: Vector2 = Vector2.RIGHT

# Used to determine if the ball has bounced to the left or right this frame.
enum BallBounced { NO, LEFT, RIGHT }

# A multiplier which is applied to the ball's speed as the player scores.
var ball_speed_mod: float = 1.5
var ball_speed_increase: float = 0.01

#endregion Ball Movement

#region AI Variables

# The position on the paddle that player 2 wants to hit the ball with.
var target_contact_point: float = randf_range(-10.0, 10.0)

# A metric of how sluggish the AI is this turn.  Lower numbers slow the AI down.
var ai_speed_mod: float = 1.0

# How frustrated the AI has become as a result of the player doing well.
var frustration: int = 0

#endregion AI Variables

#endregion Local Variables

#region Initialization

# Initial setup
func _ready():
	pause()

#endregion Initialization

#region Mainloop

func _process(delta: float) -> void:
	var delta_pos: float
	var movement: float = delta * BASE_PADDLE_SPEED

	# Pause the game if the player requests it.
	if Input.is_action_just_pressed("ui_cancel"):
		pause()
	else:
		delta_pos = movement * Input.get_action_strength("ui_down")
		delta_pos -= movement * Input.get_action_strength("ui_up")
		move_paddle(player_1, delta_pos)

		# Do AI for the player 2 paddle.
		if two_players:
			push_error("2-player mode hasn't been implemented yet :-(")
		else:
			var target_contact_y: float = target_contact_point + player_2.position.y
			#var distance: float = ball.position.y - target_contact_y
			if ball_direction.x > 0.0:
				delta_pos = ball.position.y - target_contact_y
				delta_pos = clampf(delta_pos, -1.0, 1.0) * movement
				move_paddle(player_2, delta_pos * ai_speed_mod)

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
	var ball_speed: float = BASE_BALL_SPEED * ball_speed_mod * delta
	var ball_velocity: Vector2 = ball_direction * ball_speed
	var contact_point: float
	var contact_point_normal: float
	var dir_rotate: float
	var ball_bounced: int = BallBounced.NO

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
				ball_bounced = BallBounced.RIGHT
		elif ball.left < playfield.left:
			ball_direction.x *= -1
			score_player(2)
			ball_bounced = BallBounced.RIGHT
	elif ball_direction.x > 0.0:
		if ball.right > player_2.left and ball.left < player_2.left:
			if ball.top < player_2.bottom and ball.bottom > player_2.top:
				contact_point = player_2.position.y - ball.position.y
				contact_point_normal = contact_point / player_2.extent_y
				dir_rotate = contact_point_normal * MAX_BOUNCE_ANGLE
				ball_direction = Vector2.LEFT.rotated(dir_rotate)
				ball_bounced = BallBounced.LEFT
		elif ball.right > playfield.right:
			ball_direction.x *= -1
			score_player(1)
			ball_bounced = BallBounced.LEFT
	if ball_direction.y < 0.0:
		if ball.top < playfield.top:
			ball_direction.y *= -1
		#elif ball.left < player_1.right and ball.top > player_1.bottom:
			#if ball.top < player_1.bottom:
				#ball_direction.y *= -1
		#elif ball.right > player_2.left and ball.top > player_2.bottom:
			#if ball.top < player_2.bottom:
				#ball_direction.y *= -1
	elif ball_direction.y > 0.0:
		if ball.bottom > playfield.bottom:
			ball_direction.y *= -1
		#elif ball.left < player_1.right and ball.left > player_1.left:
			#if ball.bottom > player_1.top:
				#ball_direction.y *= -1
		#elif ball.right > player_2.left and ball.right < player_2.right:
			#if ball.bottom > player_2.top:
				#ball_direction.y *= -1

	# If the ball bounced, its speed will increase.
	if ball_bounced:
		ball_speed_mod += ball_speed_increase
		# If the ball bounced to the left, the AI will choose a new target
		# contact point and speed modifier.
		if not two_players:
			if ball_bounced == BallBounced.LEFT:
				var min_ai_speed = clampf(0.1 * frustration, 0.1, 1.0)
				ai_speed_mod = randf_range(min_ai_speed, 1.0)
				target_contact_point = \
						randf_range(-(player_2.extent_y), player_2.extent_y)
				# If the AI is getting frustrated, it will be more likely to go
				# for edge shots to try and throw the player off.  This may
				# result in the AI doing something foolish.
				if frustration >= 5:
					if target_contact_point < 0.0:
						target_contact_point += \
								randf_range(-(player_2.extent_y + ball.radius), \
								target_contact_point)
					else:
						target_contact_point += \
								randf_range(target_contact_point, \
								player_2.extent_y + ball.radius)


# Incremeents a given player's score.
func score_player(which_player: int) -> void:
	assert(which_player < 3 && which_player > 0)
	if which_player == 1:
		player_1_score += 1
		if not two_players:
			frustration += 1
	else:
		player_2_score += 1
		if not two_players:
			if frustration > -5:
				frustration -= 1
	write_scores()


# Writes the players' scores on the playfield.
func write_scores() -> void:
	player_1_scoreboard.set_text("%d" % player_1_score)
	player_2_scoreboard.set_text("%d" % player_2_score)


#endregion Mainloop

#region Setup

# Pauses the `Game` process, usually to pop up the main menu.
func pause() -> void:
	set_process(false)
	modulate.v = 0.5
	emit_signal("pause_state_changed", true)


# Unpauses.
func unpause() -> void:
	emit_signal("pause_state_changed", false)
	modulate.v = 1.0
	set_process(true)


func new_game(with_two_players: bool = false) -> void:
	two_players = with_two_players

	player_1.position = Vector2(166, 324)
	player_2.position = Vector2(986, 324)
	player_1_score = 0
	player_2_score = 0
	frustration = 0

	# The ball starts in the middle.  In a two-player game it will randomly
	# select a player to serve to.  In a single-player game it will always
	# serve to the player.
	ball.position = Vector2(576, 324)
	if not two_players:
		ball_direction = Vector2.LEFT
	else:
		ball_direction = Vector2.LEFT if randi() & 1 else Vector2.RIGHT

	write_scores()
	emit_signal("all_set")

#endregion Setup

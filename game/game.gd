extends Node2D
# A node controlling the playfield and game logic for Redot Pong.


#region Signals

# Emitted when the game is finished setting up.
signal all_set

# Emitted when the game is over.
signal over(victor: int)

# The game has requested a pause which the main menu needs to be awake for.
signal requested_menu

#region Signals

#region Child Nodes

@onready var playfield = $Playfield
@onready var ball = $Ball
@onready var player_1 = $Player1Paddle
@onready var player_2 = $Player2Paddle
@onready var player_1_scoreboard = $Player1Score
@onready var player_2_scoreboard = $Player2Score

#endregion Child Nodes

#region Local Variables

# The base speed for the paddles.
var base_paddle_speed: float = 300.0

# Player score.
var player_1_score: int = 0
var player_2_score: int = 0

# TODO: Implement multiplayer :-)
var two_players: bool = false

# Properties used for debugging purposes.
var player_1_scoring: bool = true
var player_2_scoring: bool = true
var player_1_collision: bool = true
var player_2_collision: bool = true

#region Ball Movement

# The ball's base speed and starting speed mod.
var base_ball_speed: float = 300.0
var starting_ball_speed_mod: float = 1.49

# The max angle (in radians) at which the ball will bounce.
var max_bounce_angle: float = 1.2217304764

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

# Debug options.
var ai_min_speed: float = 0.1
var ai_max_speed: float = 1.0
# Set to `false` to turn off AI frustration.
var ai_frustration: bool = true
var min_frustration: int = -5
var max_frustration: int = 100
var starting_frustration: int = 0
var frustration_increase: int = 1
var frustration_threshold: int = 5
var frustration_multiplier: float = 0.1
var frustration_error: float = 10.0

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
	var movement: float = delta * base_paddle_speed

	# Pause the game if the player requests it.
	if Input.is_action_just_pressed("pause"):
		pause(true)
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
	var ball_speed: float = base_ball_speed * ball_speed_mod * delta
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
		if player_1_collision and \
		ball.left < player_1.right and ball.right > player_1.right:
			if ball.top < player_1.bottom and ball.bottom > player_1.top:
				contact_point = player_1.position.y - ball.position.y
				contact_point_normal = contact_point / player_1.extent_y
				dir_rotate = contact_point_normal * max_bounce_angle
				ball_direction = Vector2.RIGHT.rotated(-dir_rotate)
				ball_bounced = BallBounced.RIGHT
				if Global.color_changing_ball:
					ball.set_color(player_1.get_color())
		elif ball.left < playfield.left:
			ball_direction.x *= -1
			ball_bounced = BallBounced.RIGHT
			if player_2_scoring:
				score_player(2)
				if Global.color_changing_ball:
					ball.set_color(playfield.get_border_color())
	elif ball_direction.x > 0.0:
		if player_2_collision and \
		ball.right > player_2.left and ball.left < player_2.left:
			if ball.top < player_2.bottom and ball.bottom > player_2.top:
				contact_point = player_2.position.y - ball.position.y
				contact_point_normal = contact_point / player_2.extent_y
				dir_rotate = contact_point_normal * max_bounce_angle
				ball_direction = Vector2.LEFT.rotated(dir_rotate)
				ball_bounced = BallBounced.LEFT
				if Global.color_changing_ball:
					ball.set_color(player_2.get_color())
		elif ball.right > playfield.right:
			ball_direction.x *= -1
			ball_bounced = BallBounced.LEFT
			if player_1_scoring:
				score_player(1)
				if Global.color_changing_ball:
					ball.set_color(playfield.get_border_color())
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
				var new_ai_min = frustration_multiplier * frustration
				new_ai_min = clampf(new_ai_min, ai_min_speed, ai_max_speed)
				ai_speed_mod = randf_range(new_ai_min, ai_max_speed)
				target_contact_point = \
						randf_range(-(player_2.extent_y), player_2.extent_y)
				# If the AI is getting frustrated, it will be more likely to go
				# for edge shots to try and throw the player off.  This may
				# result in the AI doing something foolish.
				if ai_frustration and frustration >= frustration_threshold:
					if target_contact_point < 0.0:
						target_contact_point += \
								randf_range(-(player_2.extent_y + \
								frustration_error), target_contact_point)
					else:
						target_contact_point += \
								randf_range(target_contact_point, \
								player_2.extent_y + frustration_error)


# Incremeents a given player's score.
func score_player(which_player: int) -> void:
	assert(which_player < 3 && which_player > 0)
	var winner: int = 0
	if which_player == 1:
		player_1_score += 1
		if player_1_score >= 10:
			winner = 1
		if (not two_players) and ai_frustration:
			frustration += frustration_increase
	else:
		player_2_score += 1
		if player_2_score >= 10:
			winner = 2
		if (not two_players) and ai_frustration:
			if frustration > min_frustration:
				frustration -= frustration_increase
	write_scores()
	# If a player has scored more than 10 points, declare a winner.
	if winner:
		ball.hide()
		emit_signal("over", winner)
		pause()


# Writes the players' scores on the playfield.
func write_scores() -> void:
	player_1_scoreboard.set_text("%d" % player_1_score)
	player_2_scoreboard.set_text("%d" % player_2_score)


#endregion Mainloop

#region Setup

# Pauses the `Game` process, usually to pop up the main menu.
func pause(raise_menu: bool = false) -> void:
	set_process(false)
	modulate.v = 0.5
	if raise_menu:
		emit_signal("requested_menu")


# Unpauses.
func unpause() -> void:
	modulate.v = 1.0
	set_process(true)


func new_game(with_two_players: bool = false) -> void:
	two_players = with_two_players

	player_1.position = Vector2(166, 324)
	player_2.position = Vector2(986, 324)
	player_1_score = 0
	player_2_score = 0
	frustration = starting_frustration

	# The ball starts in the middle.  In a two-player game it will randomly
	# select a player to serve to.  In a single-player game it will always
	# serve to the player.
	ball.position = Vector2(576, 324)
	ball.set_color(Color.WHITE)
	ball.show()
	if not two_players:
		ball_direction = Vector2.LEFT
	else:
		ball_direction = Vector2.LEFT if randi() & 1 else Vector2.RIGHT

	write_scores()
	emit_signal("all_set")

#endregion Setup

@tool
class_name RedotPongPaddle
extends RedotPongRect
# The base script for paddles in Redot Pong.


#region Variables

# The paddle's color.
@export_color_no_alpha var _color: Color = Color.WHITE:
	get = get_color, set = set_color

# A rectangle used when drawing the paddle.
@onready var _rect: Rect2:
	get = get_rect

#endregion Variables

#region System Functions

# Initialization
func _ready() -> void:
	# Initialize the paddle's rectangle.
	_recalc_rect()


# Draws the paddle at its current position.
func _draw() -> void:
	draw_rect(_rect, _color, true)
	#if OS.is_debug_build():
	#	draw_circle(Vector2(0, 0), 1.0, Color.RED, true)

#endregion System Functions

#region Setters & Getters

func set_half_width(value: float) -> void:
	super(value)
	_recalc_rect()

func set_half_height(value: float) -> void:
	super(value)
	_recalc_rect()


# Recalculate `_rect` based on the given `extent_y` and `extent_x` values.
func _recalc_rect() -> void:
	# Note that the position is negative because it's declared relative to the
	# paddle's center.
	_rect = Rect2(-extent_x, -extent_y, \
			extent_x * 2, extent_y * 2)
	queue_redraw()

func get_rect() -> Rect2:
	return _rect


func get_color() -> Color:
	return _color

func set_color(value: Color) -> void:
	_color.r = value.r
	_color.g = value.g
	_color.b = value.b
	queue_redraw()

#endregion Setters & Getters

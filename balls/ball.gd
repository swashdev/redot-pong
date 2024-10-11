@tool
class_name RedotPongBall
extends Node2D
# A ball to bounce back and forth.


#region Variables

# The radius of the ball.
@export_range(1.0, 20.0, 1.0, "or_greater") var radius: float = 10.0:
	get = get_radius, set = set_radius

# The ball's color.
@export_color_no_alpha var _color: Color = Color.WHITE:
	get = get_color, set = set_color


#region Properties of the Circle

var diameter: float:
	get:
		return radius * 2
	set(value):
		radius = value / 2

# `top`, `bottom`, `left`, and `right` are derived from an approximation of
# the ball as a non-rotating square, for collision detection purposes.

var top: float:
	get:
		return position.y - radius
	set(value):
		position.y = value + radius

var bottom: float:
	get:
		return position.y + radius
	set(value):
		position.y = value - radius

var left: float:
	get:
		return position.x - radius
	set(value):
		position.x = value + radius

var right: float:
	get:
		return position.x + radius
	set(value):
		position.x = value - radius

#endregion Properties of the Circle

#endregion Variables

#region System Functions

# Draws the ball
func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, _color, true)

#endregion System Functions

#region Setters & Getters

func get_radius() -> float:
	return radius

func set_radius(value: float) -> void:
	radius = absf(value)
	queue_redraw()


func get_color() -> Color:
	return _color

func set_color(value: Color) -> void:
	_color.r = value.r
	_color.g = value.g
	_color.b = value.b
	queue_redraw()

#endregion Setters & Getters

class_name RedotPongRect
extends Node2D
# A base class for rectangular objects in Redot Pong.


# The dimensions of the rectangle, defined as how far it "extends" out from the
# center.
@export_group("Size")
@export_range(0, 100.0, 1.0, "or_greater") var extent_x: float:
	get = get_half_width, set = set_half_width
@export_range(0, 100.0, 1.0, "or_greater") var extent_y: float:
	get = get_half_height, set = set_half_height

#region Properties of the Rectangle

# The extents of the paddle's rectangle.
var top: float:
	get:
		return position.y - extent_y
	set(value):
		position.y = value + extent_y

var bottom: float:
	get:
		return position.y + extent_y
	set(value):
		position.y = value - extent_y

var left: float:
	get:
		return position.x - extent_x
	set(value):
		position.x = value + extent_x

var right: float:
	get:
		return position.x + extent_x
	set(value):
		position.x = value - extent_x

var height: float:
	get:
		return extent_y * 2
	set(value):
		extent_y = value / 2

var width: float:
	get:
		return extent_x * 2
	set(value):
		extent_x = value / 2

#endregion Properties of the Rectangle

#region Setters & Getters

func get_half_width() -> float:
	return extent_x

func set_half_width(value: float) -> void:
	extent_x = value


func get_half_height() -> float:
	return extent_y

func set_half_height(value) -> void:
	extent_y = value

#endregion Setters & Getters

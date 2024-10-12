@tool
class_name RedotPongPlayfield
extends RedotPongRect
# Defines the boundaries of the play field and how it is drawn on-screen.


#region Variables

@export_group("Border")
@export_range(0.0, 10.0, 1.0, "or_greater") var border_width: float = 10.0:
	get = get_border_width, set = set_border_width
@export var border_color: Color = Color.WHITE:
	get = get_border_color, set = set_border_color

#endregion Variables

# Draw the playfield.
func _draw() -> void:
	draw_rect(Rect2(-extent_x - (border_width / 2), \
			-extent_y - (border_width / 2), \
			width + border_width, height + border_width), \
			border_color, false, border_width)
	draw_line(Vector2(0.0, -extent_y), Vector2(0.0, extent_y), \
			border_color, 2.0)


#region Setters & Getters

func set_half_width(value: float) -> void:
	super(value)
	queue_redraw()

func set_half_height(value: float) -> void:
	super(value)
	queue_redraw()


func get_border_width() -> float:
	return border_width

func set_border_width(value: float) -> void:
	border_width = absf(value)
	queue_redraw()


func get_border_color() -> Color:
	return border_color

func set_border_color(value: Color) -> void:
	border_color.r = value.r
	border_color.g = value.g
	border_color.b = value.b
	queue_redraw()

#endregion Setters & Getters

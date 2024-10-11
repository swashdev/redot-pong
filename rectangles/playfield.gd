@tool
extends RedotPongRect
# Defines the boundaries of the play field and how it is drawn on-screen.


#region Variables

@export_group("Border")
@export_range(0.0, 10.0, 1.0, "or_greater") var border_width: float = 10.0
@export var border_color: Color = Color.WHITE

#endregion Variables

# Draw the playfield.
func _draw() -> void:
	draw_rect(Rect2(-extent_x - (border_width / 2), \
			-extent_y - (border_width / 2), \
			width + border_width, height + border_width), \
			border_color, false, border_width)


#region Setters & Getters

func set_half_width(value: float) -> void:
	super(value)
	queue_redraw()

func set_half_height(value: float) -> void:
	super(value)
	queue_redraw()

#endregion Setters & Getters

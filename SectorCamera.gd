extends Camera2D

export(float) var min_zoom = 0.5
export(float) var max_zoom = 2.0
export(float) var zoom_speed = 0.1

var is_dragging = false
var drag_start_position = Vector2.ZERO
var camera_start_position = Vector2.ZERO

func _ready():
	current = true # Ensures camera is active on start

func _unhandled_input(event):
	# DRAG TO PAN (Middle or Left Click)
	if event is InputEventMouseButton:
		if event.button_index in [BUTTON_LEFT, BUTTON_MIDDLE]:
			if event.pressed:
				is_dragging = true
				drag_start_position = event.global_position
				camera_start_position = global_position
			else:
				is_dragging = false
				
		# MOUSE WHEEL ZOOM
		elif event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				_zoom_camera(-zoom_speed)
			elif event.button_index == BUTTON_WHEEL_DOWN:
				_zoom_camera(zoom_speed)

	elif event is InputEventMouseMotion and is_dragging:
		var delta = drag_start_position - event.global_position
		global_position = camera_start_position + (delta * zoom.x)

func _zoom_camera(amount: float):
	var new_zoom = clamp(zoom.x + amount, min_zoom, max_zoom)
	zoom = Vector2(new_zoom, new_zoom)

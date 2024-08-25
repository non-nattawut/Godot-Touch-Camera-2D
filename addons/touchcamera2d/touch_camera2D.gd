@tool
extends Camera2D
class_name TouchCamera2D

@export var zoom_speed: float = 0.1
@export var pan_speed: float = 1.0
@export var rotation_speed: float = 1.0

@export var can_pan: bool
@export var can_zoom: bool
@export var can_rotate: bool

var touch_points: Dictionary = {}
var start_distance
var start_zoom
var start_angle
var current_angle

func _input(event):
	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventScreenDrag:
		handle_drag(event)
		pass
		
func handle_touch(event: InputEventScreenTouch):
	if event.pressed:
		touch_points[event.index] = event.position
	else:
		touch_points.erase(event.index)
	
	if touch_points.size() == 2:
		var touch_point_positions = touch_points.values()
		start_distance = touch_point_positions[0].distance_to(touch_point_positions[1])
		start_angle = get_angle(touch_point_positions[0], touch_point_positions[1])
		start_zoom = zoom
	elif touch_points.size() < 2:
		start_distance = 0
		
func handle_drag(event: InputEventScreenDrag):
	touch_points[event.index] = event.position
	
	if touch_points.size() == 1:
		if can_pan:
			offset -= event.relative.rotated(rotation) * pan_speed
			
	elif touch_points.size() == 2:
		var touch_point_positions = touch_points.values()
		var current_dist = touch_point_positions[0].distance_to(touch_point_positions[1])
		var current_angle = get_angle(touch_point_positions[0], touch_point_positions[1])
		var zoom_factor = start_distance / current_dist
		
		if can_zoom:
			zoom = start_zoom / zoom_factor
		if can_rotate:
			rotation -= (current_angle - start_angle) * rotation_speed
			start_angle = current_angle
		limit_zoom(zoom)

func limit_zoom(new_zoom):
	if new_zoom.x < 0.1:
		zoom.x = 0.1
	if new_zoom.y < 0.1:
		zoom.y = 0.1
	if new_zoom.x > 10:
		zoom.x = 10
	if new_zoom.y > 10:
		zoom.y = 10
	

func get_angle(p1, p2):
	var delta = p2 - p1
	return fmod((atan2(delta.y, delta.x) + PI), (2 * PI))

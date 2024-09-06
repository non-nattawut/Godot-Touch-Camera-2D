@tool
extends Camera2D
class_name TouchCamera2D


@export var can_pan: bool
@export var can_zoom: bool
@export var can_rotate: bool
@export var rotation_speed: float = 1.0

@export_group("Zoom")
@export var zoom_speed: float = 0.1
## To rise zoom in increase number
@export var zoom_in_limit: Vector2 = Vector2(10, 10)
## To rise zoom out decrease number
@export var zoom_out_limit: Vector2 = Vector2(1, 1)

@export_group("Pan")
@export var pan_speed: float = 1.0
## Limit by border not by Camera2D center
@export var is_limit_pan: bool = false
@export var pan_limit_left: int = -10000000
@export var pan_limit_top: int = -10000000
@export var pan_limit_right: int = 10000000
@export var pan_limit_bottom: int = 10000000

var touch_points: Dictionary = {}
var start_distance
var start_zoom
var start_angle
var current_angle


func _input(event):
	if not ScrollManager.is_scrolling:
		if event is InputEventScreenTouch:
			handle_touch(event)
		elif event is InputEventScreenDrag:
			handle_drag(event)
		
func handle_touch(event: InputEventScreenTouch):
	if event.pressed:
		touch_points[event.index] = event.position
	else:
		touch_points.erase(event.index)
	
	if touch_points.size() == 2: # Zoom or Rotate handle
		var touch_point_positions = touch_points.values()
		start_distance = touch_point_positions[0].distance_to(touch_point_positions[1])
		start_angle = get_angle(touch_point_positions[0], touch_point_positions[1])
		start_zoom = zoom
	elif touch_points.size() < 2:
		start_distance = 0
		
func handle_drag(event: InputEventScreenDrag):
	touch_points[event.index] = event.position
	
	if touch_points.size() == 1 and can_pan:
		offset -= event.relative.rotated(rotation) * pan_speed
		if is_limit_pan:
			limit_pan(get_camera_border())
			
	elif touch_points.size() == 2: # Zoom or Rotate handle
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
	if new_zoom.x > zoom_in_limit.x:
		zoom.x = zoom_in_limit.x
	if new_zoom.y > zoom_in_limit.y:
		zoom.y = zoom_in_limit.y
	
	if new_zoom.x < zoom_out_limit.x:
		zoom.x = zoom_out_limit.x
	if new_zoom.y < zoom_out_limit.y:
		zoom.y = zoom_out_limit.y
		
func limit_pan(border : Dictionary):
	if border["left"] < pan_limit_left:
		offset.x = pan_limit_left + border["half_viewport_with_zoom_factor"].x
	elif border["right"] > pan_limit_right:
		offset.x = pan_limit_right - border["half_viewport_with_zoom_factor"].x
		
	if border["top"] < pan_limit_top:
		offset.y = pan_limit_top + border["half_viewport_with_zoom_factor"].y
	elif border["bottom"] > pan_limit_bottom:
		offset.y = pan_limit_bottom - border["half_viewport_with_zoom_factor"].y


func get_angle(p1, p2):
	var delta = p2 - p1
	return fmod((atan2(delta.y, delta.x) + PI), (2 * PI))
	

func get_camera_border() -> Dictionary:
	var half_viewport_with_zoom_factor = get_viewport().size / zoom.x / 2
	
	#offset = screen center
	var border = {
		"left" : offset.x - half_viewport_with_zoom_factor.x,
		"right" : offset.x + half_viewport_with_zoom_factor.x,
		"top" : offset.y - half_viewport_with_zoom_factor.y,
		"bottom" : offset.y + half_viewport_with_zoom_factor.y,
		"half_viewport_with_zoom_factor" : half_viewport_with_zoom_factor
	}
	
	return border

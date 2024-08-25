@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("TouchCamera2D", "Camera2D", preload("touch_camera2D.gd"), preload("icon.svg"))


func _exit_tree():
	remove_custom_type("TouchCamera2D")

extends Node

func _input(event):
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
		_open_pause_menu()

func _open_pause_menu():
	if get_tree().current_scene.has_node("PauseMenu"):
		return
	var pause_menu = preload("res://Scenes/pause_menu.tscn").instantiate()
	pause_menu.name = "PauseMenu"
	get_tree().current_scene.add_child(pause_menu)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	await get_tree().process_frame
	get_tree().paused = true

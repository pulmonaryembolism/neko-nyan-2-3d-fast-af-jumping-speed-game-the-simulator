extends Node

func _input(event):
	if event.is_action_pressed("ui_cancel") and event.is_pressed():
		var root = get_tree().get_current_scene()
		if root == null:
			return
		
		var pause_menu = root.get_node_or_null("PauseMenu")
		if pause_menu and pause_menu.visible:
			pause_menu.hide()
			get_tree().paused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			_open_pause_menu()

func _open_pause_menu():
	var root = get_tree().get_current_scene()
	if root == null:
		return

	var pause_menu = root.get_node_or_null("PauseMenu")
	if pause_menu:
		pause_menu.show()
	else:
		pause_menu = preload("res://Scenes/pause_menu.tscn").instantiate()
		pause_menu.name = "PauseMenu"
		root.add_child(pause_menu)

	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

extends Control  # or whatever your pause menu root node is

@onready var resume_button = $MarginContainer/VBoxContainer/ResumeButton
@onready var options_button = $MarginContainer/VBoxContainer/OptionsButton
@onready var main_menu_button = $MarginContainer/VBoxContainer/MainMenuButton

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	options_button.pressed.connect(_on_optionsButton_pressed)
	resume_button.pressed.connect(_on_resume_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func _on_optionsButton_pressed():
	var options = preload("res://Scenes/Options.tscn").instantiate()
	options.name = "OptionsMenu"
	options.set_source(options.Source.PAUSE)
	get_tree().current_scene.add_child(options)
	self.hide()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_resume_button_pressed():
	queue_free()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _input(event):
	if not self.visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_resume_button_pressed()

func _on_quit_button_pressed():
	get_tree().quit()

func _on_quit_pressed():
	get_tree().quit()

func _on_main_menu_pressed():
	self.hide()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

extends Control

@onready var start_button = $MarginContainer/VBoxContainer/StartButton
@onready var options_button = $MarginContainer/VBoxContainer/OptionsButton
@onready var quit_button = $MarginContainer/VBoxContainer/Quit

func _ready():
	$MarginContainer/VBoxContainer/Time.text = Global.final_time
	start_button.pressed.connect(_on_StartButton_pressed)
	options_button.pressed.connect(_on_OptionsButton_pressed)
	quit_button.pressed.connect(_on_QuitButton_pressed)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_StartButton_pressed():
	get_tree().change_scene_to_file("res://Scenes/test.tscn")

func _on_OptionsButton_pressed():
	var options = preload("res://Scenes/Options.tscn").instantiate()
	options.set_source(options.Source.TITLE)
	get_tree().root.add_child(options)
	start_button.hide()
	options_button.hide()
	quit_button.hide()

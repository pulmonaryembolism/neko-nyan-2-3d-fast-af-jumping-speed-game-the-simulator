extends Control

@onready var save_button = $MarginContainer/VBoxContainer/SaveButton
@onready var replay_button = $MarginContainer/VBoxContainer/ReplayButton
@onready var quit_button = $MarginContainer/VBoxContainer/QuitButton

func _ready():
	$MarginContainer/VBoxContainer/Time.text = Global.final_time
	save_button.pressed.connect(_on_SaveButton_pressed)
	replay_button.pressed.connect(_on_ReplayButton_pressed)
	quit_button.pressed.connect(_on_QuitButton_pressed)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_SaveButton_pressed():
	get_tree().change_scene_to_file("res://Scenes/save_screen.tscn")

func _on_ReplayButton_pressed():
	get_tree().change_scene_to_file("res://Scenes/test.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()

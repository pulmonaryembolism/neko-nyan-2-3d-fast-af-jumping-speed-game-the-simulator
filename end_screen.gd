extends Control

@onready var replay_button = $MarginContainer/VBoxContainer/ReplayButton
@onready var quit_button = $MarginContainer/VBoxContainer/QuitButton

func _ready():
	$MarginContainer/VBoxContainer/Time.text = Global.final_time
	start_button.pressed.connect(_on_StartButton_pressed)
	quit_button.pressed.connect(_on_QuitButton_pressed)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_StartButton_pressed():
	get_tree().change_scene_to_file("res://Scenes/test.tscn")

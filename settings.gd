extends Control

enum Source { TITLE, GAME }
var source = Source.TITLE
@onready var back_button = get_node("MarginContainer/VBoxContainer/BackButton")

func _ready():
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)
	else:
		print("Error: BackButton node not found!")

func set_source(new_source):
	source = new_source

func _on_back_button_pressed():
	match source:
		Source.TITLE:
			queue_free()
			if get_tree().current_scene.has_node("TitleScreen"):
				get_tree().current_scene.get_node("TitleScreen").show()
			else:
				get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
		Source.GAME:
			queue_free()
			var pause_menu = get_tree().current_scene.get_node("PauseMenu")
			if pause_menu:
				pause_menu.show()

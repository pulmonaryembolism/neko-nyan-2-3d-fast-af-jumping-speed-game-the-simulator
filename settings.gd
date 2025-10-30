extends Control

enum Source { TITLE, GAME }
var source = Source.TITLE
@onready var back_button = get_node("MarginContainer/VBoxContainer/BackButton")
@onready var volume_slider = $MarginContainer/VBoxContainer/Volume



func _ready():
	back_button.pressed.connect(_on_back_button_pressed)
	volume_slider.value = AudioManager.master_slider_value
	volume_slider.connect("value_changed", _on_volume_changed)

func _on_volume_changed(value):
	AudioManager.master_slider_value = value
	var scaled_value = value * 0.3 #limits max volume
	AudioManager.set_master_volume(scaled_value)

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

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)

func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0,toggled_on)

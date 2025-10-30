extends Control

enum Source { TITLE, GAME, PAUSE}
var source = Source.TITLE
@onready var back_button = get_node("MarginContainer/VBoxContainer/BackButton")
@onready var volume_slider = $MarginContainer/VBoxContainer/Volume
@onready var mute_button = get_node_or_null("MarginContainer/VBoxContainer/Mute")


func _ready():
	back_button.pressed.connect(_on_back_button_pressed)
	volume_slider.value = AudioManager.master_slider_value
	volume_slider.connect("value_changed", _on_volume_changed)
	if mute_button:
		mute_button.toggled.connect(_on_mute_toggled)
		mute_button.button_pressed = AudioManager.is_muted

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
			self.hide()
			var pause_menu = get_tree().current_scene.get_node("PauseMenu")
			if pause_menu:
				pause_menu.show()
		Source.PAUSE:
			queue_free()
			var pause_menu = get_tree().current_scene.get_node("PauseMenu")
			if pause_menu:
				pause_menu.show()
			get_tree().paused = true

func _on_volume_value_changed(value: float):
	AudioServer.set_bus_volume_db(0, value)

func _on_mute_toggled(is_pressed: bool):
	AudioManager.is_muted = is_pressed
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), is_pressed)
	
func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed() and event.is_action("ui_cancel"):
		_on_back_button_pressed()
		return

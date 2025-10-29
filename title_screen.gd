extends Control

func _ready():
	$StartButton.pressed.connect(_on_StartButton_pressed)
	$OptionsButton.pressed.connect(_on_OptionsButton_pressed)
	$QuitButton.pressed.connect(_on_QuitButton_pressed)

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_StartButton_pressed():
	get_tree().change_scene_to_file("res://Scenes/test.tscn")

func _on_OptionsButton_pressed():
	var options = preload("res://Scenes/Options.tscn").instantiate()
	options.set_source(options.Source.TITLE)
	get_tree().root.add_child(options)
	$StartButton.hide()
	$OptionsButton.hide()
	$QuitButton.hide()

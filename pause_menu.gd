extends Control  # or whatever your pause menu root node is

@onready var options_button = $OptionsButton
@onready var resume_button = $ResumeButton

func _ready():
	options_button.pressed.connect(_on_optionsButton_pressed)
	resume_button.pressed.connect(_on_resume_button_pressed)
	$QuitButton.pressed.connect(_on_QuitButton_pressed)

func _on_optionsButton_pressed():
	var options = preload("res://Scenes/Options.tscn").instantiate()
	options.set_source(options.Source.GAME)
	get_tree().current_scene.add_child(options)
	self.hide()
	get_tree().paused = true


func _on_resume_button_pressed():
	queue_free()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_QuitButton_pressed():
	get_tree().quit()

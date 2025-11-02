extends TextureButton

func _ready():
	connect("mouse_entered", Callable(self, "_on_hover_entered"))
	connect("mouse_exited", Callable(self, "_on_hover_exited"))
	connect("pressed", Callable(self, "_on_texture_button_pressed"))

func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")

func _on_hover_entered():
	create_tween().tween_property(self, "scale", Vector2(1.015, 1.015), 0.1)

func _on_hover_exited():
	create_tween().tween_property(self, "scale", Vector2(1, 1), 0.1)

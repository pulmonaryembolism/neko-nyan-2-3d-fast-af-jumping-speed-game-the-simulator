extends Node3D

func _physics_process(delta):
	if Input.is_action_just_pressed("reset"):
		self.global_position = $spawn_point.global_position

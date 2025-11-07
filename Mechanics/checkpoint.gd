extends Area3D

@onready var level = get_tree().get_first_node_in_group("spawn_point")

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("CharacterBody3D"):
		level.set_active_checkpoint(self)
		print("setting active checkpoint...")

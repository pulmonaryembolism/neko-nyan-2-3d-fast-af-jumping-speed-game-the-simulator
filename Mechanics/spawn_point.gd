extends Node3D

var current_checkpoint:Node3D = null

func _physics_process(delta):
	if Input.is_action_just_pressed("reset"):
		var player = get_node_or_null("CharacterBody3D")
		if player == null:
			push_error("Player node not found!")
			return
		
		var respawn_pos = current_checkpoint.global_position if current_checkpoint else self.global_position
		player.global_position = respawn_pos
		Global.reset_timer = true
	
func set_active_checkpoint(checkpoint: Node3D) -> void:
	current_checkpoint = checkpoint

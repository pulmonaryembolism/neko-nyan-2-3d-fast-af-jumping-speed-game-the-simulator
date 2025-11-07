extends Node

var total_checkpoints: int = 0
var activated_count: int = 0
var activated_checkpoints: Array = []

func register_checkpoint():
	total_checkpoints += 1
	
func on_checkpoint_activated(checkpoint_id: int):
	if checkpoint_id not in activated_checkpoints:
		activated_checkpoints.append(checkpoint_id)
		activated_count += 1
		print("Checkpoint", checkpoint_id, "activated. Total:", activated_count)

func _process(_delta: float) -> void:
	if activated_count == total_checkpoints:
		Global.stop_timer = true

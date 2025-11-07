extends Area3D

@export var checkpoint_id: int = 0
var activated: bool = false

signal checkpoint_activated(checkpoint_id: int)

func _ready():
		CheckpointManager.register_checkpoint()
		connect("checkpoint_activated", Callable(CheckpointManager, "on_checkpoint_activated"))

		
func _on_body_entered(body):
	if activated: 
		return
		
	if body.is_in_group("Player"):
		activated = true
		$checkpointflag.queue_free()
		emit_signal("checkpoint_activated", checkpoint_id)

	

extends CanvasLayer
	
func _process(_delta: float) -> void:
	var character = get_parent() as CharacterBody3D
	if not character:
		return
	var horzspeed = Vector3(character.velocity.x, 0.0, character.velocity.z).length()
	var vertspeed = Vector3(0.0, character.velocity.y, 0.0).length()
	$Control/Speedometer.text = "H: %.2f  |  V: %.2f" % [horzspeed, vertspeed]

func _on_timer_time_changed(minutes, seconds, msec) -> void:
	$Control/Minutes.text = "%02d:" % minutes
	$Control/Seconds.text = "%02d:" % seconds
	$Control/Milliseconds.text = "%03d" % msec

extends CanvasLayer
	
func _process(delta: float) -> void:
	pass


func _on_timer_time_changed(minutes, seconds, msec) -> void:
	$Control/Minutes.text = "%02d:" % minutes
	$Control/Seconds.text = "%02d:" % seconds
	$Control/Milliseconds.text = "%03d" % msec

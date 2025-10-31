extends Node3D

@export var time := 0.0
@export var minutes : int = 0
@export var seconds : int = 0
@export var msec : int = 0

signal time_changed(minutes, seconds, msec)

func _process(delta: float) -> void:
	time += delta
	msec = fmod(time, 1) * 100
	seconds = fmod(time, 60)
	minutes = fmod(time, 3600) / 60
	time_changed.emit(minutes, seconds, msec)
	if Global.stop_timer == true:
		stop(minutes, seconds, msec)

func stop(minutes, seconds, msec) -> void:
	Global.final_time = "%02d:%02d:%03d" % [minutes, seconds, msec]
	set_process(false)
	Global.stop_timer = false

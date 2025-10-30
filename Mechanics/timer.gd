extends Node3D

@export var time := 0.0
@export var minutes : int = 0
@export var seconds : int = 0
@export var msec : int = 0

signal time_changed

func _process(delta: float) -> void:
	time += delta
	minutes = fmod(time, 3600) / 60
	seconds = fmod(time, 60)
	msec = fmod(time, 1) * 100
	time_changed.emit(minutes, seconds, msec)
	

extends Node3D

@onready var grunts: AudioStreamPlayer3D = $Grunts
@onready var footsteps: AudioStreamPlayer3D = $FootSteps

var jump_sounds: Array[AudioStream] = [
	preload("res://Sounds/jump_grunt_ty_1.mp3"),
	preload("res://Sounds/jump_grunt_ty_2.mp3"),
	preload("res://Sounds/jump_grunt_ty_3.mp3"),
	preload("res://Sounds/jump_grunt_ty_4.mp3")
]

var footstep_sounds: Array[AudioStream] = [
	preload("res://Sounds/footstep_1.mp3"),
	preload("res://Sounds/footstep_2.mp3"),
	preload("res://Sounds/footstep_3.mp3"),
	preload("res://Sounds/footstep_4.mp3"),
	preload("res://Sounds/footstep_5.mp3")
]

var wall_jump_sounds: Array[AudioStream] = [
	preload("res://Sounds/doublejump_grunt_ty_1.mp3")
]

var footstep_timer: Timer

func _ready() -> void:
	randomize()

	footstep_timer = Timer.new()
	footstep_timer.one_shot = false
	footstep_timer.connect("timeout", Callable(self, "_play_footstep"))
	add_child(footstep_timer)

func _on_character_body_3d_audio_is_jumping(active: Variant) -> void:
	if active:
		play_air_sound(jump_sounds)
		play_ground_sound(footstep_sounds)

func _on_character_body_3d_audio_is_wall_jumping(active: Variant) -> void:
	if active:
		play_air_sound(wall_jump_sounds)
		play_ground_sound(footstep_sounds)

func _on_character_body_3d_audio_is_sprinting(speed: Variant) -> void:
	var character = get_parent() as CharacterBody3D
	if not character:
		return

	if character.is_on_floor() and character.velocity.length() > 0.0:
		var min_speed = 6.0
		var max_speed = 8.0
		var min_interval = 0.3
		var max_interval = 0.35

		var interval = lerp(max_interval, min_interval, clamp((speed - min_speed) / (max_speed - min_speed), 0, 1))
		
		if footstep_timer.is_stopped():
			footstep_timer.start(interval)
		else:
			footstep_timer.wait_time = interval
	else:
		footstep_timer.stop()

func _play_footstep() -> void:
	play_ground_sound(footstep_sounds)

func play_air_sound(sounds: Array) -> void:
	if sounds.size() == 0:
		return
	var index = randi() % sounds.size()
	grunts.stream = sounds[index]
	grunts.play()

func play_ground_sound(sounds: Array) -> void:
	if sounds.size() == 0:
		return
	var index = randi() % sounds.size()
	footsteps.stream = sounds[index]
	footsteps.play()

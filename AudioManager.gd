extends Node

var master_volume := 1.0
var master_slider_value := 1.0
var is_muted: bool = false

func set_master_volume(value: float):
	master_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

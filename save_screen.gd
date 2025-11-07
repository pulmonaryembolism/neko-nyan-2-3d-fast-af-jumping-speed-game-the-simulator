extends Control

var save_path = "user://times.save"

@onready var slots := [
	$MarginContainer/VBoxContainer/Slot1,
	$MarginContainer/VBoxContainer/Slot2,
	$MarginContainer/VBoxContainer/Slot3,
	$MarginContainer/VBoxContainer/Slot4,
	$MarginContainer/VBoxContainer/Slot5,
	$MarginContainer/VBoxContainer/Slot6,
	$MarginContainer/VBoxContainer/Slot7,
	$MarginContainer/VBoxContainer/Slot8
]

@onready var back_button = $MarginContainer/VBoxContainer/BackButton


func _ready() -> void:
	for i in range(slots.size()):
		var slot_number = i + 1
		var slot_button = slots[i]
		slot_button.pressed.connect(_on_SlotButton_pressed.bind(slot_number))
		var slot_save_path = "user://times_slot_%d.save" % slot_number
		update_slot_text(slot_button, slot_save_path)
	back_button.pressed.connect(_on_BackButton_pressed)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_SlotButton_pressed(slot_number: int) -> void:
	var slot_save_path = "user://times_slot_%d.save" % slot_number
	save_data_to_slot(slot_save_path)
	update_slot_text(slots[slot_number - 1], slot_save_path)


func save_data_to_slot(slot_save_path: String) -> void:
	var data = {
		"time": Global.final_time
	}
	var file = FileAccess.open(slot_save_path, FileAccess.WRITE)
	if file:
		file.store_var(data)
		file.close()


func update_slot_text(slot_button: Button, slot_save_path: String) -> void:
	if FileAccess.file_exists(slot_save_path):
		var file = FileAccess.open(slot_save_path, FileAccess.READ)
		var data = file.get_var()
		file.close()

		var time_value = data.get("time", null)
		if time_value != null:
			slot_button.text = str(time_value)
		else:
			slot_button.text = "Empty"
	else:
		slot_button.text = "Empty"


func _on_BackButton_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")

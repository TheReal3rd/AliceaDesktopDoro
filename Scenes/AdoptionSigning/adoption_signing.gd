extends Window

@onready var signitureText = $Control/ScrollContainer/VBoxContainer/VBoxContainer/NameSign
@onready var global = get_node("/root/Global")


func _on_close_requested() -> void:
	get_tree().quit(0)


func _on_confirm_pressed() -> void:
	global.unleashTheCreature(signitureText.get_text())
	queue_free()

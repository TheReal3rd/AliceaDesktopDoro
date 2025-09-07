extends Window

@onready var frontSide = $Node3D/FrontSide
@onready var backSide = $Node3D/BackSide


func _physics_process(delta: float) -> void:
	frontSide.rotation_degrees.y = lerp(frontSide.rotation_degrees.y, frontSide.rotation_degrees.y + 360, 0.2 * delta)
	backSide.rotation_degrees.y = lerp(backSide.rotation_degrees.y, backSide.rotation_degrees.y + 360, 0.2 * delta)


func _on_close_requested() -> void:
	queue_free()

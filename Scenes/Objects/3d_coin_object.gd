extends Node3D

@onready var frontSide = $FrontSide
@onready var backSide = $BackSide


func _physics_process(delta: float) -> void:
	frontSide.rotation_degrees.y = lerp(frontSide.rotation_degrees.y, frontSide.rotation_degrees.y + 360, 0.2 * delta)
	backSide.rotation_degrees.y = lerp(backSide.rotation_degrees.y, backSide.rotation_degrees.y + 360, 0.2 * delta)

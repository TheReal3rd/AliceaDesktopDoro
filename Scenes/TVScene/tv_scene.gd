extends Window

@onready var global = get_node("/root/Global")

@onready var tvSprite = $Area2D/Sprite2D
@onready var tvLight = $Area2D/PointLight2D

var dragging: bool = false
var focus: bool = false
var mouseOnScreen: bool = false

func _ready() -> void:
	var doroNode = global.getDoroNode()
	set_position(doroNode.getPosition())
	
func _process(delta: float) -> void:
	tvLight.set_color(Color.from_hsv(Time.get_ticks_msec() / 10000.0, 1, 1, lerp(0.5, 1.0, 1.0 * delta)))
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		queue_free()
		global.getDoroNode().emit_signal("tvDestroyed")
	
	var currentPosition = get_position()
	if dragging and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		dragging = true
	else:
		dragging = mouseOnScreen and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		
	if dragging:
		currentPosition = DisplayServer.mouse_get_position() - (get_size_with_decorations() / 2)
	
	set_position(currentPosition)

func _on_close_requested() -> void:
	queue_free()

func _on_mouse_entered() -> void:
	mouseOnScreen = true

func _on_mouse_exited() -> void:
	mouseOnScreen = false

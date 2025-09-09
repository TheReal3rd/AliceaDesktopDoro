extends Node2D

@onready var outlineRect: ColorRect = $Outline
@onready var displayLabel: Label = $Outline/Inner/DisplayIDLabel

@onready var topPos: Node2D = $TopPosition
@onready var bottomPos: Node2D = $BottomPosition
@onready var leftPos: Node2D = $LeftPosition
@onready var rightPos: Node2D = $RightPosition

var managerRefer = null: set = setManagerRefer 

var displayID: int = -1: set = setDisplayID, get = getDisplayID
var colour: Color = Color.WHITE: set = setColour, get = getColour
var hovering: bool = false: set = setHovering, get = isHovering
var dragging: bool = false: set = setDragging, get = isDragging

func _ready() -> void:
	displayLabel.set_text("Display: %d" % displayID)
	outlineRect.set_color(colour)
	displayLabel.set_modulate(colour)
	
func _physics_process(delta: float) -> void:
	if (hovering or dragging) and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not managerRefer.isAlreadyDragging():
		dragging = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		if dragging:
			if managerRefer != null:
				managerRefer.emit_signal("startDragging")
	else:
		dragging = false
		if managerRefer != null:
			managerRefer.emit_signal("stopDragging")
	
	if dragging:
		var withInLockRange: bool = false
		var closestPoint: Vector2
		var closestDistance: float = 100000000000.0
		for otherDisplays:Node2D in managerRefer.getDisplays(displayID):
			for point: Vector2 in otherDisplays.getSnappingPoints():
				var tempDist = point.distance_to(get_global_position())
				if tempDist < closestDistance:
					closestPoint = point
					closestDistance = tempDist
					
		if closestDistance <= 25:
			withInLockRange = true
		
		if withInLockRange:
			set_global_position(closestPoint)
			print("Snap")
		else:
			set_global_position(get_global_mouse_position() - (getSize() / 2))
	
func setDisplayID(newID: int) -> void:
	displayID = newID
	if is_node_ready():
		displayLabel.set_text("Display: %d" % displayID)
	
func getDisplayID() -> int:
	return displayID
	
func setColour(newColour: Color) -> void:
	colour = newColour
	if is_node_ready():
		outlineRect.set_color(colour)
		displayLabel.set_modulate(colour)

func getColour() -> Color:
	return colour
	
func setManagerRefer(newManager: Window) -> void:
	managerRefer = newManager
	
func getSize() -> Vector2:
	return outlineRect.get_size()
	
func setPosition(newPos: Vector2) -> void:
	global_position = newPos
	
func getPosition() -> Vector2:
	return global_position
	
func setHovering(newHovering: bool) -> void:
	hovering = newHovering
	
func isHovering() -> bool:
	return hovering
	
func setDragging(newDragging: bool) -> void:
	dragging = newDragging
	
func isDragging() -> bool:
	return dragging
	
func getSnappingPoints() -> Array:
	return [ topPos.get_global_position(), bottomPos.get_global_position(), leftPos.get_global_position(), rightPos.get_global_position() ]

func _on_drag_button_mouse_entered() -> void:
	hovering = true

func _on_drag_button_mouse_exited() -> void:
	hovering = false

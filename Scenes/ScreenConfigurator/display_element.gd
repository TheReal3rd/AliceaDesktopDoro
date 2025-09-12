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
var displayState: bool = true: set = setDisplayState, get = getDisplayState

var snapPosition = null

func _ready() -> void:
	displayLabel.set_text("Display: %d" % displayID)
	outlineRect.set_color(colour)
	displayLabel.set_modulate(colour)
	
func _physics_process(delta: float) -> void:
	if (hovering or dragging) and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not managerRefer.isAlreadyDragging():
		dragging = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		if dragging:
			if managerRefer != null:
				managerRefer.emit_signal("startDragging", self)
	else:
		dragging = false
		if managerRefer != null:
			managerRefer.emit_signal("stopDragging")
	
	if dragging:
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
	if dragging and not newDragging:
		if snapPosition and snapPosition != null and global_position.distance_to(snapPosition) <= 330:
			set_global_position(snapPosition)
			snapPosition = null
	dragging = newDragging
	
func isDragging() -> bool:
	return dragging
	
func setDisplayState(newState:bool) -> void:
	displayState = newState
	
func getDisplayState() -> bool:
	return displayState
	
func getSnappingPoints() -> Array:
	return [ topPos.get_global_position(), bottomPos.get_global_position(), leftPos.get_global_position(), rightPos.get_global_position() ]

func _on_drag_button_mouse_entered() -> void:
	hovering = true

func _on_drag_button_mouse_exited() -> void:
	hovering = false

func findSnappingPoint(area: Area2D):
	var hitNode = area.get_parent()
	if dragging:
		for groupName in area.get_groups():
			match groupName:
				"DisplayTop":
					snapPosition = hitNode.get_global_position() - Vector2(0, 135)
				"DisplayBottom":
					snapPosition = hitNode.get_global_position() + Vector2(0, 135)
				"DisplayLeft":
					snapPosition = hitNode.get_global_position() - Vector2(240, 0)
				"DisplayRight":
					snapPosition = hitNode.get_global_position() + Vector2(240, 0)

func _on_top_position_area_entered(area: Area2D) -> void:
	findSnappingPoint(area)

func _on_bottom_position_area_entered(area: Area2D) -> void:
	findSnappingPoint(area)

func _on_left_position_area_entered(area: Area2D) -> void:
	findSnappingPoint(area)
	
func _on_right_position_area_entered(area: Area2D) -> void:
	findSnappingPoint(area)

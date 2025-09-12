extends Window

@onready var outlineNode = $OutlineRect
@onready var displayIDLabel = $OutlineRect/DisplayIDLabel
@onready var displaySizeLabel = $OutlineRect/DisplaySizeLabel
@onready var stateLabel = $OutlineRect/EnabledStateLabel

var displayColour:Color = Color.RED: set = setColour, get = getColour
var displayID:int = -1: set = setDisplayID, get = getDisplayID
var displaySize:Vector2 = Vector2.ZERO: set = setDisplaySize, get = getDisplaySize
var displayState:bool = true: set = setDisplayState, get = getDisplayState

func setWindowPosition(newPosition:Vector2i) -> void:
	DisplayServer.window_set_position(newPosition, get_window_id())

func setColour(newColour:Color) -> void:
	displayColour = newColour
	outlineNode.set_border_color(displayColour)
	
func getColour() -> Color:
	return displayColour
	
func setDisplayID(newID:int) -> void:
	displayID = newID
	displayIDLabel.set_text("DisplayID: %d" % displayID)
	
func getDisplayID() -> int:
	return displayID
	
func setDisplaySize(newSize:Vector2) -> void:
	displaySize = newSize
	displaySizeLabel.set_text("Size: %d:%d" % [displaySize.x, displaySize.y])
	
func getDisplaySize() -> Vector2:
	return displaySize
	
func setDisplayState(newState:bool) -> void:
	displayState = newState
	stateLabel.set_text("State: %s" % displayState)
	
func getDisplayState() -> bool:
	return displayState
	

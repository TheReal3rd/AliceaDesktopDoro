extends Window

@onready var displayElementScene = load("res://Scenes/ScreenConfigurator/DisplayElement.tscn")
@onready var displayOutlineScene = load("res://Scenes/ScreenConfigurator/WindowOutlineObject.tscn")

@onready var displaysContainer = $Control/ColorRect/ScrollContainer/HBoxContainer
@onready var scrollContainer = $Control/ColorRect/ScrollContainer

#Display Editor
@onready var displaySettingsContainer = $Control/DisplaySettings
@onready var displayIDLabel = $Control/DisplaySettings/DisplaySettings/DisplayIDLabel
@onready var stateCheckbox = $Control/DisplaySettings/DisplaySettings/StateCheckButton

var displayServer = null
var alreadyDragging = false: get = isAlreadyDragging
var displaysList: Array[Node2D] = []
var displayOutlineList: Array[Window] = []
var displaySize: Vector2 = Vector2.ZERO

var draggedDisplayNode = null

signal startDragging(displayNode)
signal stopDragging

func _ready() -> void:
	displaySettingsContainer.hide()
	var scrollAreaSize:Vector2 = displaysContainer.get_custom_minimum_size()
	scrollContainer.set_h_scroll((scrollAreaSize.x / 2) - 350)#350 is the half of the scroll bar width can't get scroll bar size. *Eyes roll.*
	scrollContainer.set_v_scroll((scrollAreaSize.y / 2) - 350)
	
	#Hacky way of fetching the size dynmically.
	var sizeFetchDisplay = displayElementScene.instantiate()
	displaysContainer.add_child(sizeFetchDisplay)
	displaySize = sizeFetchDisplay.getSize()
	sizeFetchDisplay.queue_free()
	
	displayServer = DisplayServer
	var xOffset = 0 - displaySize.x
	for x in (displayServer.get_screen_count()):
		var colour:Color = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))
		
		var tempDisplayOutline = displayOutlineScene.instantiate()
		add_child(tempDisplayOutline)
		displayOutlineList.append(tempDisplayOutline)
		tempDisplayOutline.setWindowPosition(displayServer.screen_get_position(x))
		tempDisplayOutline.setDisplayID(x)
		tempDisplayOutline.setDisplaySize(displayServer.screen_get_size())
		tempDisplayOutline.setColour(colour)
	
		var tempDisplay = displayElementScene.instantiate()
		tempDisplay.setDisplayID(x)
		tempDisplay.setColour(colour)
		tempDisplay.setPosition((scrollAreaSize / 2) + Vector2(xOffset, displaySize.y / 2))
		tempDisplay.setManagerRefer(self)
		displaysContainer.add_child(tempDisplay)
		displaysList.append(tempDisplay)
		xOffset += displaySize.x
		

func isAlreadyDragging() -> bool:
	return alreadyDragging

func _on_close_requested() -> void:
	queue_free()

func _on_exit_button_pressed() -> void:
	queue_free()

func _on_start_dragging(displayNode) -> void:
	alreadyDragging = true
	draggedDisplayNode = displayNode
	displaySettingsContainer.show()
	displayIDLabel.set_text("DisplayID: %d" % displayNode.getDisplayID())
	stateCheckbox.set_pressed_no_signal(displayNode.getDisplayState())

func _on_stop_dragging() -> void:
	alreadyDragging = false

func _on_state_check_button_toggled(toggled_on: bool) -> void:
	if draggedDisplayNode != null:
		draggedDisplayNode.setDisplayState(toggled_on)
		displayOutlineList[draggedDisplayNode.getDisplayID()].setDisplayState(toggled_on)

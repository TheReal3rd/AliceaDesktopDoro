extends Window

@onready var displayElementScene = load("res://Scenes/ScreenConfigurator/DisplayElement.tscn")

@onready var displaysContainer = $Control/ColorRect/ScrollContainer/HBoxContainer

var displayServer = null
var alreadyDragging = false: get = isAlreadyDragging
var displaysList: Array[Node2D] = []

signal startDragging
signal stopDragging

func _ready() -> void:
	displayServer = DisplayServer
	var xOffset = 0
	for x in (displayServer.get_screen_count()):
		var tempDisplay = displayElementScene.instantiate()
		tempDisplay.setDisplayID(x)
		tempDisplay.setColour(Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0)))
		tempDisplay.setPosition(tempDisplay.getPosition() + Vector2(xOffset, 0))
		tempDisplay.setManagerRefer(self)
		displaysContainer.add_child(tempDisplay)
		displaysList.append(tempDisplay)
		xOffset += tempDisplay.getSize().x
		
func getDisplays(filterID:int=-1) -> Array:
	var returnList: Array = []
	for display in displaysList:
		if display.getDisplayID() == filterID:
			continue
		returnList.append(display)
	return returnList

func isAlreadyDragging() -> bool:
	return alreadyDragging

func _on_close_requested() -> void:
	queue_free()

func _on_exit_button_pressed() -> void:
	queue_free()

func _on_start_dragging() -> void:
	alreadyDragging = true

func _on_stop_dragging() -> void:
	alreadyDragging = false

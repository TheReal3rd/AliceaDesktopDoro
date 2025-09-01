extends Window

@onready var connectionNodePath = load("res://Scenes/NukeSabotage/ConnectionNode.tscn")

@onready var miniGameNode: GridContainer = $Control/MiniGameNode

#TODO near future maybe make this dynamically size on random number.
var columns: int = 8
var rows: int = 8

var gridNodeList: Array[Control] = []

func _ready() -> void:
	miniGameNode.set_columns(columns)
	buildGrid()

func buildGrid() -> void:
	for i in range(columns * rows):
		var cell = connectionNodePath.instantiate()
		miniGameNode.add_child(cell)
	await get_tree().process_frame
	miniGameNode.pivot_offset = size / 2


func _process(delta: float) -> void:
	pass

func _on_close_requested() -> void:
	queue_free()

extends TextureButton

@onready var colourRectNode = $ColorRect

var gameWindowNode: Window = null : set = setGameWindowNode

var cellID: int = -1 : set = setCellID, get = getCellID
var active: bool = false

enum CellTypeEnum { EndCell, FillerCell, DeadCell }
var cellType: CellTypeEnum = CellTypeEnum.FillerCell : set = setCellType, get = getCellType

func _ready() -> void:
	setColour(Color(1.0, 1.0, 1.0))
	
func _process(delta: float) -> void:
	pass
			
func _on_mouse_entered() -> void:
	match cellType:
		CellTypeEnum.DeadCell:
			gameWindowNode.emit_signal("badMove")
		_:
			if gameWindowNode.isCellDrawing():
				var activeCell = gameWindowNode.getActiveCell()
				if activeCell.getCellID() == getCellID():
					setColour(activeCell.getColour())
				gameWindowNode.emit_signal("cellTrailingInfo", self)

func setGameWindowNode(gameWindow: Window) -> void:
	gameWindowNode = gameWindow

func setCellType(newCellType) -> void:
	cellType = newCellType
	
func getCellType() -> int:
	return cellType

func setColour(newColour: Color) -> void:
	colourRectNode.set_color(newColour)
	
func getColour() -> Color:
	return colourRectNode.get_color()
	
func setCellID(newID) -> void:
	cellID = newID
	
func getCellID() -> int:
	return cellID

func _on_button_down() -> void:
	var activeCell = gameWindowNode.getActiveCell()
	if activeCell == null:
		match cellType:
			CellTypeEnum.EndCell:
				gameWindowNode.emit_signal("cellPressed", self)
			CellTypeEnum.FillerCell:
				pass

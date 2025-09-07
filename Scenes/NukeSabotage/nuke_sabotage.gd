extends Window

@onready var connectionNodePath = load("res://Scenes/NukeSabotage/ConnectionNode.tscn")

@onready var miniGameNode: GridContainer = $GameplayScreen/MiniGameNode
@onready var timerLabel: Label = $GameplayScreen/TimerLabel
@onready var timer: Timer = $GameTimer
@onready var scoreLabel: Label = $GameplayScreen/ScoreLabel
@onready var endGameScoreLabel = $GameplayScreen/EndgameScreen/ScoreLabel

@onready var gameplayScreen: Control = $GameplayScreen
@onready var endGameScreen: Control = $GameplayScreen/EndgameScreen
@onready var aliceaDoroObjectNode: Node = $GameplayScreen/EndgameScreen/AliceaDoroObject

@onready var global = $"/root/Global"

#TODO near future maybe make this dynamically size on random number.
var columns: int = 8
var rows: int = 8

var gridCellList: Array[TextureButton] = []
var puzzleCellDict: Dictionary = {}

var colourList: Array[Color] = [
	Color(1.0, 0.0, 0.0),
	Color(0.0, 1.0, 0.0),
	Color(0.0, 0.0, 1.0),
	Color(1.0, 1.0, 0.0),
	Color(0.0, 1.0, 1.0),
	Color(1.0, 0.0, 1.0),
]

signal cellPressed(cell: TextureButton)
signal cellTrailingInfo(cell: TextureButton)
signal badMove

var activeCell: TextureButton = null : get = getActiveCell
var currentIndex: int = -1
var reverseOrdered: bool = false

var playerScore = 0

func _ready() -> void:
	miniGameNode.set_columns(columns)
	buildGrid()
	generateGridPoints()
	timer.start()
	endGameScreen.hide()
	
func _process(delta: float) -> void:
	timerLabel.set_text("Timer: %d" % timer.get_time_left())
	scoreLabel.set_text("Score: %d" % playerScore)

func buildGrid() -> void:
	for i in range(columns * rows):
		var cell = connectionNodePath.instantiate()
		cell.setGameWindowNode(self)
		gridCellList.append(cell)
		miniGameNode.add_child(cell)
	await get_tree().process_frame
	miniGameNode.pivot_offset = size / 2
	
func positionToIndex(pos: Vector2i) -> int:
	return pos.y * rows + pos.x
	
func generateGridPoints():
	randomize()
	var numberOfPoints: int = randi_range(3, 5)
	for pointStage in range(0, numberOfPoints):
		var validStart: bool = false
		var startPosition: Vector2i = Vector2i.ZERO
		var cell: Control
		while not validStart:
			startPosition = Vector2i(randi_range(0, 7), randi_range(0, 7))
			cell = gridCellList[positionToIndex(startPosition)]
			if cell.getCellID() != -1:
				continue
			else:
				validStart = true
		
		var depth: int = randi_range(5,10)
		var cellList: Array[TextureButton] = []
		cellList.append(cell)
		cell.setColour(colourList[pointStage])
		cell.setCellID(pointStage)
		cell.setCellIndex(cellList.size() - 1)
		for step in range(0, depth):
			for direction in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1)]:
				var tempPos: Vector2i = startPosition + direction
				if tempPos.x <= 0 or tempPos.y <= 0 or tempPos.x >= rows or tempPos.y >= columns:
					continue
					
				var tempCell = gridCellList[positionToIndex(tempPos)]
				if tempCell.getCellID() == -1:
					startPosition = tempPos
					tempCell.setColour(colourList[pointStage])
					tempCell.setCellID(pointStage)
					tempCell.setCellIndex(cellList.size())
					cellList.append(tempCell)
		
		#Removes any cell lengths smaller then 2.
		if cellList.size() <= 3:
			for badCell in cellList:
				badCell.setCellID(-1)
		else:
			cellList[0].setCellType(0)
			cellList[cellList.size() - 1].setCellType(0)
			for cellIndex in range(1, cellList.size() - 1):
				cellList[cellIndex].setColour(Color(1.0, 1.0, 1.0))
				#cellList[cellIndex].setColour(cellList[cellIndex].getColour() - Color(0.0, 0.0, 0.0, 0.5))
			puzzleCellDict.set(pointStage, cellList)
	
	#Disable all disused cells.
	for cell in gridCellList:
		if cell.getCellID() == -1:
			cell.setCellType(2)
			cell.set_disabled(true)
			cell.setColour(Color(0.0, 0.0, 0.0))

func getActiveCell() -> TextureButton:
	return activeCell

func isCellDrawing() -> bool:
	return activeCell != null

func _on_close_requested() -> void:
	queue_free()

func _on_cell_pressed(cell: TextureButton) -> void:
	activeCell = cell
	currentIndex = activeCell.getCellIndex()
	var maxIndex = puzzleCellDict.get(activeCell.getCellID()).size() - 1
	if currentIndex == maxIndex:
		reverseOrdered = true
	#print("%d | %d | %s" % [currentIndex, maxIndex, reverseOrdered])
	
func pathCompletionCheck(pathID: int) -> bool:
	var cellList = puzzleCellDict.get(pathID)
	var colour = cellList[0].getColour()
	for cell in cellList:
		if cell.getColour() != colour:
			return false
	return true
	
func pathReset(pathID:int) -> void:
	var cellList = puzzleCellDict.get(pathID)
	for cell in cellList:
		if cell.getCellType() == 1:
			cell.setColour(Color(1.0, 1.0, 1.0))
			
func pathLock(pathID:int) -> void:
	var cellList = puzzleCellDict.get(pathID)
	for cell in cellList:
		cell.setCellType(2)
		cell.setColour(Color(0.0, 0.0, 0.0))
		cell.set_disabled(true)
	puzzleCellDict.erase(pathID)
	
	if puzzleCellDict.size() <= 0:
		playerScore += 1
		gridReset()
		generateGridPoints()
	
func gridReset() -> void:
	for cell in gridCellList:
		cell.setColour(Color(1.0, 1.0, 1.0))
		cell.setCellID(-1)
		cell.setCellIndex(-1)
		cell.setCellType(1)
		cell.set_disabled(false)

func gridLock() -> void:
	for cell in gridCellList:
		cell.setColour(Color(0.0, 0.0, 0.0))
		cell.setCellID(-1)
		cell.setCellIndex(-1)
		cell.setCellType(1)
		cell.set_disabled(true)
	
func _on_cell_trailing_info(cell: TextureButton) -> void:
	var badMove: bool = false
	if activeCell != null:
		var currentPathID: int = activeCell.getCellID()
		if currentPathID != cell.getCellID():
			badMove = true
		else:
			if cell.getCellType() == 1:
				var tempCellIndex =  cell.getCellIndex()
				if reverseOrdered:
					if tempCellIndex == currentIndex - 1:
						currentIndex = tempCellIndex
					else:
						badMove = true
				else:
					if tempCellIndex == currentIndex + 1:
						currentIndex = tempCellIndex
					else:
						badMove = true
						
			elif cell.getCellType() == 0:
				if pathCompletionCheck(currentPathID):
					pathLock(currentPathID)
					activeCell = null
					reverseOrdered = false
				else:
					badMove = true

		if badMove:
			pathReset(currentPathID)
			activeCell = null
			reverseOrdered = false
		
func _on_bad_move() -> void:
	if activeCell != null:
		pathReset(activeCell.getCellID())
		activeCell = null
		reverseOrdered = false

func _on_game_timer_timeout() -> void:
	activeCell = null
	reverseOrdered = false
	
	endGameScoreLabel.set_text("Score: %d" % playerScore)
	if playerScore <= 0:
		aliceaDoroObjectNode.setAnimation(aliceaDoroObjectNode.animations.EvilLaugh)
	else:
		var doroNode: Node = global.getDoroNode()
		doroNode.changeNukeProgress(playerScore * 10)
		doroNode.changeHappinessScore(playerScore * 10)
		doroNode.veryAngyDoro()
	timer.stop()
	endGameScreen.show()
	gridLock()

func _on_finish_button_pressed() -> void:
	queue_free()

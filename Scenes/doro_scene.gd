extends Area2D

@onready var optionsMenuScene = load("res://Scenes/OptionsMenu.tscn")
@onready var debugMenuScene = load("res://Scenes/DevelopmentScenes/DebugTools/DebugCheatMenu.tscn")
@onready var tvScene = load("res://Scenes/TVScene/TVScene.tscn")

@onready var spriteTexture = $AnimatedSprite2D
@onready var sleepingParticlesEmitter = $SleepingParticles
@onready var confusedParticleEmitter = $ConfusedParticles
@onready var heartsParticleEmitter = $HeartsParticles
@onready var psychedlicParticleEmitter = $PsychedlicParticles
@onready var eatingParticleEmitter = $EatingParticles
@onready var hungyParticleEmitter = $HungyParticles
@onready var global = get_node("/root/Global")
@onready var cagedSprite = $CageSprite
@onready var angySprite = $AngySprite

#Settings
var disableCaring: bool = false
#Physics
const walkSpeed: float = 200.0
const runSpeed: float = 400.0
var velocity: Vector2 = Vector2.ZERO
var panicState: bool = false

#Display Related
var windowSize: Vector2i = Vector2i.ZERO
var displaySize: Vector2 = Vector2.ZERO
var currentPosition: Vector2i = Vector2i.ZERO : get = getPosition
var totalScreenSize: Vector2i = Vector2i.ZERO

#Movement Related
var moveDelay: TimeDelay = TimeDelay.new()
var movementAngleToggle: int = 1
@export var movementAngleSteepness: int = 9
@export var movementAngleSpeed: float = 6.0
var movementPause: bool = false
@export var caged: bool = true: get = isCaged, set = setCaged
@warning_ignore("unused_signal")
signal uncage

#Waypoint Related
var waypointLocation: Vector2i = Vector2i.ZERO
var screenOutboundPadding: int = 230
var nextMoveWaitDuration: float = randf_range(5, 10)
var minDistanceToWaypoint:float = 10

#Draging Related
var dragging: bool = false

#Emotion
var hungyLevel: int = 0 : set = setHungyLevel
var happinesScore: int = 100 : set = setHappinessScore
var hungerDelay: TimeDelay = TimeDelay.new()
@export var dragPunishmentAmount: int = 4
@export var pokePunishmentAmount: int = 5
var dragTimerTracker: TimeTracker = TimeTracker.new()
var dragTimerPrevDura: float = 0.0
@export var angyDragDuration: int = 5
var angyAngleToggle: int = 1

#Headpat
var headPatPart1: bool = false
var headPatpart2: bool = false
var headPatCount: int = 0
var headPatAmount: int = 0
@export var headPatLimit: int = 5
@export var headPatTriggerAmount: int = 5
var headPatAngyTriggered: bool = false

#Random Task
enum TasksEnum { None,  Sleeping, SundayBodyPillow, Sunglasses, WatchingTV, NukeTinker }
var currentTask: TasksEnum = TasksEnum.None
@export var chanceForTask:int = 15
var tvNode: Node = null
var watchingTV: bool = true
var watchTime: TimeDelay = TimeDelay.new()
@warning_ignore("unused_signal")
signal tvDestroyed

#Animations
enum Animations { None, Happie, Angy, Psychedelics, EvilLaugh }
var currentAnimation: Animations = Animations.None : set = setCurrentAnimation
var animationDelay: TimeDelay = TimeDelay.new()

#Player shop
var playerCoins: int = 0 : get = getCoins, set = setCoins

#Alicea world domination
var nukeProgress: int = 0 : set = setNukeProgress

func _ready() -> void:
	windowSize = DisplayServer.window_get_size()
	displaySize = DisplayServer.screen_get_size()
	currentPosition = DisplayServer.window_get_position()
	applyAnimation()
	totalScreenSize = calcScreenAreaSize()
	waypointLocation = createRandomPoint()
	global.setDoroNode(self)
	angySprite.hide()
	var caringSetting = global.getSetting("NoDoroCare")
	disableCaring = caringSetting.getValue()

func changeHappinessScore(amount: int) -> void:
	setHappinessScore(happinesScore + amount)

func changeHungyLevel(amount: int) -> void:
	setHungyLevel(hungyLevel + amount)

func changeNukeProgress(amount: int) -> void:
	setNukeProgress(nukeProgress + amount)
	
func giveCoins(amount: int) -> void:
	setCoins(playerCoins + amount)
	
func getCoins() -> int:
	return playerCoins
	
func setCoins(value: int):
	playerCoins = clamp(value, 0, 9223372036854775807)

func setCurrentAnimation(newAnimation) -> void:
	match currentAnimation:
		Animations.Happie:
			heartsParticleEmitter.set_emitting(false)
		Animations.Angy:
			panicState = false
			angySprite.hide()
		Animations.Psychedelics:
			psychedlicParticleEmitter.set_emitting(false)
	currentAnimation = newAnimation

func applyAnimation() -> void:
	if caged:
		spriteTexture.play("Sad")
		cagedSprite.show()
		return
		
	if currentAnimation != Animations.None:
		if currentTask != TasksEnum.None:
			currentTask = TasksEnum.None
			
		match currentAnimation:
			Animations.Happie:
				spriteTexture.play("Happie")
				heartsParticleEmitter.set_emitting(true)
				if animationDelay.hasPassed(2):
					currentAnimation = Animations.None
					heartsParticleEmitter.set_emitting(false)
				return
			Animations.Angy:
				if angySprite.hidden:
					angySprite.show()
				spriteTexture.play("Angy")
				if animationDelay.hasPassed(2):
					currentAnimation = Animations.None
					panicState = false
					angySprite.hide()
				return
			Animations.Psychedelics:
				spriteTexture.play("Psychedlic")
				psychedlicParticleEmitter.set_emitting(true)
				if animationDelay.hasPassed(10):
					currentAnimation = Animations.None
					psychedlicParticleEmitter.set_emitting(false)
				return
			Animations.EvilLaugh:
				spriteTexture.play("EvilLaugh")
				if animationDelay.hasPassed(2):
					currentAnimation = Animations.None
				return

	if currentTask != TasksEnum.None:
		match currentTask:
				TasksEnum.Sleeping:
					spriteTexture.play("Idle")
					spriteTexture.pause()
					spriteTexture.set_frame(0)
				TasksEnum.SundayBodyPillow:
					spriteTexture.play("sundayPillow")
				TasksEnum.Sunglasses:
					spriteTexture.play("Sunglasses")
		return
	
	if happinesScore < 30:
		spriteTexture.play("Reallyangy")
	elif happinesScore <= 65:
		spriteTexture.play("Angy")
	elif happinesScore < 85:
		spriteTexture.play("Sad")
	else:
		spriteTexture.play("Idle")

func calcDistanceToWaypoint() -> float:
	var xDiff: float = (currentPosition.x + (windowSize.x / 2.0)) - waypointLocation.x
	var yDiff: float = (currentPosition.y + (windowSize.y / 2.0)) - waypointLocation.y
	return sqrt((xDiff * xDiff) + (yDiff * yDiff))
	
func setHappinessScore(newValue: int) -> void:
	if disableCaring:
		happinesScore = 100
		return
	
	happinesScore = clamp(newValue, 0, 100)
	
func setHungyLevel(newValue: int) -> void:
	if disableCaring:
		hungyLevel = 0
		return
	
	hungyLevel = clamp(newValue, 0, 100)

func setNukeProgress(amount: int) -> void:
	if disableCaring:
		nukeProgress = 0
		return
	
	nukeProgress = clamp(amount, 0, 100)
	
	if nukeProgress == 100:
		pass#TODO add end game where alicea achives world domination.

func calcScreenAreaSize() -> Vector2i:
	var screenCount = DisplayServer.get_screen_count()
	var minHeight = 1000000000
	var widthTotal = 0
	for screenID in range(0, screenCount):
		var tempSize = DisplayServer.screen_get_size(screenID)
		widthTotal += tempSize.x
		minHeight = min(minHeight, tempSize.y)
	return Vector2i(widthTotal - screenOutboundPadding, minHeight - screenOutboundPadding)

func createRandomPoint() -> Vector2i:
	var returnValue: Vector2i = Vector2i(randi_range(screenOutboundPadding, totalScreenSize.x), randi_range(screenOutboundPadding, totalScreenSize.y))
	return returnValue

func applyAngleAnimation(delta: float) -> float:
		var movementAngle = lerpf(spriteTexture.rotation_degrees, movementAngleSteepness * movementAngleToggle, movementAngleSpeed * delta)
		if floor(spriteTexture.rotation_degrees) >= movementAngleSteepness - 1.0:
			movementAngleToggle = -1
		elif floor(spriteTexture.rotation_degrees) <= -(movementAngleSteepness - 1.0):
			movementAngleToggle = 1
		return movementAngle
			
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if hungerDelay.hasPassed(40, true):
		setHungyLevel(hungyLevel + 1)
	
	if dragging and dragTimerTracker.isRunning():
		var dragElapsedTime: float = dragTimerTracker.getElapsedTime()
		if dragElapsedTime - dragTimerPrevDura >= angyDragDuration:
			dragTimerPrevDura = dragElapsedTime
			changeHappinessScore(-dragPunishmentAmount)
			veryAngyDoro(true)
			
	if not dragging and not dragTimerTracker.isRunning() and dragTimerTracker.getElapsedTime() <= 1:
		changeHappinessScore(-pokePunishmentAmount)
		dragTimerTracker.reset()
			
	match currentTask:
		TasksEnum.None:
			if sleepingParticlesEmitter.is_emitting():
				sleepingParticlesEmitter.set_emitting(false)
				
	if Input.is_action_just_pressed("optionsMenuBind"):
		get_tree().root.add_child(optionsMenuScene.instantiate())
	
	if Input.is_action_just_pressed("debugMenuBind"):
		get_tree().root.add_child(debugMenuScene.instantiate())

	processHeadpat()
		
			
func _physics_process(delta: float) -> void:
	currentPosition = DisplayServer.window_get_position()
	velocity = Vector2.ZERO
	var directionHorizontal: int = 0
	var directionVertical: int = 0
	var movementAngle: float = 0
	
	if currentAnimation == Animations.Angy:
		var spriteAngle: float = lerpf(angySprite.rotation_degrees, movementAngleSteepness * angyAngleToggle, 3.0 * get_physics_process_delta_time())
		if floor(angySprite.rotation_degrees) >= movementAngleSteepness - 1.0:
			angyAngleToggle = -1
		elif floor(angySprite.rotation_degrees) <= -(movementAngleSteepness - 1.0):
			angyAngleToggle = 1
		angySprite.set_rotation_degrees(spriteAngle)
		if spriteTexture.is_flipped_h():
			angySprite.set_position(Vector2(-9, -12))
		else:
			angySprite.set_position(Vector2(9, -12))
	
	if currentTask == TasksEnum.None or currentTask == TasksEnum.WatchingTV:
			if movementPause and dragging:
				currentPosition = DisplayServer.mouse_get_position() - (windowSize / 2)
				movementAngle = applyAngleAnimation(delta)

			if not caged and not movementPause:
				var waypointDist: float = calcDistanceToWaypoint()
				if waypointDist <= minDistanceToWaypoint:
					if moveDelay.hasPassed(nextMoveWaitDuration, true):
						nextMoveWaitDuration = randf_range(5, 10)
						if watchingTV:
							if tvNode != null:
								var tvPosition = tvNode.get_position()
								waypointLocation = tvPosition - Vector2i(100, -56)
								spriteTexture.flip_h = true
						else:
							waypointLocation = createRandomPoint()
				elif waypointDist > minDistanceToWaypoint:
						var halfSize: Vector2i = Vector2i(windowSize.x / 2.0, windowSize.y / 2.0)
						if waypointLocation.x > currentPosition.x + halfSize.x:
							directionHorizontal = 1
						elif waypointLocation.x < currentPosition.x + halfSize.x:
							directionHorizontal = -1
							
						if waypointLocation.y > currentPosition.y + halfSize.y:
							directionVertical = 1
						elif waypointLocation.y < currentPosition.y + halfSize.y:
							directionVertical = -1
			
			var currentSpeed: float = walkSpeed
			if panicState:
				currentSpeed = runSpeed
				
			if directionHorizontal:
				spriteTexture.flip_h = directionHorizontal == 1
				velocity.x = (currentSpeed * directionHorizontal) * delta
				movementAngle = applyAngleAnimation(delta)
			else: 
				velocity.x = 0
			
			if directionVertical:
				velocity.y = (currentSpeed * directionVertical) * delta
				movementAngle = applyAngleAnimation(delta)
			else: 
				velocity.y = 0
	
	spriteTexture.set_rotation_degrees(movementAngle)
	currentPosition.x += velocity.x
	currentPosition.y += velocity.y
	DisplayServer.window_set_position(currentPosition)
	
func _on_mouse_entered() -> void:
	if panicState:
		return
		
	movementPause = true

func _on_mouse_exited() -> void:
	if not dragging:
		movementPause = false

@warning_ignore("unused_parameter")
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouseEvent: InputEventMouseButton = event
		if panicState:
			return
			
		if mouseEvent.button_index == 1:
			if dragging and mouseEvent.pressed:
				dragging = true
			else:
				dragging = mouseEvent.pressed
		if dragging:
			dragTimerTracker.start()
			dragTimerPrevDura = 0.0
			currentTask = TasksEnum.None
			applyAnimation()
		else:
			dragTimerTracker.stop()

func processHungy() -> void:
	if disableCaring:
		return
		
	if hungyLevel >= 90:
		changeHappinessScore(-2)
		if not hungyParticleEmitter.is_emitting():
			hungyParticleEmitter.set_emitting(true)
		if currentTask != TasksEnum.None:
			currentTask = TasksEnum.None
	else:
		if hungyParticleEmitter.is_emitting():
			hungyParticleEmitter.set_emitting(false)

func _on_emotion_update_timeout() -> void:
	if headPatAngyTriggered:
		headPatAmount -= 1
		headPatAmount = clamp(headPatAmount, 0, 10)
		if headPatAmount <= 0:
			headPatAngyTriggered = false
			
	processHungy()

	if watchingTV:
		if watchTime.hasPassed(10):
			watchingTV = false

	if not dragging and not movementPause and not caged and hungyLevel < 90:
		var taskChance: int = randi_range(0, 100)
		if taskChance <= chanceForTask:
			if currentTask == TasksEnum.None:
				currentTask = TasksEnum.values()[randi_range(0, TasksEnum.values().size() - 1)]
			else:
				currentTask = TasksEnum.None
				
			match currentTask:
				TasksEnum.Sleeping:
					changeHappinessScore(5)
					sleepingParticlesEmitter.set_emitting(true)
					spriteTexture.play("Idle")
					spriteTexture.pause()
					spriteTexture.set_frame(0)
				TasksEnum.SundayBodyPillow:
					changeHappinessScore(1)
					spriteTexture.play("sundayPillow")
				TasksEnum.Sunglasses:
					changeHappinessScore(1)
					spriteTexture.play("Sunglasses")
				TasksEnum.NukeTinker:
					changeHappinessScore(1)
					changeNukeProgress(1)
					spriteTexture.play("NukeTinker")
				TasksEnum.WatchingTV:
					if not global.getSetting("NoTVSpawns").getValue():
						changeHappinessScore(1)
						spriteTexture.play("Idle")
						var tvPosition = null
						if tvNode == null:
							tvNode = tvScene.instantiate()
							get_tree().root.add_child(tvNode)
							tvPosition = tvNode.get_position()
							waypointLocation = tvPosition - Vector2i(100, -56)
						else:
							tvPosition = tvNode.get_position()
							waypointLocation = tvPosition - Vector2i(100, -56)
						watchTime.reset()
						watchingTV = true
					else:
						currentTask = TasksEnum.SundayBodyPillow
						changeHappinessScore(1)
						spriteTexture.play("Sunglasses")
				
	applyAnimation()
				
func veryHappyDoro() -> void:
	currentAnimation = Animations.Happie
	animationDelay.reset()
	applyAnimation()
	
func psychedlicDoro() -> void:
	currentAnimation = Animations.Psychedelics
	animationDelay.reset()
	applyAnimation()
	
func evilLaughDoro() -> void:
	currentAnimation = Animations.EvilLaugh
	animationDelay.reset()
	applyAnimation()
	
func veryAngyDoro(applyPanic=false) -> void:
	currentAnimation = Animations.Angy
	animationDelay.reset()
	if applyPanic:
		panicState = true
		dragging = false
		movementPause = false
	applyAnimation()

func processHeadpat() -> void:
	if headPatPart1 and headPatpart2:
		headPatPart1 = false
		headPatpart2 = false
		headPatCount += 1
		
	if headPatCount >= headPatTriggerAmount:
		headPatCount = 0
		headPatAmount += 1
		if headPatAngyTriggered:
			changeHappinessScore(-2)
			veryAngyDoro()
		else:
			changeHappinessScore(5)
			veryHappyDoro()
			
	if headPatAmount >= headPatLimit and not headPatAngyTriggered:
		changeHappinessScore(-2)
		veryAngyDoro()
		headPatAngyTriggered = true
			

func _on_headpat_part_1_mouse_entered() -> void:
	headPatPart1 = true

func _on_headpat_part_2_mouse_entered() -> void:
	headPatpart2 = true
	
func doroSaveData() -> Dictionary:
	return {
		"happinesScore" : happinesScore,
		"hungyLevel" : hungyLevel,
		"caged" : caged,
		"coins" : playerCoins,
		"nukeProgress" : nukeProgress
	}
	
func loadDoroSaveData(saveData: Dictionary) -> void:
	if saveData.has("happinesScore"):
		happinesScore = int(saveData.get("happinesScore"))
	if saveData.has("hungyLevel"):
		hungyLevel = int(saveData.get("hungyLevel"))
	if saveData.has("caged"):
		caged = bool(saveData.get("caged"))
	if saveData.has("coins"):
		playerCoins = int(saveData.get("coins"))
	if saveData.has("nukeProgress"):
		nukeProgress = int(saveData.get("nukeProgress"))
	applyAnimation()

func _on_save_update_timeout() -> void:
	global.writeDoroData()

func _on_uncage() -> void:
	caged = false
	cagedSprite.hide()
	global.writeDoroData()
	
func isCaged() -> bool:
	return caged
	
func setCaged(state) -> void:
	caged = state
	if not caged:
		cagedSprite.hide()
	
func doroResetAllStats() -> void:
	happinesScore = 100
	hungyLevel = 0
	headPatCount = 0
	
func getPosition() -> Vector2i:
	return currentPosition

func _on_tv_destroyed() -> void:
	tvNode = null
	watchingTV = false

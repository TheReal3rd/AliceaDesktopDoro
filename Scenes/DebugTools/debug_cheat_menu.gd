extends Window

@onready var global = get_node("/root/Global")

@onready var tvScene = load("res://Scenes/TVScene/TVScene.tscn")

var doroNode = null

func _ready() -> void:
	doroNode = global.getDoroNode()

func _on_close_requested() -> void:
	queue_free()

func _on_reset_happiness_pressed() -> void:
	global.getDoroNode().setHappinessScore(100)

func _on_reset_hungy_level_pressed() -> void:
	global.getDoroNode().setHungyLevel(0)

func _on_reset_all_pressed() -> void:
	var settingsDict: Dictionary = global.getSettings()
	for setting in settingsDict.values():
		setting.reset()
	doroNode.setHungyLevel(0)
	doroNode.setHappinessScore(100)
	doroNode.setCaged(true)
	global.writeSettings()
	global.writeDoroData()
	OS.delay_msec(100)
	print("Reset")
	get_tree().quit(0)

func _on_play_psychedlic_pressed() -> void:
	doroNode.psychedlicDoro()

func _on_play_happie_pressed() -> void:
	doroNode.veryHappyDoro()

func _on_play_evil_laugh_pressed() -> void:
	doroNode.evilLaughDoro()

func _on_play_angy_pressed() -> void:
	doroNode.veryAngyDoro()

func _on_play_angy_panic_pressed() -> void:
	doroNode.veryAngyDoro(true)

func _on_spawn_tv_pressed() -> void:
	var tvNode = tvScene.instantiate()
	get_tree().root.add_child(tvNode)
	doroNode.tvNode = tvNode
	
func _on_give_coin_pressed() -> void:
	doroNode.giveCoins(1)

extends Window

@onready var interactionMenuNode = $InteractionMenu
@onready var settingsMenuNode = $SettingsMenu
@onready var settingsContainer = $SettingsMenu/ScrollContainer/VBoxContainer

@onready var global = get_node("/root/Global")

#Settings Scene
@onready var settingScene = load("res://Scenes/SettingScene.tscn")
@onready var displayConfiguratorScene = load("res://Scenes/ScreenConfigurator/ScreenConfigurator.tscn")

#Minigames
@onready var feedingMinigame = load("res://Scenes/FeedScene/FeedingItMinigame.tscn")
@onready var nukeSabotageMinigame = load("res://Scenes/NukeSabotage/NukeSabotage.tscn")
@onready var dorozonShop = load("res://Scenes/Dorozon Shop/DorozonShopScene.tscn")

func _ready() -> void:
	for setting in global.getSettings().values():
		var settingSceneTemp = settingScene.instantiate()
		settingSceneTemp.setSetting(setting)
		settingsContainer.add_child(settingSceneTemp)

func _on_close_requested() -> void:
	queue_free()
	
func startMinigame(minigameScene) -> void:
	var minigame = minigameScene.instantiate()
	get_tree().root.add_child(minigame)
	queue_free()

func _on_feed_pressed() -> void:
	startMinigame(feedingMinigame)

func _on_settings_pressed() -> void:
	interactionMenuNode.hide()
	settingsMenuNode.show()

func _on_setting_exit_button_pressed() -> void:
	interactionMenuNode.show()
	settingsMenuNode.hide()

func _on_setting_save_button_pressed() -> void:
	for node in settingsContainer.get_children():
		node.applyValueChanges()
	global.writeSettings()

func _on_shutdown_pressed() -> void:
	global.writeSettings()
	global.writeDoroData()
	get_tree().quit(0)

func _on_nuke_sabotage_pressed() -> void:
	startMinigame(nukeSabotageMinigame)

func _on_dorozon_shop_pressed() -> void:
	startMinigame(dorozonShop)

func _on_display_config_button_pressed() -> void:
	startMinigame(displayConfiguratorScene)

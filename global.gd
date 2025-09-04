extends Node

@onready var applicationScene = load("res://Scenes/AdoptionSigning/AdoptionSigning.tscn")

const settingsSavePath: String = "user://settings.json"
const doroSavePath: String = "user://doroData.json"

var doroNode: Node = null : get = getDoroNode
var doroSaveDataRead: bool = false

var settingsList: Dictionary = {
	"Username" : settingBase.new("Username", "Username the doro will be addressing you as.", "Stinky", "Stinky"),
	"NoDoroCare" : settingBase.new("No Doro Care", "Disables all the caring feature. No sadness only happiness.", false, false),
	"NoTVSpawns" : settingBase.new("No TV Spawns", "Disables the random task thats spawns in a TV for doro to watch.", false, false),
}: get = getSettings

func _ready() -> void:
	readSettings()
	writeSettings()
	
func _exit_tree() -> void:
	writeSettings()

func _process(_delta: float) -> void:
	if not doroSaveDataRead and doroNode != null:
		readDoroData(true)
		if doroNode.isCaged():
			get_tree().root.add_child(applicationScene.instantiate())
		doroSaveDataRead = true
		
func getSettings() -> Dictionary:
	return settingsList

func getDoroNode() -> Node:
	return doroNode
	
func setDoroNode(newDoroNode) -> void:
	doroNode = newDoroNode
	
func getSetting(stringName: String) -> settingBase:
	return settingsList.get(stringName)
	
func unleashTheCreature(signtureName: String) -> void:
	if doroNode != null:
		doroNode.emit_signal("uncage")
		var userNameSetting = settingsList.get("Username")
		userNameSetting.setValue(signtureName)
		doroNode.doroResetAllStats()
		writeSettings()
		writeDoroData()
	
func readDoroData(allowDataWrite:bool=false) -> void:
	if not FileAccess.file_exists(doroSavePath):
		print("No Doro Data Saved.")
		if allowDataWrite:
			writeDoroData()
		return
		
	var file = FileAccess.open(doroSavePath, FileAccess.READ)
	if file:
		var jsonString: String = file.get_as_text()
		var parsed = JSON.parse_string(jsonString)
		var data: Dictionary = {}
		if typeof(parsed) == TYPE_DICTIONARY:
			data = parsed
			print("Doro Data loaded: ", data)
		else:
			printerr("Error: The Save file is not a dictionary.")
		file.close()
		
		if doroNode != null:
			doroNode.loadDoroSaveData(data)
		else:
			printerr("Doro node not initilized but save data read and set attempted logical error.")
		
	
func writeDoroData() -> void:
	var file = FileAccess.open(doroSavePath, FileAccess.WRITE)
	if file:
		var data: Dictionary = doroNode.doroSaveData()
		var jsonString = JSON.stringify(data)
		file.store_string(jsonString)
		file.close()
		print("Doro Data Saved.")

func readSettings() -> void:
	if not FileAccess.file_exists(settingsSavePath):
		print("No Setting Data Saved.")
		writeSettings()
		return
		
	var file = FileAccess.open(settingsSavePath, FileAccess.READ)
	if file:
		var jsonString: String = file.get_as_text()
		var parsed = JSON.parse_string(jsonString)
		var data: Dictionary = {}
		if typeof(parsed) == TYPE_DICTIONARY:
			data = parsed
			print("Setting Data loaded: ", data)
		else:
			printerr("Error: The Save file is not a dictionary.")
		file.close()
		
		for key in  data.keys():
			if settingsList.has(key):
				var setting = settingsList.get(key)
				setting.setValue(data.get(key))
	
func writeSettings() -> void:
	var file = FileAccess.open(settingsSavePath, FileAccess.WRITE)
	if file:
		var data: Dictionary = {}
		for index in range(0, settingsList.size()):
			var settingName = settingsList.keys()[index]
			var settingValue = settingsList.values()[index].getValue()
			data.set(settingName, settingValue)
			
		var jsonString = JSON.stringify(data)
		file.store_string(jsonString)
		file.close()
		print("Settings Data Saved.")

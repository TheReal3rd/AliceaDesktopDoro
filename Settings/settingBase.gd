class_name settingBase extends Resource

var settingName: String = "SettingName" : get = getSettingName
var settingDescription: String = "Put your setting description here." : get = getSettingDescription
var value = null : set = setValue, get = getValue
var defaultValue = null : get = getDefaultValue
var valueType = null : get = getValueType

func _init(settingName, settingDescription, value, defaultValue) -> void:
	self.valueType = typeof(value)
	self.settingName = settingName
	self.settingDescription = settingDescription
	self.value = value
	self.defaultValue = defaultValue
	
func reset() -> void:
	value = defaultValue
	
func getDefaultValue():
	return defaultValue
	
func getSettingName() -> String:
	return settingName
	
func getSettingDescription() -> String:
	return settingDescription
	
func setValue(newValue) -> void:
	if defaultValue is int:
		if newValue is float:
			value = int(newValue)
			return
	if typeof(newValue) == valueType:
		value = newValue
	else:
		printerr("The given value type didn't match the required value type. The type of: "+str(valueType))
	
func getValue():
	return value
	
func getValueType():
	return valueType

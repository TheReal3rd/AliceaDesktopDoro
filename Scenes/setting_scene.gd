extends HBoxContainer

@onready var nameLabel = $NameLabel
@onready var valueEntryString = $ValueEntryString
@onready var valueEntryBoolean = $ValueEntryBoolean

var settingObject: settingBase = null : set = setSetting

func _ready() -> void:
	if settingObject != null:
		nameLabel.set_text(settingObject.getSettingName())
		nameLabel.set_tooltip_text(settingObject.getSettingDescription())
		if settingObject.getValue() is bool:
			valueEntryBoolean.set_pressed(settingObject.getValue())
			valueEntryBoolean.show()
			valueEntryString.hide()
		else:
			valueEntryString.set_text(str(settingObject.getValue()))
			valueEntryString.show()
			valueEntryBoolean.hide()

func applyValueChanges() -> bool:
	var currentValue = settingObject.getValue()
	if currentValue is bool:
		settingObject.setValue(valueEntryBoolean.is_pressed())
	elif currentValue is String:
		settingObject.setValue(valueEntryString.get_text())
	elif currentValue is int:
		var value = valueEntryString.get_text()
		if value.is_valid_int():
			settingObject.setValue(int(valueEntryString.get_text()))
		else:
			return true
	elif currentValue is float:
		var value = valueEntryString.get_text()
		if value.is_valid_float():
			settingObject.setValue(float(valueEntryString.get_text()))
		else:
			return true
	return false
	
func setSetting(setting) -> void:
	settingObject = setting

func _on_reset_button_pressed() -> void:
	var defaultValue = settingObject.getDefaultValue()
	if defaultValue is bool:
		valueEntryBoolean.set_pressed(defaultValue)
	elif defaultValue is String or defaultValue is int or defaultValue is float:
		valueEntryString.set_text(str(defaultValue))
	
